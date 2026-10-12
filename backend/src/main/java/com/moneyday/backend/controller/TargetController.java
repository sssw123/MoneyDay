package com.moneyday.backend.controller;

import com.moneyday.backend.common.Result;
import com.moneyday.backend.entity.Target;
import com.moneyday.backend.entity.TargetVO;
import com.moneyday.backend.service.TargetService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/targets")
public class TargetController {

    @Autowired
    private TargetService targetService;

    @Autowired
    private com.moneyday.backend.service.CycleRecordService cycleRecordService;

    @GetMapping
    public Result<List<TargetVO>> getAll() {
        return Result.success(targetService.getAllTargets());
    }

    @GetMapping("/cumulative-balance")
    public Result<java.math.BigDecimal> getCumulativeBalance() {
        return Result.success(cycleRecordService.getTotalCumulativeBalance());
    }

    @PostMapping
    public Result<Target> create(@RequestBody Target target) {
        return Result.success(targetService.addTarget(target));
    }

    @PutMapping("/{id}")
    public Result<Target> update(@PathVariable Long id, @RequestBody Target target) {
        target.setId(id);
        return Result.success(targetService.updateTarget(target));
    }

    @DeleteMapping("/{id}")
    public Result<Void> delete(@PathVariable Long id) {
        targetService.deleteTarget(id);
        return Result.success(null);
    }

    @PostMapping("/{id}/realize")
    public Result<Void> realize(@PathVariable Long id, @RequestBody java.util.Map<String, Long> payload) {
        Long accountId = payload.get("accountId");
        if (accountId == null) {
            throw new RuntimeException("请选择扣款账户");
        }
        targetService.realizeTarget(id, accountId);
        return Result.success(null);
    }

    @PostMapping("/{id}/unrealize")
    public Result<Void> unrealize(@PathVariable Long id) {
        targetService.unrealizeTarget(id);
        return Result.success(null);
    }
}
