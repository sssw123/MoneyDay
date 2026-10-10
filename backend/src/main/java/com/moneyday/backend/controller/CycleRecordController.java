package com.moneyday.backend.controller;

import com.moneyday.backend.common.Result;
import com.moneyday.backend.entity.CycleRecord;
import com.moneyday.backend.service.CycleRecordService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.math.BigDecimal;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/cycles")
public class CycleRecordController {

    @Autowired
    private CycleRecordService cycleRecordService;

    @GetMapping
    public Result<List<Map<String, Object>>> getCycleList() {
        return Result.success(cycleRecordService.getRecentCycles(6));
    }

    @PutMapping("/{id}/fixed-deposit")
    public Result<CycleRecord> updateFixedDeposit(@PathVariable Long id, @RequestBody Map<String, BigDecimal> payload) {
        BigDecimal newAmount = payload.get("fixedDeposit");
        return Result.success(cycleRecordService.updateFixedDeposit(id, newAmount));
    }

    @PostMapping("/{id}/book-item/{itemId}")
    public Result<Map<String, Object>> bookItem(@PathVariable Long id, @PathVariable String itemId, @RequestBody Map<String, Object> payload) {
        Long accountId = Long.valueOf(payload.get("accountId").toString());
        BigDecimal amount = new BigDecimal(payload.get("amount").toString());
        String date = payload.get("date").toString();
        return Result.success(cycleRecordService.bookItem(id, itemId, accountId, amount, date));
    }

    @PostMapping("/{id}/unbook-item/{itemId}")
    public Result<Map<String, Object>> unbookItem(@PathVariable Long id, @PathVariable String itemId) {
        return Result.success(cycleRecordService.unbookItem(id, itemId));
    }
}
