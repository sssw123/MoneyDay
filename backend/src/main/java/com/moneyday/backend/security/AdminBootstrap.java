package com.moneyday.backend.security;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.moneyday.backend.entity.User;
import com.moneyday.backend.mapper.UserMapper;
import com.moneyday.backend.service.impl.UserServiceImpl;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.ApplicationArguments;
import org.springframework.boot.ApplicationRunner;
import org.springframework.core.annotation.Order;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;

@Component
@Order(0)
public class AdminBootstrap implements ApplicationRunner {
    private final JdbcTemplate jdbc;private final UserMapper users;private final PasswordEncoder passwords;private final PersonalDataSeeder seeder;private final String initial;
    public AdminBootstrap(JdbcTemplate jdbc,UserMapper users,PasswordEncoder passwords,PersonalDataSeeder seeder,@Value("${MONEYDAY_ADMIN_PASSWORD:}") String initial) {this.jdbc=jdbc;this.users=users;this.passwords=passwords;this.seeder=seeder;this.initial=initial;}
    @Transactional
    public void run(ApplicationArguments args) {
        Integer version;
        try {version=jdbc.queryForObject("SELECT version FROM moneyday_schema WHERE id=1",Integer.class);}
        catch(Exception e) {throw new IllegalStateException("请先初始化独立多用户数据库，禁止使用旧库启动新版");}
        if(version==null || version!=1)throw new IllegalStateException("多用户数据库版本不匹配");
        if(users.selectCount(new QueryWrapper<User>().eq("role","ADMIN"))>0)return;
        if(users.selectCount(null)>0) throw new IllegalStateException("用户数据异常，禁止自动创建管理员");
        UserServiceImpl.validatePassword(initial);
        User admin=new User();admin.setUsername("admin");admin.setPassword(passwords.encode(initial));admin.setRole("ADMIN");admin.setStatus("ACTIVE");admin.setMustChangePassword(true);users.insert(admin);seeder.seed(admin.getId());
    }
}
