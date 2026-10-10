package com.moneyday.backend.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.moneyday.backend.entity.Account;
import com.moneyday.backend.entity.CycleRecord;
import com.moneyday.backend.entity.CycleTemplate;
import com.moneyday.backend.entity.FixedItem;
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
import java.util.UUID;

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
        List<FixedItem> items = new ArrayList<>();
        if (template != null && template.getFixedItems() != null) {
            for (FixedItem tplItem : template.getFixedItems()) {
                FixedItem newItem = new FixedItem();
                newItem.setId(tplItem.getId() != null ? tplItem.getId() : UUID.randomUUID().toString());
                newItem.setName(tplItem.getName());
                newItem.setType(tplItem.getType());
                newItem.setAmount(tplItem.getAmount());
                newItem.setCategoryId(tplItem.getCategoryId());
                newItem.setCategoryName(tplItem.getCategoryName());
                newItem.setIsBooked(false);
                items.add(newItem);
            }
        }

        record = new CycleRecord();
        record.setCycleStartDate(cycleStartDate);
        record.setCycleEndDate(cycleEndDate);
        record.setFixedItems(items);
        cycleRecordMapper.insert(record);
        return record;
    }

    @Override
    public CycleRecord updateFixedDeposit(Long id, BigDecimal newAmount) {
        // Obsolete, left empty or throw
        throw new UnsupportedOperationException("Obsolete method");
    }

    @Override
    @Transactional
    public Map<String, Object> bookIncome(Long id, Long accountId, BigDecimal amount, String date) {
        // Obsolete, replaced by bookItem
        throw new UnsupportedOperationException("Obsolete method");
    }

    @Transactional
    public Map<String, Object> bookItem(Long recordId, String itemId, Long accountId, BigDecimal amount, String date) {
        CycleRecord record = cycleRecordMapper.selectById(recordId);
        if (record == null || record.getFixedItems() == null) throw new IllegalArgumentException("周期记录不存在");

        FixedItem targetItem = null;
        for (FixedItem item : record.getFixedItems()) {
            if (itemId.equals(item.getId())) {
                targetItem = item;
                break;
            }
        }
        if (targetItem == null) throw new IllegalArgumentException("明细项不存在");
        if (Boolean.TRUE.equals(targetItem.getIsBooked())) {
            throw new IllegalArgumentException("该项目已操作，不可重复记账");
        }
        if ("DEPOSIT".equals(targetItem.getType())) {
            throw new IllegalArgumentException("固存不需要记账操作");
        }

        // 生成真实交易
        Transaction tx = new Transaction();
        tx.setType("INCOME".equals(targetItem.getType()) ? 1 : 2);
        tx.setAmount(amount);
        tx.setAccountId(accountId);
        tx.setCategoryId(targetItem.getCategoryId());
        tx.setTransactionDate(LocalDate.parse(date));
        tx.setRemark("周期项目确认：" + targetItem.getName());
        transactionMapper.insert(tx);

        // 更新账户余额
        Account account = accountMapper.selectById(accountId);
        if (account != null) {
            BigDecimal diff = "INCOME".equals(targetItem.getType()) ? amount : amount.negate();
            account.setCurrentBalance(account.getCurrentBalance().add(diff));
            accountMapper.updateById(account);
        }

        // 更新快照
        targetItem.setAmount(amount); // update to actual amount
        targetItem.setIsBooked(true);
        targetItem.setTransactionId(tx.getId());
        cycleRecordMapper.updateById(record);

        Map<String, Object> result = new HashMap<>();
        result.put("id", record.getId());
        result.put("fixedItems", record.getFixedItems());
        return result;
    }

    @Override
    @Transactional
    public Map<String, Object> unbookItem(Long recordId, String itemId) {
        CycleRecord record = cycleRecordMapper.selectById(recordId);
        if (record == null || record.getFixedItems() == null) throw new IllegalArgumentException("周期记录不存在");

        FixedItem targetItem = null;
        for (FixedItem item : record.getFixedItems()) {
            if (itemId.equals(item.getId())) {
                targetItem = item;
                break;
            }
        }
        if (targetItem == null) throw new IllegalArgumentException("明细项不存在");

        if (targetItem.getTransactionId() != null) {
            Transaction tx = transactionMapper.selectById(targetItem.getTransactionId());
            if (tx != null) {
                // 回滚账户余额
                Account account = accountMapper.selectById(tx.getAccountId());
                if (account != null) {
                    BigDecimal revertDiff = tx.getType() == 1 ? tx.getAmount().negate() : tx.getAmount();
                    account.setCurrentBalance(account.getCurrentBalance().add(revertDiff));
                    accountMapper.updateById(account);
                }
                transactionMapper.deleteById(tx.getId());
            }
        }

        targetItem.setIsBooked(false);
        targetItem.setTransactionId(null);
        cycleRecordMapper.updateById(record);

        Map<String, Object> result = new HashMap<>();
        result.put("id", record.getId());
        result.put("fixedItems", record.getFixedItems());
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

            // 动态联动验证：如果标记为已完成，但对应流水不存在或已被删除，自动恢复未完成！
            boolean needUpdateRecord = false;
            if (record.getFixedItems() != null) {
                for (FixedItem item : record.getFixedItems()) {
                    if (Boolean.TRUE.equals(item.getIsBooked())) {
                        if (item.getTransactionId() != null) {
                            Transaction tx = transactionMapper.selectById(item.getTransactionId());
                            if (tx == null) {
                                item.setIsBooked(false);
                                item.setTransactionId(null);
                                needUpdateRecord = true;
                            }
                        } else {
                            // 兼容旧数据：检查周期内是否存在该流水的备注
                            QueryWrapper<Transaction> txQuery = new QueryWrapper<>();
                            txQuery.eq("remark", "周期项目确认：" + item.getName())
                                   .ge("transaction_date", sDate)
                                   .le("transaction_date", eDate)
                                   .last("LIMIT 1");
                            Transaction tx = transactionMapper.selectOne(txQuery);
                            if (tx != null) {
                                item.setTransactionId(tx.getId());
                                needUpdateRecord = true;
                            } else {
                                // 流水表中不存在任何对应记录，自动重置为未完成
                                item.setIsBooked(false);
                                needUpdateRecord = true;
                            }
                        }
                    }
                }
            }
            if (needUpdateRecord) {
                cycleRecordMapper.updateById(record);
            }

            BigDecimal income = statMapper.getIncomeByDate(sDateStr, eDateStr);
            if (income == null) income = BigDecimal.ZERO;
            BigDecimal expense = statMapper.getExpenseByDate(sDateStr, eDateStr);
            if (expense == null) expense = BigDecimal.ZERO;

            BigDecimal depositSum = BigDecimal.ZERO;
            if (record.getFixedItems() != null) {
                for (FixedItem item : record.getFixedItems()) {
                    if ("DEPOSIT".equals(item.getType()) && item.getAmount() != null) {
                        depositSum = depositSum.add(item.getAmount());
                    }
                }
            }
            
            BigDecimal balance = income.subtract(expense).subtract(depositSum);

            Map<String, Object> map = new HashMap<>();
            map.put("id", record.getId());
            map.put("cycleStartDate", sDateStr);
            map.put("cycleEndDate", eDateStr);
            map.put("income", income);
            map.put("expense", expense);
            map.put("fixedItems", record.getFixedItems());
            map.put("balance", balance);
            list.add(map);
        }
        return list;
    }

    @Override
    public BigDecimal getTotalCumulativeBalance() {
        List<Map<String, Object>> cycles = getRecentCycles(12);
        BigDecimal total = BigDecimal.ZERO;
        if (cycles != null) {
            for (Map<String, Object> c : cycles) {
                Object b = c.get("balance");
                if (b instanceof BigDecimal) {
                    total = total.add((BigDecimal) b);
                } else if (b != null) {
                    total = total.add(new BigDecimal(b.toString()));
                }
            }
        }
        return total;
    }
}
