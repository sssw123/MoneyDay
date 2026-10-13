package com.moneyday.backend.service;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.moneyday.backend.entity.CycleRecord;
import com.moneyday.backend.entity.CycleTemplate;
import com.moneyday.backend.entity.Wishlist;
import com.moneyday.backend.mapper.CycleRecordMapper;
import com.moneyday.backend.mapper.CycleTemplateMapper;
import com.moneyday.backend.mapper.StatMapper;
import com.moneyday.backend.mapper.WishlistMapper;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.context.event.ApplicationReadyEvent;
import org.springframework.context.event.EventListener;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;

@Service
public class ScheduleTaskService {

    private static final Logger log = LoggerFactory.getLogger(ScheduleTaskService.class);

    @Autowired
    private CycleRecordService cycleRecordService;

    @Autowired
    private CycleRecordMapper cycleRecordMapper;

    @Autowired
    private CycleTemplateMapper cycleTemplateMapper;

    @Autowired
    private LiabilityService liabilityService;

    @Autowired
    private WishlistMapper wishlistMapper;

    @Autowired
    private StatMapper statMapper;

    @Autowired
    private TodoService todoService;

    /**
     * 开机自检补偿：后端启动完毕后静默执行一次完整自检
     */
    @EventListener(ApplicationReadyEvent.class)
    public void onApplicationReady() {
        log.info("MoneyDay 后端启动完成，开始执行开机自检补偿任务...");
        try {
            executeAllChecks();
            log.info("MoneyDay 开机自检补偿任务执行成功。");
        } catch (Exception e) {
            log.error("MoneyDay 开机自检补偿任务执行异常: ", e);
        }
    }

    /**
     * 每日凌晨 00:05 自动执行巡检
     */
    @Scheduled(cron = "0 5 0 * * ?")
    public void scheduledDailyCheck() {
        log.info("MoneyDay 开始执行每日定时巡检作业...");
        try {
            executeAllChecks();
            log.info("MoneyDay 每日定时巡检作业执行成功。");
        } catch (Exception e) {
            log.error("MoneyDay 每日定时巡检作业执行异常: ", e);
        }
    }

    /**
     * 统一调度三大核心作业
     */
    public synchronized void executeAllChecks() {
        checkAndRollCycle();
        checkAndExecuteLiabilityRepayments();
        checkWishlistMilestones();
    }

    /**
     * 作业 1: 周期自动滚动巡检
     */
    public void checkAndRollCycle() {
        try {
            CycleTemplate defaultTemplate = cycleTemplateMapper.findDefault();
            if (defaultTemplate == null) return;

            int startDay = defaultTemplate.getStartDay() != null ? defaultTemplate.getStartDay() : 1;
            LocalDate today = LocalDate.now();
            int actualStartDay = Math.min(startDay, today.lengthOfMonth());
            LocalDate currentStartDate;
            if (today.getDayOfMonth() >= actualStartDay) {
                currentStartDate = today.withDayOfMonth(actualStartDay);
            } else {
                LocalDate lastMonth = today.minusMonths(1);
                currentStartDate = lastMonth.withDayOfMonth(Math.min(startDay, lastMonth.lengthOfMonth()));
            }
            LocalDate nextMonth = currentStartDate.plusMonths(1);
            LocalDate currentEndDate = nextMonth.withDayOfMonth(Math.min(startDay, nextMonth.lengthOfMonth())).minusDays(1);

            QueryWrapper<CycleRecord> query = new QueryWrapper<>();
            query.eq("cycle_start_date", currentStartDate).eq("cycle_end_date", currentEndDate).last("LIMIT 1");
            CycleRecord record = cycleRecordMapper.selectOne(query);
            if (record == null) {
                log.info("检测到跨入新账单周期 [{} 至 {}]，正在自动生成新周期快照...", currentStartDate, currentEndDate);
                record = cycleRecordService.getOrCreateSnapshot(currentStartDate, currentEndDate);
                if (record.getFixedItems() != null && !record.getFixedItems().isEmpty()) {
                    long pendingItemsCount = record.getFixedItems().stream()
                            .filter(item -> !"DEPOSIT".equals(item.getType()))
                            .count();
                    if (pendingItemsCount > 0) {
                        String title = "【新周期账单提醒】" + currentStartDate + " 至 " + currentEndDate;
                        String content = "新周期已开启，共有 " + pendingItemsCount + " 笔固定收支待确认，请前往周期预算表核对。";
                        todoService.createTodoIfNotExists("CYCLE_FIXED_ITEMS", title, content, String.valueOf(record.getId()));
                    }
                }
            }
        } catch (Exception e) {
            log.error("周期自动滚动巡检异常: ", e);
        }
    }

    /**
     * 作业 2: 分期智能到期扣款与逾期待办巡检
     */
    public void checkAndExecuteLiabilityRepayments() {
        try {
            liabilityService.checkAndExecuteDueRepayments();
        } catch (Exception e) {
            log.error("分期智能到期扣款巡检异常: ", e);
        }
    }

    /**
     * 作业 3: 心愿达成巡检
     */
    public void checkWishlistMilestones() {
        try {
            BigDecimal cumulativeBalance = cycleRecordService.getTotalCumulativeBalance();
            if (cumulativeBalance == null) cumulativeBalance = BigDecimal.ZERO;

            List<Wishlist> unfulfilled = wishlistMapper.selectList(new QueryWrapper<Wishlist>().eq("is_realized", 0));
            for (Wishlist w : unfulfilled) {
                if (w.getTargetAmount() != null && cumulativeBalance.compareTo(w.getTargetAmount()) >= 0) {
                    String title = "【心愿达成提醒】" + w.getName();
                    String content = String.format("累计结余已达 ¥%s，已覆盖心愿所需 ¥%s，可随时兑现！",
                            cumulativeBalance, w.getTargetAmount());
                    todoService.createTodoIfNotExists("WISHLIST_REACHED", title, content, String.valueOf(w.getId()));
                }
            }
        } catch (Exception e) {
            log.error("心愿达成巡检异常: ", e);
        }
    }
}
