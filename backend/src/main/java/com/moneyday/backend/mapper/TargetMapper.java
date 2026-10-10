package com.moneyday.backend.mapper;

import com.moneyday.backend.entity.Target;
import org.apache.ibatis.annotations.*;

import java.util.List;

@Mapper
public interface TargetMapper {

    @Select("SELECT * FROM target ORDER BY id DESC")
    List<Target> findAll();

    @Select("SELECT * FROM target WHERE id = #{id}")
    Target findById(@Param("id") Long id);

    @Insert("INSERT INTO target(name, target_amount, allocated_amount, deadline) VALUES(#{name}, #{targetAmount}, #{allocatedAmount}, #{deadline})")
    @Options(useGeneratedKeys = true, keyProperty = "id")
    int insert(Target target);

    @Update("UPDATE target SET name=#{name}, target_amount=#{targetAmount}, allocated_amount=#{allocatedAmount}, deadline=#{deadline} WHERE id=#{id}")
    int update(Target target);

    @Delete("DELETE FROM target WHERE id = #{id}")
    int deleteById(@Param("id") Long id);
}
