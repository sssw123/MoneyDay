package com.moneyday.backend.mapper;

import com.moneyday.backend.entity.Account;
import org.apache.ibatis.annotations.Mapper;
import com.baomidou.mybatisplus.core.mapper.BaseMapper;

@Mapper
public interface AccountMapper extends BaseMapper<Account> {
}
