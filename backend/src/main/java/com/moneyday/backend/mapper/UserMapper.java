package com.moneyday.backend.mapper;

import com.moneyday.backend.entity.User;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;
import org.apache.ibatis.annotations.Update;

@Mapper
public interface UserMapper {

    @Select("SELECT * FROM user WHERE username = #{username}")
    User findByUsername(@Param("username") String username);

    @Update("UPDATE user SET billing_cycle_start_day = #{billingCycleStartDay} WHERE username = #{username}")
    int updateBillingCycle(@Param("username") String username, @Param("billingCycleStartDay") Integer billingCycleStartDay);
}
