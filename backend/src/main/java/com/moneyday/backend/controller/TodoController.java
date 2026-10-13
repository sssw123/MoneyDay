package com.moneyday.backend.controller;

import com.moneyday.backend.common.Result;
import com.moneyday.backend.entity.TodoItem;
import com.moneyday.backend.service.TodoService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.Collections;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/todos")
public class TodoController {

    @Autowired
    private TodoService todoService;

    @GetMapping
    public Result<List<TodoItem>> getTodos(@RequestParam(required = false, defaultValue = "PENDING") String status) {
        return Result.success(todoService.getTodos(status));
    }

    @GetMapping("/pending-count")
    public Result<Map<String, Long>> getPendingCount() {
        return Result.success(Collections.singletonMap("count", todoService.countPending()));
    }

    @PostMapping("/{id}/dismiss")
    public Result<Void> dismiss(@PathVariable Long id) {
        todoService.dismissTodo(id);
        return Result.success(null);
    }

    @PostMapping("/{id}/resolve")
    public Result<Void> resolve(@PathVariable Long id) {
        todoService.resolveTodo(id);
        return Result.success(null);
    }

    @PostMapping("/{id}/retry-repay")
    public Result<Void> retryRepay(@PathVariable Long id, @RequestBody(required = false) Map<String, Long> payload) {
        Long accountId = payload != null ? payload.get("accountId") : null;
        todoService.retryLiabilityRepayment(id, accountId);
        return Result.success(null);
    }
}
