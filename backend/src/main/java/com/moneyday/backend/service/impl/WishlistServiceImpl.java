package com.moneyday.backend.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.moneyday.backend.entity.*;
import com.moneyday.backend.mapper.*;
import com.moneyday.backend.service.CycleRecordService;
import com.moneyday.backend.service.TransactionService;
import com.moneyday.backend.service.WishlistService;
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
public class WishlistServiceImpl implements WishlistService {

    @Autowired
    private WishlistMapper wishlistMapper;

    @Autowired
    private CycleRecordService cycleRecordService;

    @Autowired
    private CycleTemplateMapper cycleTemplateMapper;

    @Autowired
    private AccountMapper accountMapper;

    @Autowired
    private CategoryMapper categoryMapper;

    @Autowired
    private TransactionMapper transactionMapper;

    @Autowired
    private TransactionService transactionService;

    @Autowired
    @org.springframework.context.annotation.Lazy
    private com.moneyday.backend.service.TodoService todoService;

    @Override
    public List<WishlistVO> getAllWishlists() {
        List<Wishlist> list = wishlistMapper.selectList(null);
        if (list == null || list.isEmpty()) {
            return new ArrayList<>();
        }

        // 1. 获取全局累计结余
        BigDecimal cumulativeBalance = cycleRecordService.getTotalCumulativeBalance();
        if (cumulativeBalance == null) {
            cumulativeBalance = BigDecimal.ZERO;
        }

        // 2. 计算历史已结算周期的平均实际结余
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

        // 3. 解析默认周期模板中的基准预算 (固收 - 固支 - 固存)
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
        BigDecimal templateBaselineBalance = templateFixedIncome.subtract(templateFixedExpense).subtract(templateFixedDeposit);

        // 4. 当前周期起算日
        int actualStartDay = Math.min(startDay, today.lengthOfMonth());
        LocalDate currentStartDate;
        if (today.getDayOfMonth() >= actualStartDay) {
            currentStartDate = today.withDayOfMonth(actualStartDay);
        } else {
            LocalDate lastMonth = today.minusMonths(1);
            currentStartDate = lastMonth.withDayOfMonth(Math.min(startDay, lastMonth.lengthOfMonth()));
        }

        // 5. 组装 VO 与预计达成时间测算
        List<WishlistVO> voList = new ArrayList<>();
        for (Wishlist item : list) {
            WishlistVO vo = new WishlistVO();
            BeanUtils.copyProperties(item, vo);
            vo.setAvailableFunds(cumulativeBalance);

            BigDecimal targetAmount = vo.getTargetAmount() != null ? vo.getTargetAmount() : BigDecimal.ZERO;

            if (vo.getIsRealized() != null && vo.getIsRealized() == 1) {
                vo.setProgress(100);
                vo.setEstimatedCompletionDate("-");
                vo.setIsEstimatedFallback(false);
                vo.setEstimatedReason("心愿已实现");
                vo.setGap(BigDecimal.ZERO);
                voList.add(vo);
                continue;
            }

            // 计算结余进度
            if (targetAmount.compareTo(BigDecimal.ZERO) <= 0) {
                vo.setProgress(100);
                vo.setGap(BigDecimal.ZERO);
            } else if (cumulativeBalance.compareTo(BigDecimal.ZERO) <= 0) {
                vo.setProgress(0);
                vo.setGap(targetAmount);
            } else if (cumulativeBalance.compareTo(targetAmount) >= 0) {
                vo.setProgress(100);
                vo.setGap(BigDecimal.ZERO);
            } else {
                int progress = cumulativeBalance.multiply(BigDecimal.valueOf(100))
                        .divide(targetAmount, 0, RoundingMode.HALF_UP).intValue();
                vo.setProgress(Math.min(99, Math.max(0, progress)));
                vo.setGap(targetAmount.subtract(cumulativeBalance));
            }

            // 测算预计达成时间
            if (vo.getGap() == null || vo.getGap().compareTo(BigDecimal.ZERO) <= 0) {
                vo.setEstimatedCompletionDate("当前可实现");
                vo.setIsEstimatedFallback(false);
                vo.setEstimatedReason("当前累计结余已达到心愿金额，随时可兑现");
            } else {
                BigDecimal speed;
                boolean isFallback = false;
                String reason;

                if (avgHistoricalBalance != null && avgHistoricalBalance.compareTo(BigDecimal.ZERO) > 0) {
                    speed = avgHistoricalBalance;
                    reason = String.format("按过去历史平均周期结余 (¥%.2f/周期) 推算", speed.doubleValue());
                } else {
                    isFallback = true;
                    if (templateBaselineBalance.compareTo(BigDecimal.ZERO) > 0) {
                        speed = templateBaselineBalance;
                        String prefix = (avgHistoricalBalance == null || avgHistoricalBalance.compareTo(BigDecimal.ZERO) == 0)
                                ? "暂无充足历史周期盈余，假定严格执行模板预算"
                                : "历史周期平均结余无盈余，假定严格执行模板预算";
                        reason = String.format("%s (¥%.2f/周期) 推算", prefix, speed.doubleValue());
                    } else {
                        speed = BigDecimal.ZERO;
                        reason = "历史结余与模板预算结余均无正向盈余，无法预估达成时间";
                    }
                }

                vo.setIsEstimatedFallback(isFallback);
                vo.setEstimatedReason(reason);

                if (speed.compareTo(BigDecimal.ZERO) <= 0) {
                    vo.setEstimatedCompletionDate("无法预估");
                } else {
                    int periodsNeeded = vo.getGap().divide(speed, 0, RoundingMode.CEILING).intValue();
                    LocalDate targetPeriodStart = currentStartDate.plusMonths(periodsNeeded);
                    int targetStartDay = Math.min(startDay, targetPeriodStart.lengthOfMonth());
                    LocalDate targetPeriodStartDate = targetPeriodStart.withDayOfMonth(targetStartDay);
                    LocalDate nextMonthDate = targetPeriodStartDate.plusMonths(1);
                    int nextMonthStartDay = Math.min(startDay, nextMonthDate.lengthOfMonth());
                    LocalDate targetPeriodEndDate = nextMonthDate.withDayOfMonth(nextMonthStartDay).minusDays(1);

                    vo.setEstimatedCompletionDate(targetPeriodEndDate.format(DateTimeFormatter.ISO_LOCAL_DATE));
                }
            }
            voList.add(vo);
        }

        return voList;
    }

    @Override
    public Wishlist addWishlist(Wishlist wishlist) {
        if (wishlist.getStartDate() == null) {
            wishlist.setStartDate(LocalDate.now());
        }
        if (wishlist.getIsRealized() == null) {
            wishlist.setIsRealized(0);
        }
        wishlistMapper.insert(wishlist);
        return wishlist;
    }

    @Override
    public Wishlist updateWishlist(Wishlist wishlist) {
        wishlistMapper.updateById(wishlist);
        return wishlist;
    }

    @Override
    public void deleteWishlist(Long id) {
        wishlistMapper.deleteById(id);
    }

    @Override
    @Transactional
    public void realizeWishlist(Long id, Long accountId) {
        Wishlist item = wishlistMapper.selectById(id);
        if (item == null || (item.getIsRealized() != null && item.getIsRealized() == 1)) {
            throw new RuntimeException("心愿不存在或已实现");
        }

        Account account = accountMapper.selectById(accountId);
        if (account == null) {
            throw new IllegalArgumentException("扣款账户不存在");
        }
        if (account.getCurrentBalance().compareTo(item.getTargetAmount()) < 0) {
            throw new IllegalArgumentException("扣款账户余额不足！当前账户余额: ¥" + account.getCurrentBalance() + "，心愿需: ¥" + item.getTargetAmount());
        }

        item.setIsRealized(1);
        wishlistMapper.updateById(item);

        QueryWrapper<Category> catQuery = new QueryWrapper<>();
        catQuery.eq("name", "目标").eq("type", 2).last("LIMIT 1");
        Category targetCategory = categoryMapper.selectOne(catQuery);
        Long categoryId = targetCategory != null ? targetCategory.getId() : null;

        Transaction tx = new Transaction();
        tx.setType(2); // 支出
        tx.setAmount(item.getTargetAmount());
        tx.setTransactionDate(LocalDate.now());
        tx.setAccountId(accountId);
        tx.setCategoryId(categoryId);
        tx.setRemark("【心愿实现】" + item.getName());

        transactionService.addTransaction(tx);

        if (todoService != null) {
            todoService.resolveTodoByBiz("WISHLIST_REACHED", String.valueOf(item.getId()));
        }
    }

    @Override
    @Transactional
    public void unrealizeWishlist(Long id) {
        Wishlist item = wishlistMapper.selectById(id);
        if (item == null || item.getIsRealized() == null || item.getIsRealized() == 0) {
            throw new RuntimeException("心愿未处于已实现状态");
        }

        String targetRemark = "【心愿实现】" + item.getName();
        QueryWrapper<Transaction> txQuery = new QueryWrapper<>();
        txQuery.eq("type", 2)
                .eq("amount", item.getTargetAmount())
                .eq("remark", targetRemark)
                .orderByDesc("created_at")
                .last("LIMIT 1");
        Transaction tx = transactionMapper.selectOne(txQuery);

        if (tx != null) {
            transactionService.deleteTransaction(tx.getId());
        }

        item.setIsRealized(0);
        wishlistMapper.updateById(item);
    }
}
