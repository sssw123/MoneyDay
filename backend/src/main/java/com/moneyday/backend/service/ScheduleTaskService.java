package com.moneyday.backend.service;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.moneyday.backend.entity.*;
import com.moneyday.backend.mapper.*;
import com.moneyday.backend.security.UserContext;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.context.event.ApplicationReadyEvent;
import org.springframework.context.event.EventListener;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;
import org.springframework.transaction.support.TransactionTemplate;
import java.math.BigDecimal;
import java.time.LocalDate;

@Service
public class ScheduleTaskService {
    private static final Logger log=LoggerFactory.getLogger(ScheduleTaskService.class);
    @Autowired private UserMapper users;
    @Autowired private CycleRecordService cycles;
    @Autowired private CycleRecordMapper records;
    @Autowired private CycleTemplateMapper templates;
    @Autowired private LiabilityService liabilities;
    @Autowired private WishlistMapper wishes;
    @Autowired private TodoService todos;
    @Autowired private org.springframework.transaction.PlatformTransactionManager manager;
    @EventListener(ApplicationReadyEvent.class)
    public void onApplicationReady() {executeAllChecks();}
    @Scheduled(cron="0 5 0 * * ?",zone="Asia/Shanghai")
    public void scheduledDailyCheck() {executeAllChecks();}
    public synchronized void executeAllChecks() {
        for(User user:users.selectList(new QueryWrapper<User>().eq("status","ACTIVE"))) {
            try {
                UserContext.call(user.getId(),()->new TransactionTemplate(manager).execute(status->{
                    User fresh=users.lockById(user.getId());
                    if(fresh==null || !"ACTIVE".equals(fresh.getStatus())) return null;
                    checkAndRollCycle();checkAndExecuteLiabilityRepayments();checkWishlistMilestones();return null;
                }));
            } catch(Exception e) {log.error("用户 {} 巡检失败: {}",user.getId(),e.getClass().getSimpleName());}
        }
    }
    public void checkAndRollCycle() {
        UserContext.requireId();
        CycleTemplate template=templates.findDefault();if(template==null)return;
        int start=template.getStartDay()==null?1:template.getStartDay();
        LocalDate today=LocalDate.now();
        LocalDate month=today.getDayOfMonth()>=Math.min(start,today.lengthOfMonth())?today:today.minusMonths(1);
        LocalDate begin=month.withDayOfMonth(Math.min(start,month.lengthOfMonth()));
        LocalDate next=begin.plusMonths(1);
        LocalDate end=next.withDayOfMonth(Math.min(start,next.lengthOfMonth())).minusDays(1);
        CycleRecord record=records.selectOne(new QueryWrapper<CycleRecord>().eq("cycle_start_date",begin).eq("cycle_end_date",end).last("LIMIT 1"));
        if(record!=null)return;
        record=cycles.getOrCreateSnapshot(begin,end);
        if(record.getFixedItems()!=null) {
            long count=record.getFixedItems().stream().filter(i->!"DEPOSIT".equals(i.getType())).count();
            if(count>0) todos.createTodoIfNotExists("CYCLE_FIXED_ITEMS","【新周期账单提醒】"+begin+" 至 "+end,"新周期已开启，共有 "+count+" 笔固定收支待确认，请前往周期预算表核对。",String.valueOf(record.getId()));
        }
    }
    public void checkAndExecuteLiabilityRepayments() {UserContext.requireId();liabilities.checkAndExecuteDueRepayments();}
    public void checkWishlistMilestones() {
        UserContext.requireId();
        BigDecimal balance=cycles.getTotalCumulativeBalance();if(balance==null)balance=BigDecimal.ZERO;
        for(Wishlist wish:wishes.selectList(new QueryWrapper<Wishlist>().eq("is_realized",0))) {
            if(wish.getTargetAmount()!=null && balance.compareTo(wish.getTargetAmount())>=0)
                todos.createTodoIfNotExists("WISHLIST_REACHED","【心愿达成提醒】"+wish.getName(),String.format("累计结余已达 ¥%s，已覆盖心愿所需 ¥%s，可随时兑现！",balance,wish.getTargetAmount()),String.valueOf(wish.getId()));
        }
    }
}
