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
        if (liability.getCategoryId() == null) {
            QueryWrapper<Category> qw = new QueryWrapper<>();
            qw.eq("name", "分期还款").eq("type", 2).last("LIMIT 1");
            Category cat = categoryMapper.selectOne(qw);
            if (cat != null) {
                liability.setCategoryId(cat.getId());
            }
        }
        liabilityMapper.insert(liability);
        return liability;
    }

    @Override
    public Liability updateLiability(Liability liability) {
        liabilityMapper.updateById(liability);
        return liability;
    }

    @Override
    public void deleteLiability(Long id) {
        liabilityMapper.deleteById(id);
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

        // 计算当前周期起止时间
        CycleTemplate template = cycleTemplateMapper.findDefault();
        int startDay = (template != null && template.getStartDay() != null) ? template.getStartDay() : 1;
        LocalDate today = LocalDate.now();

        int actualStartDay = Math.min(startDay, today.lengthOfMonth());
        LocalDate cycleStartDate;
        if (today.getDayOfMonth() >= actualStartDay) {
            cycleStartDate = today.withDayOfMonth(actualStartDay);
        } else {
            LocalDate lastMonth = today.minusMonths(1);
            cycleStartDate = lastMonth.withDayOfMonth(Math.min(startDay, lastMonth.lengthOfMonth()));
        }
        LocalDate nextMonth = cycleStartDate.plusMonths(1);
        int nextMonthStartDay = Math.min(startDay, nextMonth.lengthOfMonth());
        LocalDate cycleEndDate = nextMonth.withDayOfMonth(nextMonthStartDay).minusDays(1);

        for (Liability l : activeLiabilities) {
            if (l.getCurrentPeriod() >= l.getTotalPeriods()) {
                l.setStatus("SETTLED");
                liabilityMapper.updateById(l);
                continue;
            }

            int rDay = l.getRepaymentDay() != null ? l.getRepaymentDay() : 10;
            // 定位当期还款日
            LocalDate repaymentDate;
            if (rDay >= cycleStartDate.getDayOfMonth()) {
                repaymentDate = cycleStartDate.withDayOfMonth(Math.min(rDay, cycleStartDate.lengthOfMonth()));
            } else {
                repaymentDate = cycleEndDate.withDayOfMonth(Math.min(rDay, cycleEndDate.lengthOfMonth()));
            }

            // 若尚未到还款日，跳过
            if (today.isBefore(repaymentDate)) {
                continue;
            }

            // 检查当期是否已为此负债生成流水
            QueryWrapper<Transaction> txQuery = new QueryWrapper<>();
            txQuery.eq("liability_id", l.getId())
                    .ge("transaction_date", cycleStartDate)
                    .le("transaction_date", cycleEndDate);
            Long count = transactionMapper.selectCount(txQuery);
            if (count != null && count > 0) {
                // 当期已扣款，无需重复扣
                continue;
            }

            // 决定扣款账户 (默认账户余额充足则用默认，不足则降级为系统余额最多的账户)
            Long targetAccountId = l.getDefaultAccountId();
            Account defAcc = targetAccountId != null ? accountMapper.selectById(targetAccountId) : null;
            if (defAcc == null || defAcc.getCurrentBalance().compareTo(l.getPeriodAmount()) < 0) {
                // 查找全系统余额最高的账户
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
            tx.setTransactionDate(repaymentDate.isAfter(today) ? today : repaymentDate);
            tx.setAccountId(targetAccountId);
            tx.setCategoryId(l.getCategoryId());
            tx.setLiabilityId(l.getId());
            tx.setRemark("【分期还款】" + l.getName() + " (" + nextPeriod + "/" + l.getTotalPeriods() + "期)");

            transactionService.addTransaction(tx);

            l.setCurrentPeriod(nextPeriod);
            if (nextPeriod >= l.getTotalPeriods()) {
                l.setStatus("SETTLED");
                l.setSettledAt(LocalDateTime.now());
            }
            liabilityMapper.updateById(l);
        }
    }
}
