package com.moneyday.backend.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.moneyday.backend.entity.Account;
import com.moneyday.backend.entity.CycleRecord;
import com.moneyday.backend.entity.CycleTemplate;
import com.moneyday.backend.entity.Transaction;
import com.moneyday.backend.mapper.AccountMapper;
import com.moneyday.backend.mapper.CycleRecordMapper;
import com.moneyday.backend.mapper.CycleTemplateMapper;
import com.moneyday.backend.mapper.StatMapper;
import com.moneyday.backend.mapper.TransactionMapper;
import com.moneyday.backend.service.CycleRecordService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Service
public class CycleRecordServiceImpl implements CycleRecordService {

    @Autowired private CycleRecordMapper cycleRecordMapper;
    @Autowired private CycleTemplateMapper cycleTemplateMapper;
    @Autowired private StatMapper statMapper;
    @Autowired private TransactionMapper transactionMapper;
    @Autowired private AccountMapper accountMapper;

    @Override
    public CycleRecord getOrCreateSnapshot(LocalDate cycleStartDate, LocalDate cycleEndDate) {
        QueryWrapper<CycleRecord> query = new QueryWrapper<>();
        query.eq("cycle_start_date", cycleStartDate).eq("cycle_end_date", cycleEndDate).last("LIMIT 1");
        CycleRecord record = cycleRecordMapper.selectOne(query);
        if (record != null) return record;

        CycleTemplate template = cycleTemplateMapper.findDefault();
        BigDecimal defaultDeposit = (template != null && template.getDefaultFixedDeposit() != null)
                ? template.getDefaultFixedDeposit() : BigDecimal.ZERO;
        BigDecimal defaultIncome = (template != null && template.getDefaultFixedIncome() != null)
                ? template.getDefaultFixedIncome() : BigDecimal.ZERO;

        record = new CycleRecord();
        record.setCycleStartDate(cycleStartDate);
        record.setCycleEndDate(cycleEndDate);
        record.setFixedDeposit(defaultDeposit);
        record.setFixedIncome(defaultIncome);
        record.setIsFixedIncomeBooked(0);
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

    @Override
    @Transactional
    public Map<String, Object> bookIncome(Long id, Long accountId, BigDecimal amount, String date) {
        CycleRecord record = cycleRecordMapper.selectById(id);
        if (record == null) throw new IllegalArgumentException("周期记录不存在");
        if (record.getIsFixedIncomeBooked() != null && record.getIsFixedIncomeBooked() == 1) {
            throw new IllegalArgumentException("该周期固收已到账，不可重复操作");
        }

        // 生成真实收入交易
        Transaction tx = new Transaction();
        tx.setType(1);
        tx.setAmount(amount);
        tx.setAccountId(accountId);
        tx.setTransactionDate(LocalDate.parse(date));
        tx.setRemark("周期固收到账");
        transactionMapper.insert(tx);

        // 更新账户余额
        Account account = accountMapper.selectById(accountId);
        if (account != null) {
            account.setCurrentBalance(account.getCurrentBalance().add(amount));
            accountMapper.updateById(account);
        }

        // 更新快照
        record.setFixedIncome(amount);
        record.setIsFixedIncomeBooked(1);
        cycleRecordMapper.updateById(record);

        Map<String, Object> result = new HashMap<>();
        result.put("id", record.getId());
        result.put("fixedIncome", amount);
        result.put("isFixedIncomeBooked", 1);
        return result;
    }

    @Override
    public List<Map<String, Object>> getRecentCycles(int months) {
        List<Map<String, Object>> list = new ArrayList<>();

        CycleTemplate template = cycleTemplateMapper.findDefault();
        int startDay = (template != null && template.getStartDay() != null) ? template.getStartDay() : 1;

        LocalDate today = LocalDate.now();
        int actualStartDay = Math.min(startDay, today.lengthOfMonth());
        LocalDate currentStartDate;

        if (today.getDayOfMonth() >= actualStartDay) {
            currentStartDate = today.withDayOfMonth(actualStartDay);
        } else {
            LocalDate lastMonth = today.minusMonths(1);
            currentStartDate = lastMonth.withDayOfMonth(Math.min(startDay, lastMonth.lengthOfMonth()));
        }

        for (int i = 0; i < months; i++) {
            LocalDate sDate = currentStartDate.minusMonths(i);
            sDate = sDate.withDayOfMonth(Math.min(startDay, sDate.lengthOfMonth()));
            LocalDate nextMonth = sDate.plusMonths(1);
            LocalDate eDate = nextMonth.withDayOfMonth(Math.min(startDay, nextMonth.lengthOfMonth())).minusDays(1);

            CycleRecord record = getOrCreateSnapshot(sDate, eDate);

            String sDateStr = sDate.format(DateTimeFormatter.ISO_LOCAL_DATE);
            String eDateStr = eDate.format(DateTimeFormatter.ISO_LOCAL_DATE);

            BigDecimal income = statMapper.getIncomeByDate(sDateStr, eDateStr);
            if (income == null) income = BigDecimal.ZERO;
            BigDecimal expense = statMapper.getExpenseByDate(sDateStr, eDateStr);
            if (expense == null) expense = BigDecimal.ZERO;

            BigDecimal fixedDeposit = record.getFixedDeposit() != null ? record.getFixedDeposit() : BigDecimal.ZERO;
            BigDecimal fixedIncome = record.getFixedIncome() != null ? record.getFixedIncome() : BigDecimal.ZERO;
            BigDecimal balance = income.subtract(fixedDeposit).subtract(expense);

            Map<String, Object> map = new HashMap<>();
            map.put("id", record.getId());
            map.put("cycleStartDate", sDateStr);
            map.put("cycleEndDate", eDateStr);
            map.put("income", income);
            map.put("expense", expense);
            map.put("fixedDeposit", fixedDeposit);
            map.put("fixedIncome", fixedIncome);
            map.put("isFixedIncomeBooked", record.getIsFixedIncomeBooked() != null ? record.getIsFixedIncomeBooked() : 0);
            map.put("balance", balance);
            list.add(map);
        }
        return list;
    }
}

