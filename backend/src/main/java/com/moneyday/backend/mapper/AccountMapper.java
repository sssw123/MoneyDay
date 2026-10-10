package com.moneyday.backend.mapper;

import com.moneyday.backend.entity.Account;
import org.apache.ibatis.annotations.*;

import java.util.List;

@Mapper
public interface AccountMapper {

    @Select("SELECT * FROM account")
    List<Account> findAll();

    @Select("SELECT * FROM account WHERE id = #{id}")
    Account findById(@Param("id") Long id);

    @Insert("INSERT INTO account(name, type, initial_balance, current_balance) " +
            "VALUES(#{name}, #{type}, #{initialBalance}, #{currentBalance})")
    @Options(useGeneratedKeys = true, keyProperty = "id")
    int insert(Account account);

    @Update("UPDATE account SET name=#{name}, type=#{type}, " +
            "current_balance=#{currentBalance} WHERE id=#{id}")
    int update(Account account);

    @Delete("DELETE FROM account WHERE id = #{id}")
    int deleteById(@Param("id") Long id);
}
