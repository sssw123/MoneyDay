package com.moneyday.backend.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.moneyday.backend.entity.TodoItem;
import org.apache.ibatis.annotations.Mapper;

@Mapper
public interface TodoItemMapper extends BaseMapper<TodoItem> {
}
