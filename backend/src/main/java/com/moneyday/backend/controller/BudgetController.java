package com.moneyday.backend.controller;

import com.moneyday.backend.common.Result;
import com.moneyday.backend.entity.Budget;
import com.moneyday.backend.service.BudgetService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/budgets")
public class BudgetController {

    @Autowired
    private BudgetService budgetService;

    @GetMapping
    public Result<List<Budget>> getAll() {
        return Result.success(budgetService.getAllBudgets());
    }

    @PostMapping
    public Result<Budget> create(@RequestBody Budget budget) {
        return Result.success(budgetService.addBudget(budget));
    }

    @PutMapping("/{id}")
    public Result<Budget> update(@PathVariable Long id, @RequestBody Budget budget) {
        budget.setId(id);
        return Result.success(budgetService.updateBudget(budget));
    }

    @DeleteMapping("/{id}")
    public Result<Void> delete(@PathVariable Long id) {
        budgetService.deleteBudget(id);
        return Result.success(null);
    }
}
