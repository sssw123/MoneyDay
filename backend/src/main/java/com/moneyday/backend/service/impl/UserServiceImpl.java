package com.moneyday.backend.service.impl;

import com.moneyday.backend.service.UserService;

import com.moneyday.backend.entity.User;
import com.moneyday.backend.mapper.UserMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.HashMap;
import java.util.Map;
import java.util.UUID;

@Service
public class UserServiceImpl implements UserService {

    @Autowired
    private UserMapper userMapper;

    // Simple in-memory token map for MVP
    private Map<String, Long> tokenStore = new HashMap<>();

    public String login(String username, String password) {
        User user = userMapper.selectOne(new com.baomidou.mybatisplus.core.conditions.query.QueryWrapper<com.moneyday.backend.entity.User>().eq("username", username));
        if (user != null && user.getPassword().equals(password)) {
            String token = UUID.randomUUID().toString();
            tokenStore.put(token, user.getId());
            return token;
        }
        throw new IllegalArgumentException("Invalid username or password");
    }

    public User getByToken(String token) {
        Long id = tokenStore.get(token);
        if (id == null) return null;
        // Mock returning user (MVP limits to 1 user)
        User u = new User();
        u.setId(id);
        return u;
    }

    public User getByUsername(String username) {
        return userMapper.selectOne(new com.baomidou.mybatisplus.core.conditions.query.QueryWrapper<com.moneyday.backend.entity.User>().eq("username", username));
    }
}
