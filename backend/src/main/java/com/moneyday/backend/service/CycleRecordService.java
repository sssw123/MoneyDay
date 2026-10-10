package com.moneyday.backend.service;

import com.moneyday.backend.entity.CycleRecord;
import java.time.LocalDate;

public interface CycleRecordService {
    CycleRecord getOrCreateSnapshot(LocalDate cycleStartDate, LocalDate cycleEndDate);
    CycleRecord updateFixedDeposit(Long id, java.math.BigDecimal newAmount);
    java.util.List<java.util.Map<String, Object>> getRecentCycles(int months);
    java.util.Map<String, Object> bookIncome(Long id, Long accountId, java.math.BigDecimal amount, String date);
    java.util.Map<String, Object> bookItem(Long recordId, String itemId, Long accountId, java.math.BigDecimal amount, String date);
    java.util.Map<String, Object> unbookItem(Long recordId, String itemId);
    java.math.BigDecimal getTotalCumulativeBalance();
}
