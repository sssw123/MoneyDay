package com.moneyday.backend.service.impl;

import com.moneyday.backend.entity.CycleTemplate;
import com.moneyday.backend.entity.FixedItem;
import com.moneyday.backend.entity.Target;
import com.moneyday.backend.entity.TargetVO;
import com.moneyday.backend.entity.Account;
import com.moneyday.backend.mapper.AccountMapper;
import com.moneyday.backend.mapper.CategoryMapper;
import com.moneyday.backend.mapper.CycleTemplateMapper;
import com.moneyday.backend.mapper.StatMapper;
import com.moneyday.backend.mapper.TargetMapper;
import com.moneyday.backend.mapper.TransactionMapper;
import com.moneyday.backend.service.CycleRecordService;
import com.moneyday.backend.service.TargetService;
import com.moneyday.backend.service.TransactionService;
import org.springframework.beans.BeanUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

@Service
public class TargetServiceImpl implements TargetService {
    @Autowired private com.moneyday.backend.security.OwnershipGuard guard;


    @Autowired
    private TargetMapper targetMapper;

    @Autowired
    private CycleRecordService cycleRecordService;

    @Autowired
    private CycleTemplateMapper cycleTemplateMapper;

    @Autowired
    private StatMapper statMapper;

    @Autowired
    private TransactionService transactionService;

    @Autowired
    private CategoryMapper categoryMapper;

    @Autowired
    private TransactionMapper transactionMapper;

    @Autowired
    private AccountMapper accountMapper;

    @Autowired
    private com.moneyday.backend.mapper.LiabilityMapper liabilityMapper;

    @Override
    public List<TargetVO> getAllTargets() {
        List<Target> targets = targetMapper.selectList(null);
        if (targets == null || targets.isEmpty()) {
            return new ArrayList<>();
        }

        // 1. 获取全局累计结余
        BigDecimal cumulativeBalance = cycleRecordService.getTotalCumulativeBalance();
        if (cumulativeBalance == null) {
            cumulativeBalance = BigDecimal.ZERO;
        }

        // 2. 获取可用净资产（总资产 - 未结清负债待还总额）
        BigDecimal totalAssets = statMapper.getTotalAssets();
        if (totalAssets == null) {
            totalAssets = BigDecimal.ZERO;
        }
        BigDecimal totalLiab = liabilityMapper.getTotalRemainingLiability();
        if (totalLiab == null) {
            totalLiab = BigDecimal.ZERO;
        }
        BigDecimal availableNetAssets = totalAssets.subtract(totalLiab);

        // 3. 计算历史已结算周期的平均实际结余
        LocalDate today = LocalDate.now();
        List<Map<String, Object>> recentCycles = cycleRecordService.getRecentCycles(12);
        BigDecimal historicalBalanceSum = BigDecimal.ZERO;
        int historicalCount = 0;
        if (recentCycles != null) {
            for (Map<String, Object> c : recentCycles) {
                String eDateStr = (String) c.get("cycleEndDate");
                if (eDateStr != null) {
                    LocalDate eDate = LocalDate.parse(eDateStr);
                    if (eDate.isBefore(today)) {
                        Object balObj = c.get("balance");
                        BigDecimal b = BigDecimal.ZERO;
                        if (balObj instanceof BigDecimal) {
                            b = (BigDecimal) balObj;
                        } else if (balObj != null) {
                            b = new BigDecimal(balObj.toString());
                        }
                        historicalBalanceSum = historicalBalanceSum.add(b);
                        historicalCount++;
                    }
                }
            }
        }
        BigDecimal avgHistoricalBalance = null;
        if (historicalCount > 0) {
            avgHistoricalBalance = historicalBalanceSum.divide(BigDecimal.valueOf(historicalCount), 2, RoundingMode.HALF_UP);
        }

        // 4. 解析默认周期模板中的基准预算
        CycleTemplate template = cycleTemplateMapper.findDefault();
        int startDay = (template != null && template.getStartDay() != null) ? template.getStartDay() : 1;
        BigDecimal templateFixedIncome = BigDecimal.ZERO;
        BigDecimal templateFixedExpense = BigDecimal.ZERO;
        BigDecimal templateFixedDeposit = BigDecimal.ZERO;
        if (template != null && template.getFixedItems() != null) {
            for (FixedItem item : template.getFixedItems()) {
                if (item.getAmount() == null) continue;
                if ("INCOME".equalsIgnoreCase(item.getType())) {
                    templateFixedIncome = templateFixedIncome.add(item.getAmount());
                } else if ("EXPENSE".equalsIgnoreCase(item.getType())) {
                    templateFixedExpense = templateFixedExpense.add(item.getAmount());
                } else if ("DEPOSIT".equalsIgnoreCase(item.getType())) {
                    templateFixedDeposit = templateFixedDeposit.add(item.getAmount());
                }
            }
        }
        // 模板基准结余: 固收 - 固支 - 固存
        BigDecimal templateBaselineBalance = templateFixedIncome.subtract(templateFixedExpense).subtract(templateFixedDeposit);
        // 模板基准净沉淀: 固存 + 模板基准结余 = 固收 - 固支
        BigDecimal templateBaselineNetAccumulation = templateFixedIncome.subtract(templateFixedExpense);

        // 5. 计算当前周期的起算日
        int actualStartDay = Math.min(startDay, today.lengthOfMonth());
        LocalDate currentStartDate;
        if (today.getDayOfMonth() >= actualStartDay) {
            currentStartDate = today.withDayOfMonth(actualStartDay);
        } else {
            LocalDate lastMonth = today.minusMonths(1);
            currentStartDate = lastMonth.withDayOfMonth(Math.min(startDay, lastMonth.lengthOfMonth()));
        }

        // 6. 为每个目标独立测算进度与达成时间
        List<TargetVO> voList = new ArrayList<>();
        for (Target t : targets) {
            TargetVO vo = new TargetVO();
            BeanUtils.copyProperties(t, vo);
            BigDecimal availableFunds = availableNetAssets;
            vo.setAvailableFunds(availableFunds);

            BigDecimal targetAmount = vo.getTargetAmount() != null ? vo.getTargetAmount() : BigDecimal.ZERO;

            if (vo.getIsRealized() != null && vo.getIsRealized() == 1) {
                vo.setProgress(100);
                vo.setEstimatedCompletionDate("-");
                vo.setIsEstimatedFallback(false);
                vo.setEstimatedReason("目标已实现");
                vo.setGap(BigDecimal.ZERO);
                voList.add(vo);
                continue;
            }

            // 计算进度百分比 (0 - 100)
            int progress = 0;
            if (targetAmount.compareTo(BigDecimal.ZERO) > 0) {
                if (availableFunds.compareTo(BigDecimal.ZERO) > 0) {
                    if (availableFunds.compareTo(targetAmount) >= 0) {
                        progress = 100;
                    } else {
                        progress = availableFunds.multiply(BigDecimal.valueOf(100))
                                .divide(targetAmount, 0, RoundingMode.FLOOR).intValue();
                    }
                }
            }
            vo.setProgress(progress);

            // 资金缺口
            BigDecimal gap = targetAmount.subtract(availableFunds);
            if (gap.compareTo(BigDecimal.ZERO) <= 0) {
                vo.setEstimatedCompletionDate("当前可实现");
                vo.setIsEstimatedFallback(false);
                vo.setEstimatedReason("当前可用净资产已满足目标金额");
                vo.setGap(BigDecimal.ZERO);
                voList.add(vo);
                continue;
            }
            vo.setGap(gap);

            // 计算存钱速度与推算模式 (长期资产目标以每周期净沉淀为准)
            BigDecimal velocity = BigDecimal.ZERO;
            boolean isFallback = false;
            String reason = "";

            if (avgHistoricalBalance != null && avgHistoricalBalance.compareTo(BigDecimal.ZERO) > 0) {
                BigDecimal netAccumulation = templateFixedDeposit.add(avgHistoricalBalance);
                if (netAccumulation.compareTo(BigDecimal.ZERO) > 0) {
                    velocity = netAccumulation;
                    isFallback = false;
                    reason = "基于每周期净沉淀推算 (固存¥" + templateFixedDeposit + " + 历史平均结余¥" + avgHistoricalBalance.setScale(2, RoundingMode.HALF_UP) + " = ¥" + netAccumulation.setScale(2, RoundingMode.HALF_UP) + "/周期)";
                } else {
                    velocity = BigDecimal.ZERO;
                }
            } else if (templateBaselineNetAccumulation.compareTo(BigDecimal.ZERO) > 0) {
                velocity = templateBaselineNetAccumulation;
                isFallback = true;
                String prefix = (avgHistoricalBalance == null || avgHistoricalBalance.compareTo(BigDecimal.ZERO) == 0)
                        ? "暂无充足历史周期盈余，此为按模板严格执行的基准净沉淀预计时间"
                        : "历史平均结余为负，此为按模板严格执行的基准净沉淀预计时间";
                reason = prefix + " (固收-固支 = ¥" + templateBaselineNetAccumulation.setScale(2, RoundingMode.HALF_UP) + "/周期)";
            } else {
                velocity = BigDecimal.ZERO;
                isFallback = false;
                reason = "历史结余与模板基准净沉淀均无盈余，无法预估";
            }

            if (velocity.compareTo(BigDecimal.ZERO) <= 0) {
                vo.setEstimatedCompletionDate("无法预估");
                vo.setIsEstimatedFallback(false);
                vo.setEstimatedReason(reason);
            } else {
                int neededCycles = gap.divide(velocity, 0, RoundingMode.CEILING).intValue();
                LocalDate targetCycleStart = currentStartDate.plusMonths(neededCycles - 1);
                LocalDate nextMonth = targetCycleStart.plusMonths(1);
                int nextMonthStartDay = Math.min(startDay, nextMonth.lengthOfMonth());
                LocalDate targetCycleEnd = nextMonth.withDayOfMonth(nextMonthStartDay).minusDays(1);

                vo.setEstimatedCompletionDate(targetCycleEnd.format(DateTimeFormatter.ISO_LOCAL_DATE));
                vo.setIsEstimatedFallback(isFallback);
                vo.setEstimatedReason(reason);
            }

            voList.add(vo);
        }

        return voList;
    }

    @Override
    public Target addTarget(Target target) {
        if (target.getStartDate() == null) {
            target.setStartDate(LocalDate.now());
        }
        target.setId(null);
        targetMapper.insert(target);
        return target;
    }

    @Override
    public Target updateTarget(Target target) {
        guard.require(targetMapper,target.getId());
        targetMapper.updateById(target);
        return target;
    }

    @Override
    public void deleteTarget(Long id) {
        guard.require(targetMapper,id);
        targetMapper.deleteById(id);
    }

    @Override
    @Transactional
    public void realizeTarget(Long id, Long accountId) {
        Target target = guard.require(targetMapper,id);
        if (target == null || (target.getIsRealized() != null && target.getIsRealized() == 1)) {
            throw new com.moneyday.backend.common.ApiException(400, "目标不存在或已实现");
        }

        Account account = guard.require(accountMapper,accountId);
        if (account == null) {
            throw new IllegalArgumentException("扣款账户不存在");
        }
        if (account.getCurrentBalance().compareTo(target.getTargetAmount()) < 0) {
            throw new IllegalArgumentException("扣款账户余额不足！当前账户余额: ¥" + account.getCurrentBalance() + "，目标需: ¥" + target.getTargetAmount());
        }

        // 目标：强校验总资产
        BigDecimal totalAssets = statMapper.getTotalAssets();
        if (totalAssets == null) totalAssets = BigDecimal.ZERO;
        if (totalAssets.compareTo(target.getTargetAmount()) < 0) {
            throw new IllegalArgumentException("总资产不足，严禁实现！当前总资产: ¥" + totalAssets + "，目标需: ¥" + target.getTargetAmount());
        }

        target.setIsRealized(1);
        targetMapper.updateById(target);

        com.baomidou.mybatisplus.core.conditions.query.QueryWrapper<com.moneyday.backend.entity.Category> catQuery =
                new com.baomidou.mybatisplus.core.conditions.query.QueryWrapper<>();
        catQuery.eq("name", "目标").eq("type", 2).last("LIMIT 1");
        com.moneyday.backend.entity.Category targetCategory = categoryMapper.selectOne(catQuery);

        com.moneyday.backend.entity.Transaction t = new com.moneyday.backend.entity.Transaction();
        t.setType(2); // 支出
        t.setAmount(target.getTargetAmount());
        t.setTransactionDate(LocalDate.now());
        t.setAccountId(accountId);
        if (targetCategory != null) {
            t.setCategoryId(targetCategory.getId());
        }
        t.setRemark("实现目标：" + target.getName());
        transactionService.addTransaction(t);
    }

    @Override
    @Transactional
    public void unrealizeTarget(Long id) {
        Target target = guard.require(targetMapper,id);
        if (target == null || target.getIsRealized() == null || target.getIsRealized() == 0) {
            throw new com.moneyday.backend.common.ApiException(400, "目标不存在或尚未实现");
        }

        target.setIsRealized(0);
        targetMapper.updateById(target);

        // 寻找并删除生成的扣款流水（自动回滚账户余额）
        com.baomidou.mybatisplus.core.conditions.query.QueryWrapper<com.moneyday.backend.entity.Transaction> txQuery =
                new com.baomidou.mybatisplus.core.conditions.query.QueryWrapper<>();
        txQuery.eq("type", 2)
                .eq("remark", "实现目标：" + target.getName())
                .orderByDesc("id")
                .last("LIMIT 1");
        com.moneyday.backend.entity.Transaction tx = transactionMapper.selectOne(txQuery);
        if (tx != null) {
            transactionService.deleteTransaction(tx.getId());
        }
    }
}
