package com.moneyday.backend.service.impl;

import com.moneyday.backend.service.StatService;

import com.moneyday.backend.entity.CycleTemplate;
import com.moneyday.backend.entity.StatDTO;
import com.moneyday.backend.mapper.CycleTemplateMapper;
import com.moneyday.backend.mapper.StatMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;

@Service
public class StatServiceImpl implements StatService {

    @Autowired
    private StatMapper statMapper;
    
    @Autowired
    private CycleTemplateMapper templateMapper;

    @Autowired
    private com.moneyday.backend.service.CycleRecordService cycleRecordService;

    @Autowired
    private com.moneyday.backend.mapper.LiabilityMapper liabilityMapper;

    public StatDTO getStats() {
        StatDTO dto = new StatDTO();
        dto.setTotalAssets(statMapper.getTotalAssets());
        dto.setTotalTargets(statMapper.getTotalTargets());
        dto.setTargetAllocated(statMapper.getTargetAllocated());
        // 当前阶段心愿单不占预留资金，可用净资产即为总资产，不触发目标透支
        dto.setIsOverdraft(false);

        CycleTemplate defaultTemplate = templateMapper.findDefault();
        int startDay = defaultTemplate != null ? defaultTemplate.getStartDay() : 1;
        
        LocalDate today = LocalDate.now();
        LocalDate startDate;
        
        // Handle end of month logically
        int actualStartDay = Math.min(startDay, today.lengthOfMonth());
        
        if (today.getDayOfMonth() >= actualStartDay) {
            startDate = today.withDayOfMonth(actualStartDay);
        } else {
            LocalDate lastMonth = today.minusMonths(1);
            int lastMonthStartDay = Math.min(startDay, lastMonth.lengthOfMonth());
            startDate = lastMonth.withDayOfMonth(lastMonthStartDay);
        }
        
        LocalDate nextMonth = startDate.plusMonths(1);
        int nextMonthStartDay = Math.min(startDay, nextMonth.lengthOfMonth());
        LocalDate endDate = nextMonth.withDayOfMonth(nextMonthStartDay).minusDays(1);

        String sDate = startDate.format(DateTimeFormatter.ISO_LOCAL_DATE);
        String eDate = endDate.format(DateTimeFormatter.ISO_LOCAL_DATE);

        dto.setCurrentIncome(statMapper.getIncomeByDate(sDate, eDate));
        dto.setCurrentExpense(statMapper.getExpenseByDate(sDate, eDate));

        // Get fixed deposit for current cycle
        com.moneyday.backend.entity.CycleRecord record = cycleRecordService.getOrCreateSnapshot(startDate, endDate);

        BigDecimal fixedDeposit = BigDecimal.ZERO;
        if (record.getFixedItems() != null) {
            for (com.moneyday.backend.entity.FixedItem item : record.getFixedItems()) {
                if ("DEPOSIT".equals(item.getType()) && item.getAmount() != null) {
                    fixedDeposit = fixedDeposit.add(item.getAmount());
                }
            }
        }
        
        dto.setCurrentFixedDeposit(fixedDeposit);
        BigDecimal balance = dto.getCurrentIncome().subtract(fixedDeposit).subtract(dto.getCurrentExpense());
        dto.setCurrentBalance(balance);
        dto.setCurrentFinalBalance(fixedDeposit.add(balance));
        BigDecimal totalLiab = liabilityMapper.getTotalRemainingLiability();
        dto.setTotalLiabilities(totalLiab != null ? totalLiab : BigDecimal.ZERO);
        // 可用净资产 = 总资产 - 所有未结清负债待还总额
        dto.setAvailableAssets(dto.getTotalAssets().subtract(dto.getTotalLiabilities()));
        dto.setCumulativeBalance(cycleRecordService.getTotalCumulativeBalance());
        dto.setCategoryExpenses(statMapper.getCategoryExpensesByDate(sDate, eDate));

        return dto;
    }
}
