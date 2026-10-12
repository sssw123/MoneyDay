package com.moneyday.backend.mapper;

import com.moneyday.backend.entity.CycleTemplate;
import org.apache.ibatis.annotations.*;
import com.baomidou.mybatisplus.core.mapper.BaseMapper;

import java.util.List;

@Mapper
public interface CycleTemplateMapper extends BaseMapper<CycleTemplate> {

    

    default CycleTemplate findDefault() {
        return selectOne(new com.baomidou.mybatisplus.core.conditions.query.QueryWrapper<CycleTemplate>()
                .eq("is_default", 1)
                .last("LIMIT 1"));
    }



    

    

    @Update("UPDATE cycle_template SET is_default = 0")
    void clearDefault();

    @Update("UPDATE cycle_template SET is_default = 1 WHERE id = #{id}")
    void setDefault(@Param("id") Long id);
}
