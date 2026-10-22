package com.moneyday.backend.security;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.moneyday.backend.common.Result;
import com.moneyday.backend.entity.User;
import com.moneyday.backend.service.UserService;
import jakarta.servlet.*;
import jakarta.servlet.http.*;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.filter.OncePerRequestFilter;
import java.io.IOException;
import java.util.List;

public class BearerAuthenticationFilter extends OncePerRequestFilter {
    private final UserService users;
    private final ObjectMapper json;
    public BearerAuthenticationFilter(UserService users,ObjectMapper json) {this.users=users;this.json=json;}
    protected boolean shouldNotFilter(HttpServletRequest req) { return "OPTIONS".equals(req.getMethod()) || ("POST".equals(req.getMethod()) && "/api/user/login".equals(req.getServletPath())); }
    protected void doFilterInternal(HttpServletRequest req,HttpServletResponse res,FilterChain chain) throws IOException,ServletException {
        String header=req.getHeader("Authorization");
        User user=header!=null && header.startsWith("Bearer ") ? users.getByToken(header.substring(7)) : null;
        if(user==null) { error(res,401,"请重新登录");return; }
        String path=req.getServletPath();
        boolean ownAuth=("GET".equals(req.getMethod()) && path.equals("/api/user/profile")) || ("PUT".equals(req.getMethod()) && path.equals("/api/user/password")) || ("POST".equals(req.getMethod()) && path.equals("/api/user/logout"));
        if(Boolean.TRUE.equals(user.getMustChangePassword()) && !ownAuth) { error(res,403,"请先修改初始密码");return; }
        SecurityContextHolder.getContext().setAuthentication(new UsernamePasswordAuthenticationToken(user,null,List.of(new SimpleGrantedAuthority("ROLE_"+user.getRole()))));
        try {
            UserContext.call(user.getId(),()->{
                try { chain.doFilter(req,res); }
                catch(IOException | ServletException e) { throw new FilterFailure(e); }
                return null;
            });
        } catch(FilterFailure e) {
            if(e.getCause() instanceof IOException io) throw io;
            throw (ServletException)e.getCause();
        } finally { SecurityContextHolder.clearContext(); }
    }
    private void error(HttpServletResponse res,int code,String message) throws IOException { res.setStatus(code);res.setContentType("application/json;charset=UTF-8");json.writeValue(res.getOutputStream(),Result.error(code,message)); }
    private static class FilterFailure extends RuntimeException { FilterFailure(Exception cause) {super(cause);} }
}
