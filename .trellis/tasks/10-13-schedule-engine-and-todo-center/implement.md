# 实施计划与任务清单：定时任务引擎与待办中心

## Phase 1: 数据库与基础层建设
- [x] 1.1 在 MySQL 执行 DDL 创建 `todo_item` 表，并在 `schema.sql` 中同步表定义。
- [x] 1.2 创建实体类 `TodoItem.java`，定义 MyBatis-Plus 注解与属性字段。
- [x] 1.3 创建 Mapper 接口 `TodoItemMapper.java`。

## Phase 2: 后端待办服务与业务联动闭环
- [x] 2.1 编写 `TodoService` 及 `TodoServiceImpl`：
  - 实现待办查询（支持按状态过滤）、未读总数统计；
  - 实现待办核销通用方法 `resolveTodo(type, bizId)`；
  - 实现忽略待办 `dismissTodo(id)`；
  - 实现分期还款失败待办的立即补扣 `retryLiabilityRepayment(todoId, accountId)`。
- [x] 2.2 编写 `TodoController`，暴露 REST API 接口。
- [x] 2.3 联动改造 `LiabilityServiceImpl`：
  - 改造分期还款巡检逻辑，严格落实“优先默认账户，仅在其他单一账户余额可全额覆盖时降级，全系统不足严禁扣款并生成 `LIABILITY_OVERDUE` 待办”；
  - 在分期还款成功（自动或手动提前还期/结清）时，触发核销对应的待办项；
- [x] 2.4 联动改造 `WishlistServiceImpl`：
  - 在心愿成功兑现时，触发核销对应的 `WISHLIST_REACHED` 待办项。

## Phase 3: 后端定时引擎与开机补偿
- [x] 3.1 开启 Spring `@EnableScheduling`。
- [x] 3.2 编写 `ScheduleTaskService`：
  - 监听 `ApplicationReadyEvent`，开机启动时自动执行完整巡检；
  - 配置每日凌晨 `00:05` cron 定时任务；
  - 实现三大作业：周期滚动自检、分期到期智能扣款自检、心愿达成门槛自检。

## Phase 4: 前端待办中心与导航组件开发
- [x] 4.1 编写 `TodoCenter.vue`：
  - 展示待办卡片列表，区分分期扣款失败（警告）、新周期账单提醒（信息）、心愿达成（达成）；
  - 实现分期失败的【立即补扣】操作（支持弹窗切换账户）；
  - 实现心愿达成的【立即兑现】操作与【忽略】操作；
  - 实现周期账单的【前往核对】快捷跳转。
- [x] 4.2 配置前端路由 `/todos`。
- [x] 4.3 改造 `App.vue`：在顶部导航菜单新增「待办中心」，并使用 Ant Design `a-badge` 显示实时未处理数量。

## Phase 5: 综合验证与质量检查
- [x] 5.1 后端单元测试/启动验证，验证开机自检与接口功能。
- [x] 5.2 前端构建验证（`vue-tsc` + `vite build`）。
- [x] 5.3 模拟各种边界场景（降级扣款、余额不足生成待办、手动补扣成功核销、心愿达成核销）。
