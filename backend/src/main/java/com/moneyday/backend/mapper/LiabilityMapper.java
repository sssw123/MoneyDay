package com.moneyday.backend.mapper;

import com.moneyday.backend.entity.Liability;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Select;
import com.baomidou.mybatisplus.core.mapper.BaseMapper;

import java.math.BigDecimal;

@Mapper
public interface LiabilityMapper extends BaseMapper<Liability> {

    @Select("SELECT IFNULL(SUM(total_amount - (current_period * period_amount)), 0) FROM liability WHERE status = 'REPAYING'")
    BigDecimal getTotalRemainingLiability();
}
