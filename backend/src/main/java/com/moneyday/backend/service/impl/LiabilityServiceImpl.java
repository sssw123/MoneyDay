package com.moneyday.backend.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.moneyday.backend.entity.*;
import com.moneyday.backend.mapper.*;
import com.moneyday.backend.service.LiabilityService;
import com.moneyday.backend.service.TransactionService;
import org.springframework.beans.BeanUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

@Service
public class LiabilityServiceImpl implements LiabilityService {

    @Autowired
    private LiabilityMapper liabilityMapper;

    @Autowired
    private AccountMapper accountMapper;

    @Autowired
    private CategoryMapper categoryMapper;

    @Autowired
    private TransactionMapper transactionMapper;

    @Autowired
    private TransactionService transactionService;

    @Autowired
    private CycleTemplateMapper cycleTemplateMapper;

    @Override
    public List<LiabilityVO> getAllLiabilities() {
        // 自动巡检并补扣到期还款
        try {
            checkAndExecuteDueRepayments();
        } catch (Exception ignored) {}

        List<Liability> list = liabilityMapper.selectList(new QueryWrapper<Liability>().orderByDesc("created_at"));
        if (list == null || list.isEmpty()) {
            return new ArrayList<>();
        }

        List<LiabilityVO> voList = new ArrayList<>();
        for (Liability l : list) {
            LiabilityVO vo = new LiabilityVO();
            BeanUtils.copyProperties(l, vo);

            int totalP = l.getTotalPeriods() != null ? l.getTotalPeriods() : 1;
            int curP = l.getCurrentPeriod() != null ? l.getCurrentPeriod() : 0;
            int remainingP = Math.max(0, totalP - curP);

            vo.setRemainingPeriods(remainingP);
            BigDecimal pAmount = l.getPeriodAmount() != null ? l.getPeriodAmount() : BigDecimal.ZERO;
            vo.setRemainingAmount(pAmount.multiply(BigDecimal.valueOf(remainingP)));
            vo.setProgressPercent(Math.min(100, Math.max(0, (curP * 100) / totalP)));

            if (l.getDefaultAccountId() != null) {
                Account acc = accountMapper.selectById(l.getDefaultAccountId());
                if (acc != null) {
                    vo.setDefaultAccountName(acc.getName());
                }
            }

            if (l.getCategoryId() != null) {
                Category cat = categoryMapper.selectById(l.getCategoryId());
                if (cat != null) {
                    vo.setCategoryName(cat.getName());
                }
            }

            voList.add(vo);
        }
        return voList;
    }

    @Override
    public Liability addLiability(Liability liability) {
        if (liability.getStartDate() == null) {
            liability.setStartDate(LocalDate.now());
        }
        if (liability.getCurrentPeriod() == null) {
            liability.setCurrentPeriod(0);
        }
        if (liability.getStatus() == null) {
            liability.setStatus("REPAYING");
        }
        if (liability.getAutoCycleFixedExpense() == null) {
            liability.setAutoCycleFixedExpense(1);
        }
        if (liability.getRepaymentDay() == null) {
            liability.setRepaymentDay(10);
        }

        // 推算/校验初始下一次还款日
        if (liability.getNextRepaymentDate() == null) {
            int rDay = liability.getRepaymentDay();
            LocalDate today = LocalDate.now();
            int actualDay = Math.min(rDay, today.lengthOfMonth());
            LocalDate cand = today.withDayOfMonth(actualDay);
            if (cand.isBefore(today)) {
                LocalDate nextM = today.plusMonths(1);
                cand = nextM.withDayOfMonth(Math.min(rDay, nextM.lengthOfMonth()));
            }
            liability.setNextRepaymentDate(cand);
        }

        // 检查已还期数是否已满
        if (liability.getTotalPeriods() != null && liability.getCurrentPeriod() >= liability.getTotalPeriods()) {
            liability.setStatus("SETTLED");
            liability.setSettledAt(LocalDateTime.now());
            liability.setNextRepaymentDate(null);
        }

        if (liability.getCategoryId() == null) {
            QueryWrapper<Category> qw = new QueryWrapper<>();
            qw.eq("name", "分期还款").eq("type", 2).last("LIMIT 1");
            Category cat = categoryMapper.selectOne(qw);
            if (cat != null) {
                liability.setCategoryId(cat.getId());
            } else {
                QueryWrapper<Category> anyQw = new QueryWrapper<>();
                anyQw.eq("type", 2).last("LIMIT 1");
                Category anyCat = categoryMapper.selectOne(anyQw);
                if (anyCat != null) {
                    liability.setCategoryId(anyCat.getId());
                }
            }
        }
        liabilityMapper.insert(liability);
        return liability;
    }

    @Override
    public Liability updateLiability(Liability liability) {
        if (liability.getTotalPeriods() != null && liability.getCurrentPeriod() != null) {
            if (liability.getCurrentPeriod() >= liability.getTotalPeriods()) {
                liability.setStatus("SETTLED");
                liability.setSettledAt(LocalDateTime.now());
                liability.setNextRepaymentDate(null);
            } else if ("SETTLED".equalsIgnoreCase(liability.getStatus())) {
                liability.setStatus("REPAYING");
                liability.setSettledAt(null);
            }
        }
        liabilityMapper.updateById(liability);
        return liability;
    }

    @Override
    public void deleteLiability(Long id) {
        liabilityMapper.deleteById(id);
    }

    @Override
    @Transactional
    public void repayPeriods(Long id, Integer periods, BigDecimal amount, Long accountId) {
        Liability liability = liabilityMapper.selectById(id);
        if (liability == null || "SETTLED".equalsIgnoreCase(liability.getStatus())) {
            throw new RuntimeException("负债不存在或已结清");
        }

        int curP = liability.getCurrentPeriod() != null ? liability.getCurrentPeriod() : 0;
        int totalP = liability.getTotalPeriods() != null ? liability.getTotalPeriods() : 1;
        int remainingP = totalP - curP;

        if (periods == null || periods < 1 || periods > remainingP) {
            throw new IllegalArgumentException("归还期数无效，最多可还剩余 " + remainingP + " 期");
        }

        Account account = accountMapper.selectById(accountId);
        if (account == null) {
            throw new IllegalArgumentException("扣款账户不存在");
        }
        if (amount == null || amount.compareTo(BigDecimal.ZERO) <= 0) {
            throw new IllegalArgumentException("还款金额必须大于0");
        }
        if (account.getCurrentBalance().compareTo(amount) < 0) {
            throw new IllegalArgumentException("扣款账户余额不足！当前余额: ¥" + account.getCurrentBalance() + "，应还: ¥" + amount);
        }

        // 1. 生成真实支出流水
        Transaction tx = new Transaction();
        tx.setType(2); // 支出
        tx.setAmount(amount);
        tx.setTransactionDate(LocalDate.now());
        tx.setAccountId(accountId);
        tx.setCategoryId(liability.getCategoryId());
        tx.setLiabilityId(liability.getId());
        String periodRemark = (periods == 1)
                ? String.format("【提前还款】%s (第%d期)", liability.getName(), curP + 1)
                : String.format("【提前还款】%s (第%d-%d期)", liability.getName(), curP + 1, curP + periods);
        tx.setRemark(periodRemark);
        transactionService.addTransaction(tx);

        // 2. 推进期数与状态
        int newCurrentPeriod = curP + periods;
        liability.setCurrentPeriod(newCurrentPeriod);

        if (newCurrentPeriod >= totalP) {
            liability.setStatus("SETTLED");
            liability.setSettledAt(LocalDateTime.now());
            liability.setNextRepaymentDate(null);
        } else {
            // 3. 顺延下一次还款日 (按所还期数往后推 N 个月，对齐每月还款日)
            LocalDate baseDate = liability.getNextRepaymentDate();
            if (baseDate == null) {
                baseDate = LocalDate.now();
            }
            LocalDate shifted = baseDate.plusMonths(periods);
            int rDay = liability.getRepaymentDay() != null ? liability.getRepaymentDay() : 10;
            liability.setNextRepaymentDate(shifted.withDayOfMonth(Math.min(rDay, shifted.lengthOfMonth())));
        }
        liabilityMapper.updateById(liability);
    }

    @Override
    @Transactional
    public void settleLiability(Long id, Long accountId, BigDecimal settleAmount) {
        Liability liability = liabilityMapper.selectById(id);
        if (liability == null || "SETTLED".equalsIgnoreCase(liability.getStatus())) {
            throw new RuntimeException("负债不存在或已结清");
        }

        Account account = accountMapper.selectById(accountId);
        if (account == null) {
            throw new IllegalArgumentException("扣款账户不存在");
        }
        if (settleAmount == null || settleAmount.compareTo(BigDecimal.ZERO) <= 0) {
            throw new IllegalArgumentException("结清金额必须大于0");
        }
        if (account.getCurrentBalance().compareTo(settleAmount) < 0) {
            throw new IllegalArgumentException("扣款账户余额不足！当前余额: ¥" + account.getCurrentBalance() + "，结清需: ¥" + settleAmount);
        }

        int remainingP = liability.getTotalPeriods() - liability.getCurrentPeriod();
        Transaction tx = new Transaction();
        tx.setType(2); // 支出
        tx.setAmount(settleAmount);
        tx.setTransactionDate(LocalDate.now());
        tx.setAccountId(accountId);
        tx.setCategoryId(liability.getCategoryId());
        tx.setLiabilityId(liability.getId());
        tx.setRemark("【提前结清】" + liability.getName() + " (结清剩余" + remainingP + "期)");

        transactionService.addTransaction(tx);

        liability.setCurrentPeriod(liability.getTotalPeriods());
        liability.setStatus("SETTLED");
        liability.setSettledAt(LocalDateTime.now());
        liability.setNextRepaymentDate(null);
        liabilityMapper.updateById(liability);
    }

    @Override
    @Transactional
    public void checkAndExecuteDueRepayments() {
        List<Liability> activeLiabilities = liabilityMapper.selectList(
                new QueryWrapper<Liability>()
                        .eq("status", "REPAYING")
                        .eq("auto_cycle_fixed_expense", 1)
        );

        if (activeLiabilities == null || activeLiabilities.isEmpty()) {
            return;
        }

        LocalDate today = LocalDate.now();

        for (Liability l : activeLiabilities) {
            if (l.getCurrentPeriod() >= l.getTotalPeriods()) {
                l.setStatus("SETTLED");
                l.setSettledAt(LocalDateTime.now());
                l.setNextRepaymentDate(null);
                liabilityMapper.updateById(l);
                continue;
            }

            LocalDate nextDue = l.getNextRepaymentDate();
            if (nextDue == null) {
                // 自动补齐 nextRepaymentDate
                int rDay = l.getRepaymentDay() != null ? l.getRepaymentDay() : 10;
                int actualDay = Math.min(rDay, today.lengthOfMonth());
                nextDue = today.withDayOfMonth(actualDay);
                if (nextDue.isBefore(today)) {
                    LocalDate nextM = today.plusMonths(1);
                    nextDue = nextM.withDayOfMonth(Math.min(rDay, nextM.lengthOfMonth()));
                }
                l.setNextRepaymentDate(nextDue);
                liabilityMapper.updateById(l);
            }

            // 排期守护：若尚未到下一次还款日，坚决跳过，杜绝提前误扣与重复扣款
            if (today.isBefore(nextDue)) {
                continue;
            }

            // 决定扣款账户 (默认账户余额充足则用默认，不足则降级为系统余额最多的账户)
            Long targetAccountId = l.getDefaultAccountId();
            Account defAcc = targetAccountId != null ? accountMapper.selectById(targetAccountId) : null;
            if (defAcc == null || defAcc.getCurrentBalance().compareTo(l.getPeriodAmount()) < 0) {
                Account bestAcc = accountMapper.selectOne(new QueryWrapper<Account>().orderByDesc("current_balance").last("LIMIT 1"));
                if (bestAcc != null) {
                    targetAccountId = bestAcc.getId();
                }
            }
            if (targetAccountId == null) {
                continue;
            }

            // 执行自动扣款
            int nextPeriod = l.getCurrentPeriod() + 1;
            Transaction tx = new Transaction();
            tx.setType(2); // 支出
            tx.setAmount(l.getPeriodAmount());
            tx.setTransactionDate(today);
            tx.setAccountId(targetAccountId);
            tx.setCategoryId(l.getCategoryId());
            tx.setLiabilityId(l.getId());
            tx.setRemark("【分期还款】" + l.getName() + " (" + nextPeriod + "/" + l.getTotalPeriods() + "期)");

            transactionService.addTransaction(tx);

            l.setCurrentPeriod(nextPeriod);
            if (nextPeriod >= l.getTotalPeriods()) {
                l.setStatus("SETTLED");
                l.setSettledAt(LocalDateTime.now());
                l.setNextRepaymentDate(null);
            } else {
                int rDay = l.getRepaymentDay() != null ? l.getRepaymentDay() : 10;
                LocalDate shifted = nextDue.plusMonths(1);
                l.setNextRepaymentDate(shifted.withDayOfMonth(Math.min(rDay, shifted.lengthOfMonth())));
            }
            liabilityMapper.updateById(l);
        }
    }
}
