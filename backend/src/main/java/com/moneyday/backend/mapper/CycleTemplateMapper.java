package com.moneyday.backend.mapper;

import com.moneyday.backend.entity.CycleTemplate;
import org.apache.ibatis.annotations.*;

import java.util.List;

@Mapper
public interface CycleTemplateMapper {

    @Select("SELECT * FROM cycle_template ORDER BY id")
    List<CycleTemplate> findAll();

    @Select("SELECT * FROM cycle_template WHERE is_default = 1 LIMIT 1")
    CycleTemplate findDefault();

    @Insert("INSERT INTO cycle_template(name, start_day, is_default) VALUES(#{name}, #{startDay}, #{isDefault})")
    @Options(useGeneratedKeys = true, keyProperty = "id")
    int insert(CycleTemplate template);

    @Update("UPDATE cycle_template SET name=#{name}, start_day=#{startDay}, is_default=#{isDefault} WHERE id=#{id}")
    int update(CycleTemplate template);

    @Delete("DELETE FROM cycle_template WHERE id=#{id}")
    int deleteById(@Param("id") Long id);

    @Update("UPDATE cycle_template SET is_default = 0")
    void clearDefault();

    @Update("UPDATE cycle_template SET is_default = 1 WHERE id = #{id}")
    void setDefault(@Param("id") Long id);
}
