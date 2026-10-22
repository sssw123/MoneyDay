package com.moneyday.backend.entity;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;

import com.baomidou.mybatisplus.annotation.TableName;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableField;
import com.baomidou.mybatisplus.extension.handlers.JacksonTypeHandler;

import java.util.List;

@TableName(value = "cycle_record", autoResultMap = true)
public class CycleRecord extends UserOwned {
    @TableId(type = IdType.AUTO)
    private Long id;
    private LocalDate cycleStartDate;
    private LocalDate cycleEndDate;
    
    @TableField(typeHandler = JacksonTypeHandler.class)
    private List<FixedItem> fixedItems;
    
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public LocalDate getCycleStartDate() { return cycleStartDate; }
    public void setCycleStartDate(LocalDate cycleStartDate) { this.cycleStartDate = cycleStartDate; }
    public LocalDate getCycleEndDate() { return cycleEndDate; }
    public void setCycleEndDate(LocalDate cycleEndDate) { this.cycleEndDate = cycleEndDate; }
    public List<FixedItem> getFixedItems() { return fixedItems; }
    public void setFixedItems(List<FixedItem> fixedItems) { this.fixedItems = fixedItems; }
    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }
    public LocalDateTime getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(LocalDateTime updatedAt) { this.updatedAt = updatedAt; }
}
