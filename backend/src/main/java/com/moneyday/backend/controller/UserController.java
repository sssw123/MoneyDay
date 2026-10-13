package com.moneyday.backend.controller;

import com.moneyday.backend.common.Result;
import com.moneyday.backend.service.UserService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@RequestMapping("/api/user")
public class UserController {

    @Autowired
    private UserService userService;

    @PostMapping("/login")
    public Result<String> login(@RequestBody Map<String, String> body) {
        String token = userService.login(body.get("username"), body.get("password"));
        return Result.success(token);
    }

    @GetMapping("/profile")
    public Result<com.moneyday.backend.entity.User> getProfile() {
        // Mock get current user for MVP
        return Result.success(userService.getByUsername("admin"));
    }
}
