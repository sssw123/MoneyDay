package com.moneyday.backend.entity;

import com.baomidou.mybatisplus.annotation.TableField;
import com.baomidou.mybatisplus.annotation.FieldStrategy;
import com.fasterxml.jackson.annotation.JsonIgnore;

public abstract class UserOwned {
    @JsonIgnore
    @TableField(value = "user_id", insertStrategy = FieldStrategy.NEVER, updateStrategy = FieldStrategy.NEVER)
    private Long userId;
    public Long getUserId() { return userId; }
    public void setUserId(Long userId) { this.userId = userId; }
}
