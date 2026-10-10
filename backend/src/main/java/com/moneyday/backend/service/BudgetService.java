package com.moneyday.backend.service;

import com.moneyday.backend.entity.Budget;
import com.moneyday.backend.mapper.BudgetMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class BudgetService {

    @Autowired
    private BudgetMapper budgetMapper;

    public List<Budget> getAllBudgets() {
        return budgetMapper.selectList(null);
    }

    public Budget addBudget(Budget budget) {
        budgetMapper.insert(budget);
        return budget;
    }

    public Budget updateBudget(Budget budget) {
        budgetMapper.updateById(budget);
        return budget;
    }

    public void deleteBudget(Long id) {
        budgetMapper.deleteById(id);
    }
}
