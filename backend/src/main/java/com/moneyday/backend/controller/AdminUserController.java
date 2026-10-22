package com.moneyday.backend.controller;
import com.moneyday.backend.common.Result;
import com.moneyday.backend.entity.User;
import com.moneyday.backend.service.AdminUserService;
import org.springframework.web.bind.annotation.*;
import java.util.Map;
@RestController
@RequestMapping("/api/admin/users")
public class AdminUserController {
    private final AdminUserService users;
    public AdminUserController(AdminUserService users) { this.users=users; }
    @GetMapping public Result<Map<String,Object>> list(@RequestParam(defaultValue="1") int page,@RequestParam(defaultValue="20") int pageSize,@RequestParam(required=false) String keyword,@RequestParam(required=false) String status) { return Result.success(users.list(page,pageSize,keyword,status)); }
    @PostMapping public Result<User> create(@RequestBody Map<String,String> body) {return Result.success(users.create(body.get("username"),body.get("password")));}
    @PutMapping("/{id}/status") public Result<Void> status(@PathVariable long id,@RequestBody Map<String,String> body) {users.status(id,body.get("status"));return Result.success();}
    @PostMapping("/{id}/reset-password") public Result<Void> reset(@PathVariable long id,@RequestBody Map<String,String> body) {users.reset(id,body.get("password"));return Result.success();}
    @DeleteMapping("/{id}") public Result<Void> delete(@PathVariable long id) {users.delete(id);return Result.success();}
}
