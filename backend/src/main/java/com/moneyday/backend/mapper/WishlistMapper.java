package com.moneyday.backend.mapper;

import com.moneyday.backend.entity.Wishlist;
import org.apache.ibatis.annotations.Mapper;
import com.baomidou.mybatisplus.core.mapper.BaseMapper;

@Mapper
public interface WishlistMapper extends BaseMapper<Wishlist> {
}
