package com.moneyday.backend.mapper;
import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.moneyday.backend.entity.AuthSession;
import org.apache.ibatis.annotations.Mapper;
@Mapper
public interface AuthSessionMapper extends BaseMapper<AuthSession> {}
