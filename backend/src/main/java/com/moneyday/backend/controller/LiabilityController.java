package com.moneyday.backend.controller;

import com.moneyday.backend.common.Result;
import com.moneyday.backend.entity.Liability;
import com.moneyday.backend.entity.LiabilityVO;
import com.moneyday.backend.service.LiabilityService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.math.BigDecimal;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/liabilities")
public class LiabilityController {

    @Autowired
    private LiabilityService liabilityService;

    @GetMapping
    public Result<List<LiabilityVO>> getAllLiabilities() {
        return Result.success(liabilityService.getAllLiabilities());
    }

    @PostMapping
    public Result<Liability> addLiability(@RequestBody Liability liability) {
        return Result.success(liabilityService.addLiability(liability));
    }

    @PutMapping("/{id}")
    public Result<Liability> updateLiability(@PathVariable Long id, @RequestBody Liability liability) {
        liability.setId(id);
        return Result.success(liabilityService.updateLiability(liability));
    }

    @DeleteMapping("/{id}")
    public Result<Void> deleteLiability(@PathVariable Long id) {
        liabilityService.deleteLiability(id);
        return Result.success();
    }

    @PostMapping("/{id}/settle")
    public Result<Void> settleLiability(@PathVariable Long id, @RequestBody Map<String, Object> payload) {
        Object accObj = payload.get("accountId");
        Object amtObj = payload.get("settleAmount");
        if (accObj == null || amtObj == null) {
            return Result.error(400, "必须指定扣款账户和结清金额");
        }
        Long accountId = Long.valueOf(accObj.toString());
        BigDecimal settleAmount = new BigDecimal(amtObj.toString());
        liabilityService.settleLiability(id, accountId, settleAmount);
        return Result.success();
    }

    @PostMapping("/check-repayments")
    public Result<Void> checkRepayments() {
        liabilityService.checkAndExecuteDueRepayments();
        return Result.success();
    }
}
