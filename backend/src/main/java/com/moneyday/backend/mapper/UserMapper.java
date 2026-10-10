package com.moneyday.backend.mapper;

import com.moneyday.backend.entity.User;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;
import org.apache.ibatis.annotations.Update;
import com.baomidou.mybatisplus.core.mapper.BaseMapper;

@Mapper
public interface UserMapper extends BaseMapper<User> {

    

    @Update("UPDATE user SET billing_cycle_start_day = #{billingCycleStartDay} WHERE username = #{username}")
    int updateBillingCycle(@Param("username") String username, @Param("billingCycleStartDay") Integer billingCycleStartDay);
}
