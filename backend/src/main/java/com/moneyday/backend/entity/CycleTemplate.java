package com.moneyday.backend.entity;
import java.math.BigDecimal;
import com.baomidou.mybatisplus.annotation.TableName;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.IdType;

@TableName("cycle_template")
public class CycleTemplate {
    @TableId(type = IdType.AUTO)
    private Long id;
    private String name;
    private Integer startDay;
    private Integer isDefault;
    private BigDecimal defaultFixedDeposit;
    private BigDecimal defaultFixedIncome;

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public String getName() { return name; }
    public void setName(String name) { this.name = name; }
    public Integer getStartDay() { return startDay; }
    public void setStartDay(Integer startDay) { this.startDay = startDay; }
    public Integer getIsDefault() { return isDefault; }
    public void setIsDefault(Integer isDefault) { this.isDefault = isDefault; }
    public BigDecimal getDefaultFixedDeposit() { return defaultFixedDeposit; }
    public void setDefaultFixedDeposit(BigDecimal defaultFixedDeposit) { this.defaultFixedDeposit = defaultFixedDeposit; }
    public BigDecimal getDefaultFixedIncome() { return defaultFixedIncome; }
    public void setDefaultFixedIncome(BigDecimal defaultFixedIncome) { this.defaultFixedIncome = defaultFixedIncome; }
}
