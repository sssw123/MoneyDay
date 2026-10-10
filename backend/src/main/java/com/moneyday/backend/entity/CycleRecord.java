package com.moneyday.backend.entity;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;

import com.baomidou.mybatisplus.annotation.TableName;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.IdType;

@TableName("cycle_record")
public class CycleRecord {
    @TableId(type = IdType.AUTO)
    private Long id;
    private LocalDate cycleStartDate;
    private LocalDate cycleEndDate;
    private BigDecimal fixedDeposit;
    private BigDecimal fixedIncome;
    private Integer isFixedIncomeBooked;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public LocalDate getCycleStartDate() { return cycleStartDate; }
    public void setCycleStartDate(LocalDate cycleStartDate) { this.cycleStartDate = cycleStartDate; }
    public LocalDate getCycleEndDate() { return cycleEndDate; }
    public void setCycleEndDate(LocalDate cycleEndDate) { this.cycleEndDate = cycleEndDate; }
    public BigDecimal getFixedDeposit() { return fixedDeposit; }
    public void setFixedDeposit(BigDecimal fixedDeposit) { this.fixedDeposit = fixedDeposit; }
    public BigDecimal getFixedIncome() { return fixedIncome; }
    public void setFixedIncome(BigDecimal fixedIncome) { this.fixedIncome = fixedIncome; }
    public Integer getIsFixedIncomeBooked() { return isFixedIncomeBooked; }
    public void setIsFixedIncomeBooked(Integer isFixedIncomeBooked) { this.isFixedIncomeBooked = isFixedIncomeBooked; }
    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }
    public LocalDateTime getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(LocalDateTime updatedAt) { this.updatedAt = updatedAt; }
}
