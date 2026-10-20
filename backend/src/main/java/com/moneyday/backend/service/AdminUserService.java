package com.moneyday.backend.service;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.moneyday.backend.common.ApiException;
import com.moneyday.backend.entity.*;
import com.moneyday.backend.mapper.*;
import com.moneyday.backend.security.PersonalDataSeeder;
import com.moneyday.backend.service.impl.UserServiceImpl;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import java.util.Map;

@Service
public class AdminUserService {
    private final UserMapper users;
    private final AuthSessionMapper sessions;
    private final PasswordEncoder passwords;
    private final PersonalDataSeeder seeder;
    public AdminUserService(UserMapper users,AuthSessionMapper sessions,PasswordEncoder passwords,PersonalDataSeeder seeder) {this.users=users;this.sessions=sessions;this.passwords=passwords;this.seeder=seeder;}
    public Map<String,Object> list(int page,int pageSize,String keyword,String status) {
        if(page<1 || pageSize<1 || pageSize>100) throw new ApiException(400,"分页参数无效");
        QueryWrapper<User> q=new QueryWrapper<User>().eq("role","USER").ne("status","DELETED");
        if(keyword!=null && !keyword.isBlank()) q.like("username",keyword.trim());
        if(status!=null && !status.isBlank()) {if(!java.util.Set.of("ACTIVE","DISABLED").contains(status)) throw new ApiException(400,"状态无效");q.eq("status",status);}
        long total=users.selectCount(q);
        q.orderByDesc("id").last("LIMIT "+pageSize+" OFFSET "+((long)(page-1)*pageSize));
        return Map.of("records",users.selectList(q),"total",total,"page",page,"pageSize",pageSize);
    }
    @Transactional public User create(String username,String password) {
        String normalized=UserServiceImpl.normalizeUsername(username); UserServiceImpl.validatePassword(password);
        if(users.selectCount(new QueryWrapper<User>().eq("username",normalized))>0) throw new ApiException(409,"用户名已被占用");
        User u=new User();u.setUsername(normalized);u.setPassword(passwords.encode(password));u.setRole("USER");u.setStatus("ACTIVE");u.setMustChangePassword(true);users.insert(u);seeder.seed(u.getId());return users.selectById(u.getId());
    }
    private User ordinary(long id) { User u=users.lockById(id); if(u==null || !"USER".equals(u.getRole()) || "DELETED".equals(u.getStatus())) throw ApiException.notFound();return u; }
    private void revoke(long id) {sessions.delete(new QueryWrapper<AuthSession>().eq("user_id",id));}
    @Transactional public void status(long id,String status) {
        if(!java.util.Set.of("ACTIVE","DISABLED").contains(status==null?"":status)) throw new ApiException(400,"状态无效");
        User u=ordinary(id);u.setStatus(status);users.updateById(u);revoke(id);
    }
    @Transactional public void reset(long id,String password) {
        UserServiceImpl.validatePassword(password);User u=ordinary(id);u.setPassword(passwords.encode(password));u.setMustChangePassword(true);users.updateById(u);revoke(id);
    }
    @Transactional public void delete(long id) {User u=ordinary(id);u.setStatus("DELETED");users.updateById(u);revoke(id);}
}
