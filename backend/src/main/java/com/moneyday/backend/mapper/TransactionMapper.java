package com.moneyday.backend.mapper;

import com.moneyday.backend.entity.Transaction;
import org.apache.ibatis.annotations.*;

import java.util.List;

@Mapper
public interface TransactionMapper {

    @Select("SELECT * FROM transaction ORDER BY transaction_date DESC, id DESC")
    List<Transaction> findAll();

    @Select("SELECT * FROM transaction WHERE id = #{id}")
    Transaction findById(@Param("id") Long id);

    @Insert("INSERT INTO transaction(type, amount, transaction_date, category_id, account_id, to_account_id, remark) " +
            "VALUES(#{type}, #{amount}, #{transactionDate}, #{categoryId}, #{accountId}, #{toAccountId}, #{remark})")
    @Options(useGeneratedKeys = true, keyProperty = "id")
    int insert(Transaction transaction);

    @Update("UPDATE transaction SET type=#{type}, amount=#{amount}, transaction_date=#{transactionDate}, " +
            "category_id=#{categoryId}, account_id=#{accountId}, to_account_id=#{toAccountId}, remark=#{remark} " +
            "WHERE id=#{id}")
    int update(Transaction transaction);

    @Delete("DELETE FROM transaction WHERE id = #{id}")
    int deleteById(@Param("id") Long id);
}
