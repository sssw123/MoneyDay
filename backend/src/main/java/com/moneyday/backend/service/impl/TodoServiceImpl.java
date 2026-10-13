package com.moneyday.backend.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.moneyday.backend.entity.Liability;
import com.moneyday.backend.entity.TodoItem;
import com.moneyday.backend.mapper.LiabilityMapper;
import com.moneyday.backend.mapper.TodoItemMapper;
import com.moneyday.backend.service.LiabilityService;
import com.moneyday.backend.service.TodoService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Lazy;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
public class TodoServiceImpl implements TodoService {

    @Autowired
    private TodoItemMapper todoItemMapper;

    @Autowired
    private LiabilityMapper liabilityMapper;

    @Autowired
    @Lazy
    private LiabilityService liabilityService;

    @Override
    public List<TodoItem> getTodos(String status) {
        QueryWrapper<TodoItem> query = new QueryWrapper<>();
        if (status != null && !status.trim().isEmpty() && !"ALL".equalsIgnoreCase(status)) {
            query.eq("status", status.toUpperCase());
        }
        query.orderByDesc("id");
        return todoItemMapper.selectList(query);
    }

    @Override
    public long countPending() {
        return todoItemMapper.selectCount(new QueryWrapper<TodoItem>().eq("status", "PENDING"));
    }

    @Override
    public void dismissTodo(Long id) {
        TodoItem item = todoItemMapper.selectById(id);
        if (item != null) {
            item.setStatus("DISMISSED");
            todoItemMapper.updateById(item);
        }
    }

    @Override
    public void resolveTodo(Long id) {
        TodoItem item = todoItemMapper.selectById(id);
        if (item != null) {
            item.setStatus("RESOLVED");
            todoItemMapper.updateById(item);
        }
    }

    @Override
    public void resolveTodoByBiz(String type, String bizId) {
        if (type == null || bizId == null) return;
        List<TodoItem> items = todoItemMapper.selectList(
                new QueryWrapper<TodoItem>()
                        .eq("type", type)
                        .eq("biz_id", bizId)
                        .eq("status", "PENDING")
        );
        for (TodoItem item : items) {
            item.setStatus("RESOLVED");
            todoItemMapper.updateById(item);
        }
    }

    @Override
    public void createTodoIfNotExists(String type, String title, String content, String bizId) {
        QueryWrapper<TodoItem> query = new QueryWrapper<TodoItem>()
                .eq("type", type)
                .eq("biz_id", bizId);
        
        // 如果是心愿达成或周期账单，只要有 PENDING 或 DISMISSED 就不重复打扰
        if ("WISHLIST_REACHED".equals(type) || "CYCLE_FIXED_ITEMS".equals(type)) {
            query.in("status", "PENDING", "DISMISSED");
        } else {
            // 分期逾期：若已有 PENDING 则不重复新建
            query.eq("status", "PENDING");
        }
        query.last("LIMIT 1");

        TodoItem existing = todoItemMapper.selectOne(query);
        if (existing == null) {
            TodoItem newItem = new TodoItem();
            newItem.setType(type);
            newItem.setTitle(title);
            newItem.setContent(content);
            newItem.setBizId(bizId);
            newItem.setStatus("PENDING");
            todoItemMapper.insert(newItem);
        }
    }

    @Override
    @Transactional
    public void retryLiabilityRepayment(Long todoId, Long accountId) {
        TodoItem item = todoItemMapper.selectById(todoId);
        if (item == null) {
            throw new IllegalArgumentException("待办事项不存在");
        }
        if (!"LIABILITY_OVERDUE".equals(item.getType())) {
            throw new IllegalArgumentException("非分期扣款待办事项");
        }
        Long liabilityId = Long.parseLong(item.getBizId());
        Liability liability = liabilityMapper.selectById(liabilityId);
        if (liability == null || "SETTLED".equalsIgnoreCase(liability.getStatus())) {
            item.setStatus("RESOLVED");
            todoItemMapper.updateById(item);
            return;
        }

        // 调用还款（还 1 期），传入指定的扣款账户
        liabilityService.repayPeriods(liabilityId, 1, liability.getPeriodAmount(), accountId);

        // 核销该待办
        item.setStatus("RESOLVED");
        todoItemMapper.updateById(item);
    }
}
