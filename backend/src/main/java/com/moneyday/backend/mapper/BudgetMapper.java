package com.moneyday.backend.mapper;

import com.moneyday.backend.entity.Budget;
import org.apache.ibatis.annotations.Mapper;
import com.baomidou.mybatisplus.core.mapper.BaseMapper;

@Mapper
public interface BudgetMapper extends BaseMapper<Budget> {
}
