package com.moneyday.backend.mapper;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Select;

import java.math.BigDecimal;
import java.util.List;
import java.util.Map;

@Mapper
public interface StatMapper {

    @Select("SELECT IFNULL(SUM(current_balance), 0) FROM account")
    BigDecimal getTotalAssets();

    @Select("SELECT IFNULL(SUM(target_amount), 0) FROM target WHERE is_realized = 0")
    BigDecimal getTotalTargets();

    @Select("SELECT IFNULL(SUM(target_amount), 0) FROM target WHERE is_realized = 1")
    BigDecimal getTargetAllocated();

    @Select("SELECT IFNULL(SUM(amount), 0) FROM transaction WHERE type = 1 AND transaction_date >= #{startDate} AND transaction_date <= #{endDate}")
    BigDecimal getIncomeByDate(String startDate, String endDate);

    @Select("SELECT IFNULL(SUM(amount), 0) FROM transaction WHERE type = 2 AND transaction_date >= #{startDate} AND transaction_date <= #{endDate}")
    BigDecimal getExpenseByDate(String startDate, String endDate);

    @Select("SELECT c.name as name, SUM(t.amount) as value FROM transaction t JOIN category c ON t.category_id = c.id WHERE t.type = 2 AND t.transaction_date >= #{startDate} AND t.transaction_date <= #{endDate} GROUP BY c.id, c.name ORDER BY value DESC")
    List<Map<String, Object>> getCategoryExpensesByDate(String startDate, String endDate);
}
