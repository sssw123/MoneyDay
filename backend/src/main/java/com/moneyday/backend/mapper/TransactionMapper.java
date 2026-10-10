package com.moneyday.backend.mapper;

import com.moneyday.backend.entity.Transaction;
import org.apache.ibatis.annotations.Mapper;
import com.baomidou.mybatisplus.core.mapper.BaseMapper;

@Mapper
public interface TransactionMapper extends BaseMapper<Transaction> {
}
