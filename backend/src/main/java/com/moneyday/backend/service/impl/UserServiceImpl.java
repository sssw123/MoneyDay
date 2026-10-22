package com.moneyday.backend.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.moneyday.backend.common.ApiException;
import com.moneyday.backend.entity.*;
import com.moneyday.backend.mapper.*;
import com.moneyday.backend.security.UserContext;
import com.moneyday.backend.service.UserService;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.SecureRandom;
import java.time.LocalDateTime;
import java.util.*;

@Service
public class UserServiceImpl implements UserService {
    private final UserMapper users;
    private final AuthSessionMapper sessions;
    private final PasswordEncoder passwords;
    public UserServiceImpl(UserMapper users, AuthSessionMapper sessions, PasswordEncoder passwords) {
        this.users=users; this.sessions=sessions; this.passwords=passwords;
    }
    public static String normalizeUsername(String name) {
        if (name==null || !name.trim().matches("[A-Za-z0-9_.-]{3,50}")) throw new ApiException(400,"用户名须为3–50位字母、数字、下划线、点或横线");
        return name.trim().toLowerCase(Locale.ROOT);
    }
    public static void validatePassword(String value) {
        if(value==null || value.codePointCount(0,value.length())<8 || value.getBytes(StandardCharsets.UTF_8).length>72)
            throw new ApiException(400,"密码至少8位且UTF-8编码不超过72字节");
    }
    public static String hashToken(String token) {
        try { return HexFormat.of().formatHex(MessageDigest.getInstance("SHA-256").digest(token.getBytes(StandardCharsets.UTF_8))); }
        catch (java.security.NoSuchAlgorithmException e) { throw new IllegalStateException(e); }
    }
    @Transactional
    public Map<String,Object> login(String username,String password) {
        User found;
        try { found=getByUsername(normalizeUsername(username)); }
        catch(ApiException e) { throw new ApiException(401,"用户名或密码错误"); }
        if(found==null) throw new ApiException(401,"用户名或密码错误");
        User u=users.lockById(found.getId());
        if(!"ACTIVE".equals(u.getStatus()) || password==null || password.getBytes(StandardCharsets.UTF_8).length>72 || !passwords.matches(password,u.getPassword()))
            throw new ApiException(401,"用户名或密码错误，或账户不可用");
        byte[] bytes=new byte[32]; new SecureRandom().nextBytes(bytes);
        String token=Base64.getUrlEncoder().withoutPadding().encodeToString(bytes);
        AuthSession session=new AuthSession(); session.setId(hashToken(token)); session.setUserId(u.getId()); session.setExpiresAt(LocalDateTime.now().plusDays(7)); sessions.insert(session);
        return Map.of("token",token,"expiresAt",session.getExpiresAt().atZone(java.time.ZoneId.of("Asia/Shanghai")).toInstant(),"user",u);
    }
    public User getByToken(String token) {
        if(token==null || token.length()>256) return null;
        AuthSession s=sessions.selectById(hashToken(token));
        if(s==null || !s.getExpiresAt().isAfter(LocalDateTime.now())) return null;
        User user=users.selectById(s.getUserId());
        return user!=null && "ACTIVE".equals(user.getStatus()) ? user : null;
    }
    public User getByUsername(String username) { return users.selectOne(new QueryWrapper<User>().eq("username",username)); }
    public void logout(String token) { if(token!=null) sessions.deleteById(hashToken(token)); }
    @Transactional
    public void changePassword(String oldPassword,String newPassword) {
        User u=users.lockById(UserContext.requireId());
        if(u==null || !"ACTIVE".equals(u.getStatus())) throw new ApiException(401,"账户不可用");
        if(oldPassword==null || oldPassword.getBytes(StandardCharsets.UTF_8).length>72 || !passwords.matches(oldPassword,u.getPassword())) throw new ApiException(400,"原密码错误");
        validatePassword(newPassword);
        if(passwords.matches(newPassword,u.getPassword())) throw new ApiException(400,"新密码不能与原密码相同");
        u.setPassword(passwords.encode(newPassword)); u.setMustChangePassword(false); users.updateById(u);
        sessions.delete(new QueryWrapper<AuthSession>().eq("user_id",u.getId()));
    }
}
