package com.moneyday.backend.mapper;

import com.moneyday.backend.entity.Budget;
import org.apache.ibatis.annotations.*;

import java.util.List;

@Mapper
public interface BudgetMapper {

    @Select("SELECT * FROM budget ORDER BY cycle_start_date DESC")
    List<Budget> findAll();

    @Select("SELECT * FROM budget WHERE id = #{id}")
    Budget findById(@Param("id") Long id);

    @Insert("INSERT INTO budget(amount, cycle_start_date, cycle_end_date) VALUES(#{amount}, #{cycleStartDate}, #{cycleEndDate})")
    @Options(useGeneratedKeys = true, keyProperty = "id")
    int insert(Budget budget);

    @Update("UPDATE budget SET amount=#{amount}, cycle_start_date=#{cycleStartDate}, cycle_end_date=#{cycleEndDate} WHERE id=#{id}")
    int update(Budget budget);

    @Delete("DELETE FROM budget WHERE id = #{id}")
    int deleteById(@Param("id") Long id);
}
