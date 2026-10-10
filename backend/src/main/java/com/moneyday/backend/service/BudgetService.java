package com.moneyday.backend.service;

import com.moneyday.backend.entity.Budget;
import com.moneyday.backend.mapper.BudgetMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import java.util.List;

public interface BudgetService {
    List<Budget> getAllBudgets();
    Budget addBudget(Budget budget);
    Budget updateBudget(Budget budget);
    void deleteBudget(Long id);
}
