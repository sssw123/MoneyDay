package com.moneyday.backend;

import com.moneyday.backend.entity.TodoItem;
import com.moneyday.backend.service.ScheduleTaskService;
import com.moneyday.backend.service.TodoService;
import org.junit.jupiter.api.Assertions;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;

import java.util.List;

@SpringBootTest
class BackendApplicationTests {

    @Autowired
    private ScheduleTaskService scheduleTaskService;

    @Autowired
    private TodoService todoService;

    @Test
    void contextLoads() {
        Assertions.assertNotNull(scheduleTaskService);
        Assertions.assertNotNull(todoService);
    }

    @Test
    void testScheduleTaskExecutionAndTodoLifecycle() {
        // 1. 手动触发一次完整巡检，确保三大作业执行无报错
        scheduleTaskService.executeAllChecks();

        // 2. 验证待办中心服务可正常获取数据
        List<TodoItem> pendingList = todoService.getTodos("PENDING");
        Assertions.assertNotNull(pendingList);
        long count = todoService.countPending();
        Assertions.assertEquals(pendingList.size(), count);

        // 3. 验证幂等创建与忽略逻辑
        String mockBizId = "mock_test_999";
        todoService.createTodoIfNotExists("WISHLIST_REACHED", "测试心愿达成", "测试内容说明", mockBizId);
        List<TodoItem> listAfterCreate = todoService.getTodos("PENDING");
        TodoItem created = listAfterCreate.stream().filter(t -> mockBizId.equals(t.getBizId())).findFirst().orElse(null);
        Assertions.assertNotNull(created);

        // 4. 忽略该测试待办
        todoService.dismissTodo(created.getId());
        List<TodoItem> listAfterDismiss = todoService.getTodos("PENDING");
        Assertions.assertTrue(listAfterDismiss.stream().noneMatch(t -> mockBizId.equals(t.getBizId())));

        // 5. 核销测试待办
        todoService.resolveTodo(created.getId());
    }
}
