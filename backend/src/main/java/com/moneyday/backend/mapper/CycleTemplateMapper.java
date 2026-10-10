package com.moneyday.backend.mapper;

import com.moneyday.backend.entity.CycleTemplate;
import org.apache.ibatis.annotations.*;
import com.baomidou.mybatisplus.core.mapper.BaseMapper;

import java.util.List;

@Mapper
public interface CycleTemplateMapper extends BaseMapper<CycleTemplate> {

    

    @Select("SELECT * FROM cycle_template WHERE is_default = 1 LIMIT 1")
    CycleTemplate findDefault();



    

    

    @Update("UPDATE cycle_template SET is_default = 0")
    void clearDefault();

    @Update("UPDATE cycle_template SET is_default = 1 WHERE id = #{id}")
    void setDefault(@Param("id") Long id);
}
