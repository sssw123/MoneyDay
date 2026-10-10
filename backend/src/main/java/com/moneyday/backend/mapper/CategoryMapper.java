package com.moneyday.backend.mapper;

import com.moneyday.backend.entity.Category;
import org.apache.ibatis.annotations.Mapper;
import com.baomidou.mybatisplus.core.mapper.BaseMapper;

@Mapper
public interface CategoryMapper extends BaseMapper<Category> {
}
