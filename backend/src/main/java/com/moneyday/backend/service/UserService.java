package com.moneyday.backend.service;

import com.moneyday.backend.entity.User;
import com.moneyday.backend.mapper.UserMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import java.util.HashMap;
import java.util.Map;
import java.util.UUID;

public interface UserService {
    String login(String username, String password);
    User getByToken(String token);
    User getByUsername(String username);
}
