package com.moneyday.backend.controller;

import com.moneyday.backend.common.Result;
import com.moneyday.backend.entity.Wishlist;
import com.moneyday.backend.entity.WishlistVO;
import com.moneyday.backend.service.WishlistService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/wishlists")
public class WishlistController {

    @Autowired
    private WishlistService wishlistService;

    @GetMapping
    public Result<List<WishlistVO>> getAllWishlists() {
        return Result.success(wishlistService.getAllWishlists());
    }

    @PostMapping
    public Result<Wishlist> addWishlist(@RequestBody Wishlist wishlist) {
        return Result.success(wishlistService.addWishlist(wishlist));
    }

    @PutMapping("/{id}")
    public Result<Wishlist> updateWishlist(@PathVariable Long id, @RequestBody Wishlist wishlist) {
        wishlist.setId(id);
        return Result.success(wishlistService.updateWishlist(wishlist));
    }

    @DeleteMapping("/{id}")
    public Result<Void> deleteWishlist(@PathVariable Long id) {
        wishlistService.deleteWishlist(id);
        return Result.success();
    }

    @PostMapping("/{id}/realize")
    public Result<Void> realizeWishlist(@PathVariable Long id, @RequestBody Map<String, Long> payload) {
        Long accountId = payload.get("accountId");
        if (accountId == null) {
            return Result.error(400, "必须指定扣款账户");
        }
        wishlistService.realizeWishlist(id, accountId);
        return Result.success();
    }

    @PostMapping("/{id}/unrealize")
    public Result<Void> unrealizeWishlist(@PathVariable Long id) {
        wishlistService.unrealizeWishlist(id);
        return Result.success();
    }
}
