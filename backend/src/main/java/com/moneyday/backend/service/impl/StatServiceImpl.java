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

    public StatDTO getStats() {
        StatDTO dto = new StatDTO();
        dto.setTotalAssets(statMapper.getTotalAssets());
        dto.setTotalTargets(statMapper.getTotalTargets());
        dto.setTargetAllocated(statMapper.getTargetAllocated());
        dto.setIsOverdraft(dto.getTotalAssets().compareTo(dto.getTotalTargets()) < 0);

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
        dto.setCurrentBalance(dto.getCurrentIncome().subtract(dto.getCurrentExpense()));
        dto.setCategoryExpenses(statMapper.getCategoryExpensesByDate(sDate, eDate));

        return dto;
    }
}
