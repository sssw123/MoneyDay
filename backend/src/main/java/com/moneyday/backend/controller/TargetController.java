package com.moneyday.backend.controller;

import com.moneyday.backend.common.Result;
import com.moneyday.backend.entity.Target;
import com.moneyday.backend.service.TargetService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/targets")
public class TargetController {

    @Autowired
    private TargetService targetService;

    @GetMapping
    public Result<List<Target>> getAll() {
        return Result.success(targetService.getAllTargets());
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
}
