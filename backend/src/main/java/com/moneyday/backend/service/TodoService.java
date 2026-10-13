package com.moneyday.backend.service;

import com.moneyday.backend.entity.TodoItem;
import java.util.List;

public interface TodoService {
    List<TodoItem> getTodos(String status);
    long countPending();
    void dismissTodo(Long id);
    void resolveTodo(Long id);
    void resolveTodoByBiz(String type, String bizId);
    void createTodoIfNotExists(String type, String title, String content, String bizId);
    void retryLiabilityRepayment(Long todoId, Long accountId);
}
