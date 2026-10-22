package com.moneyday.backend.controller;
import com.moneyday.backend.common.Result;
import com.moneyday.backend.entity.User;
import com.moneyday.backend.mapper.UserMapper;
import com.moneyday.backend.security.UserContext;
import com.moneyday.backend.service.UserService;
import org.springframework.web.bind.annotation.*;
import java.util.Map;

@RestController
@RequestMapping("/api/user")
public class UserController {
    private final UserService users;
    private final UserMapper mapper;
    public UserController(UserService users,UserMapper mapper) { this.users=users; this.mapper=mapper; }
    @PostMapping("/login")
    public Result<Map<String,Object>> login(@RequestBody Map<String,String> body) { return Result.success(users.login(body.get("username"),body.get("password"))); }
    @GetMapping("/profile")
    public Result<User> profile() { return Result.success(mapper.selectById(UserContext.requireId())); }
    @PostMapping("/logout")
    public Result<Void> logout(@RequestHeader("Authorization") String header) { users.logout(header.substring(7)); return Result.success(); }
    @PutMapping("/password")
    public Result<Void> changePassword(@RequestBody Map<String,String> body) { users.changePassword(body.get("oldPassword"),body.get("newPassword")); return Result.success(); }
}
