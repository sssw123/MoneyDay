package com.moneyday.backend.service;

import com.moneyday.backend.entity.Wishlist;
import com.moneyday.backend.entity.WishlistVO;
import java.util.List;

public interface WishlistService {
    List<WishlistVO> getAllWishlists();
    Wishlist addWishlist(Wishlist wishlist);
    Wishlist updateWishlist(Wishlist wishlist);
    void deleteWishlist(Long id);
    void realizeWishlist(Long id, Long accountId);
    void unrealizeWishlist(Long id);
}
