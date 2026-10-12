package com.moneyday.backend.entity;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;

import com.baomidou.mybatisplus.annotation.TableName;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.IdType;

@TableName("liability")
public class Liability {
    @TableId(type = IdType.AUTO)
    private Long id;
    private String name;
    private BigDecimal principal;
    private BigDecimal totalAmount;
    private Integer totalPeriods;
    private Integer currentPeriod;
    private BigDecimal periodAmount;
    private String rateType; // NONE, FEE, APR
    private BigDecimal interestRate;
    private Integer repaymentDay;
    private Long defaultAccountId;
    private Long categoryId;
    private Integer autoCycleFixedExpense;
    private String status; // REPAYING, SETTLED
    private LocalDate startDate;
    private LocalDateTime settledAt;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public String getName() { return name; }
    public void setName(String name) { this.name = name; }
    public BigDecimal getPrincipal() { return principal; }
    public void setPrincipal(BigDecimal principal) { this.principal = principal; }
    public BigDecimal getTotalAmount() { return totalAmount; }
    public void setTotalAmount(BigDecimal totalAmount) { this.totalAmount = totalAmount; }
    public Integer getTotalPeriods() { return totalPeriods; }
    public void setTotalPeriods(Integer totalPeriods) { this.totalPeriods = totalPeriods; }
    public Integer getCurrentPeriod() { return currentPeriod; }
    public void setCurrentPeriod(Integer currentPeriod) { this.currentPeriod = currentPeriod; }
    public BigDecimal getPeriodAmount() { return periodAmount; }
    public void setPeriodAmount(BigDecimal periodAmount) { this.periodAmount = periodAmount; }
    public String getRateType() { return rateType; }
    public void setRateType(String rateType) { this.rateType = rateType; }
    public BigDecimal getInterestRate() { return interestRate; }
    public void setInterestRate(BigDecimal interestRate) { this.interestRate = interestRate; }
    public Integer getRepaymentDay() { return repaymentDay; }
    public void setRepaymentDay(Integer repaymentDay) { this.repaymentDay = repaymentDay; }
    public Long getDefaultAccountId() { return defaultAccountId; }
    public void setDefaultAccountId(Long defaultAccountId) { this.defaultAccountId = defaultAccountId; }
    public Long getCategoryId() { return categoryId; }
    public void setCategoryId(Long categoryId) { this.categoryId = categoryId; }
    public Integer getAutoCycleFixedExpense() { return autoCycleFixedExpense; }
    public void setAutoCycleFixedExpense(Integer autoCycleFixedExpense) { this.autoCycleFixedExpense = autoCycleFixedExpense; }
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
    public LocalDate getStartDate() { return startDate; }
    public void setStartDate(LocalDate startDate) { this.startDate = startDate; }
    public LocalDateTime getSettledAt() { return settledAt; }
    public void setSettledAt(LocalDateTime settledAt) { this.settledAt = settledAt; }
    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }
    public LocalDateTime getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(LocalDateTime updatedAt) { this.updatedAt = updatedAt; }
}
