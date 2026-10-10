package com.moneyday.backend.service;

import com.moneyday.backend.entity.CycleRecord;
import java.time.LocalDate;

public interface CycleRecordService {
    CycleRecord getOrCreateSnapshot(LocalDate cycleStartDate, LocalDate cycleEndDate);
    CycleRecord updateFixedDeposit(Long id, java.math.BigDecimal newAmount);
    java.util.List<java.util.Map<String, Object>> getRecentCycles(int months);
}
