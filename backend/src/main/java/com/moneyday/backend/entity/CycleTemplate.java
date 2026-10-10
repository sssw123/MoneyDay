package com.moneyday.backend.entity;

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

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public String getName() { return name; }
    public void setName(String name) { this.name = name; }
    public Integer getStartDay() { return startDay; }
    public void setStartDay(Integer startDay) { this.startDay = startDay; }
    public Integer getIsDefault() { return isDefault; }
    public void setIsDefault(Integer isDefault) { this.isDefault = isDefault; }
}
