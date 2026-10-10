package com.moneyday.backend.entity;

import java.math.BigDecimal;
import java.util.List;
import java.util.Map;

public class StatDTO {
    private BigDecimal totalAssets;
    private BigDecimal totalTargets;
    private BigDecimal targetAllocated;
    private boolean isOverdraft;

    private BigDecimal currentIncome;
    private BigDecimal currentExpense;
    private BigDecimal currentFixedDeposit;
    private BigDecimal currentBalance;
    private BigDecimal currentFinalBalance;
    private BigDecimal availableAssets;
    private BigDecimal cumulativeBalance;

    private List<Map<String, Object>> categoryExpenses;

    public BigDecimal getCumulativeBalance() { return cumulativeBalance; }
    public void setCumulativeBalance(BigDecimal cumulativeBalance) { this.cumulativeBalance = cumulativeBalance; }

    public BigDecimal getTotalAssets() { return totalAssets; }
    public void setTotalAssets(BigDecimal totalAssets) { this.totalAssets = totalAssets; }
    public BigDecimal getTotalTargets() { return totalTargets; }
    public void setTotalTargets(BigDecimal totalTargets) { this.totalTargets = totalTargets; }
    public BigDecimal getTargetAllocated() { return targetAllocated; }
    public void setTargetAllocated(BigDecimal targetAllocated) { this.targetAllocated = targetAllocated; }
    public boolean getIsOverdraft() { return isOverdraft; }
    public void setIsOverdraft(boolean isOverdraft) { this.isOverdraft = isOverdraft; }
    public BigDecimal getCurrentIncome() { return currentIncome; }
    public void setCurrentIncome(BigDecimal currentIncome) { this.currentIncome = currentIncome; }
    public BigDecimal getCurrentExpense() { return currentExpense; }
    public void setCurrentExpense(BigDecimal currentExpense) { this.currentExpense = currentExpense; }
    public BigDecimal getCurrentFixedDeposit() { return currentFixedDeposit; }
    public void setCurrentFixedDeposit(BigDecimal currentFixedDeposit) { this.currentFixedDeposit = currentFixedDeposit; }
    public BigDecimal getCurrentBalance() { return currentBalance; }
    public void setCurrentBalance(BigDecimal currentBalance) { this.currentBalance = currentBalance; }
    public BigDecimal getCurrentFinalBalance() { return currentFinalBalance; }
    public void setCurrentFinalBalance(BigDecimal currentFinalBalance) { this.currentFinalBalance = currentFinalBalance; }
    public BigDecimal getAvailableAssets() { return availableAssets; }
    public void setAvailableAssets(BigDecimal availableAssets) { this.availableAssets = availableAssets; }
    public List<Map<String, Object>> getCategoryExpenses() { return categoryExpenses; }
    public void setCategoryExpenses(List<Map<String, Object>> categoryExpenses) { this.categoryExpenses = categoryExpenses; }
}
