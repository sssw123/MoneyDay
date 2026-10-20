package com.moneyday.backend.service;
import com.moneyday.backend.entity.User;
import java.util.Map;
public interface UserService {
    Map<String,Object> login(String username, String password);
    User getByToken(String token);
    User getByUsername(String username);
    void logout(String token);
    void changePassword(String oldPassword, String newPassword);
}
