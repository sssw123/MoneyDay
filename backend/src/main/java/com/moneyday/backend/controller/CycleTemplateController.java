package com.moneyday.backend.controller;

import com.moneyday.backend.common.Result;
import com.moneyday.backend.entity.CycleTemplate;
import com.moneyday.backend.service.CycleTemplateService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/cycle-templates")
public class CycleTemplateController {

    @Autowired
    private CycleTemplateService service;

    @GetMapping
    public Result<List<CycleTemplate>> getAll() {
        return Result.success(service.getAll());
    }

    @PostMapping
    public Result<CycleTemplate> create(@RequestBody CycleTemplate template) {
        return Result.success(service.add(template));
    }

    @PutMapping("/{id}")
    public Result<CycleTemplate> update(@PathVariable Long id, @RequestBody CycleTemplate template) {
        template.setId(id);
        return Result.success(service.update(template));
    }

    @DeleteMapping("/{id}")
    public Result<Void> delete(@PathVariable Long id) {
        service.delete(id);
        return Result.success(null);
    }

    @PostMapping("/{id}/default")
    public Result<Void> setDefault(@PathVariable Long id) {
        service.setDefault(id);
        return Result.success(null);
    }
}
