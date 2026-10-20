package com.moneyday.backend.security;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.moneyday.backend.common.Result;
import com.moneyday.backend.service.UserService;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.*;
import org.springframework.http.HttpMethod;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter;
import org.springframework.web.cors.*;
import java.util.*;

@Configuration
public class SecurityConfiguration {
    @Bean public PasswordEncoder passwords() { return new BCryptPasswordEncoder(); }
    @Bean public SecurityFilterChain apiSecurity(HttpSecurity http,UserService users,ObjectMapper json,@org.springframework.beans.factory.annotation.Qualifier("cors") CorsConfigurationSource cors) throws Exception {
        return http.csrf(c->c.disable()).cors(c->c.configurationSource(cors))
            .sessionManagement(s->s.sessionCreationPolicy(SessionCreationPolicy.STATELESS))
            .formLogin(c->c.disable()).httpBasic(c->c.disable())
            .authorizeHttpRequests(a->a.requestMatchers(HttpMethod.OPTIONS,"/**").permitAll()
                .requestMatchers(HttpMethod.POST,"/api/user/login").permitAll()
                .requestMatchers("/api/admin/**").hasRole("ADMIN").anyRequest().authenticated())
            .exceptionHandling(e->e.authenticationEntryPoint((req,res,ex)->{res.setStatus(401);res.setContentType("application/json;charset=UTF-8");json.writeValue(res.getOutputStream(),Result.error(401,"请先登录"));})
                .accessDeniedHandler((req,res,ex)->{res.setStatus(403);res.setContentType("application/json;charset=UTF-8");json.writeValue(res.getOutputStream(),Result.error(403,"无权执行此操作"));}))
            .addFilterBefore(new BearerAuthenticationFilter(users,json),UsernamePasswordAuthenticationFilter.class).build();
    }
    @Bean public CorsConfigurationSource cors(@Value("${moneyday.cors-origins:http://localhost:5173,http://127.0.0.1:5173,http://localhost:5174,http://127.0.0.1:5174,https://localhost,http://localhost,capacitor://localhost}") String origins) {
        CorsConfiguration c=new CorsConfiguration();c.setAllowedOrigins(Arrays.stream(origins.split(",")).map(String::trim).toList());c.setAllowedMethods(List.of("GET","POST","PUT","DELETE","OPTIONS"));c.setAllowedHeaders(List.of("Authorization","Content-Type"));c.setAllowCredentials(false);
        UrlBasedCorsConfigurationSource source=new UrlBasedCorsConfigurationSource();source.registerCorsConfiguration("/**",c);return source;
    }
}
