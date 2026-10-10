package com.moneyday.backend.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.moneyday.backend.entity.CycleRecord;
import com.moneyday.backend.entity.CycleTemplate;
import com.moneyday.backend.mapper.CycleRecordMapper;
import com.moneyday.backend.mapper.CycleTemplateMapper;
import com.moneyday.backend.service.CycleRecordService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.time.LocalDate;

@Service
public class CycleRecordServiceImpl implements CycleRecordService {

    @Autowired
    private CycleRecordMapper cycleRecordMapper;

    @Autowired
    private CycleTemplateMapper cycleTemplateMapper;

    @Override
    public CycleRecord getOrCreateSnapshot(LocalDate cycleStartDate, LocalDate cycleEndDate) {
        QueryWrapper<CycleRecord> query = new QueryWrapper<>();
        query.eq("cycle_start_date", cycleStartDate).eq("cycle_end_date", cycleEndDate).last("LIMIT 1");
        CycleRecord record = cycleRecordMapper.selectOne(query);
        if (record != null) {
            return record;
        }

        // Get default fixed deposit from template
        CycleTemplate template = cycleTemplateMapper.findDefault();
        BigDecimal defaultAmount = (template != null && template.getDefaultFixedDeposit() != null) 
            ? template.getDefaultFixedDeposit() : BigDecimal.ZERO;

        record = new CycleRecord();
        record.setCycleStartDate(cycleStartDate);
        record.setCycleEndDate(cycleEndDate);
        record.setFixedDeposit(defaultAmount);
        cycleRecordMapper.insert(record);
        return record;
    }

    @Override
    public CycleRecord updateFixedDeposit(Long id, BigDecimal newAmount) {
        CycleRecord record = cycleRecordMapper.selectById(id);
        if (record != null) {
            record.setFixedDeposit(newAmount);
            cycleRecordMapper.updateById(record);
        }
        return record;
    }

    @Autowired
    private com.moneyday.backend.mapper.StatMapper statMapper;

    @Override
    public java.util.List<java.util.Map<String, Object>> getRecentCycles(int months) {
        java.util.List<java.util.Map<String, Object>> list = new java.util.ArrayList<>();
        
        // Find default start day
        CycleTemplate template = cycleTemplateMapper.findDefault();
        int startDay = (template != null && template.getStartDay() != null) ? template.getStartDay() : 1;

        LocalDate today = LocalDate.now();
        int actualStartDay = Math.min(startDay, today.lengthOfMonth());
        LocalDate currentStartDate;
        
        if (today.getDayOfMonth() >= actualStartDay) {
            currentStartDate = today.withDayOfMonth(actualStartDay);
        } else {
            LocalDate lastMonth = today.minusMonths(1);
            int lastMonthStartDay = Math.min(startDay, lastMonth.lengthOfMonth());
            currentStartDate = lastMonth.withDayOfMonth(lastMonthStartDay);
        }

        for (int i = 0; i < months; i++) {
            LocalDate sDate = currentStartDate.minusMonths(i);
            int sDay = Math.min(startDay, sDate.lengthOfMonth());
            sDate = sDate.withDayOfMonth(sDay);

            LocalDate nextMonth = sDate.plusMonths(1);
            int nDay = Math.min(startDay, nextMonth.lengthOfMonth());
            LocalDate eDate = nextMonth.withDayOfMonth(nDay).minusDays(1);

            CycleRecord record = getOrCreateSnapshot(sDate, eDate);

            String sDateStr = sDate.format(java.time.format.DateTimeFormatter.ISO_LOCAL_DATE);
            String eDateStr = eDate.format(java.time.format.DateTimeFormatter.ISO_LOCAL_DATE);

            BigDecimal income = statMapper.getIncomeByDate(sDateStr, eDateStr);
            if (income == null) income = BigDecimal.ZERO;
            BigDecimal expense = statMapper.getExpenseByDate(sDateStr, eDateStr);
            if (expense == null) expense = BigDecimal.ZERO;

            BigDecimal fixedDeposit = record.getFixedDeposit() != null ? record.getFixedDeposit() : BigDecimal.ZERO;
            BigDecimal balance = income.subtract(fixedDeposit).subtract(expense);

            java.util.Map<String, Object> map = new java.util.HashMap<>();
            map.put("id", record.getId());
            map.put("cycleStartDate", sDateStr);
            map.put("cycleEndDate", eDateStr);
            map.put("income", income);
            map.put("expense", expense);
            map.put("fixedDeposit", fixedDeposit);
            map.put("balance", balance);
            
            list.add(map);
        }
        return list;
    }
}
