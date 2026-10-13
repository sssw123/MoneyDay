# 技术方案设计：定时任务引擎与待办中心

## 1. 架构总览

本方案通过后台定时调度引擎（Spring `@Scheduled` + `ApplicationReadyEvent`）实现系统的自动化主动巡检，并引入持久化的 `todo_item` 实体作为异常兜底、业务提醒与人机交互的统一载体。

```mermaid
flowchart TD
    cron["每日凌晨 Cron (00:05)"] --> Engine["ScheduleTaskService"]
    boot["开机启动 (ApplicationReadyEvent)"] --> Engine

    Engine --> C1["1. 周期滚动巡检"]
    Engine --> C2["2. 分期智能扣款巡检"]
    Engine --> C3["3. 心愿达成巡检"]

    C1 --> |跨周期| R1["生成新周期快照 cycle_record"]
    C1 --> R2["生成新周期账单待办 (CYCLE_FIXED_ITEMS)"]

    C2 --> |默认账户余额足| Pay1["扣款成功 -> 流水入账 -> 顺延下期"]
    C2 --> |默认不足但其他单账户足| Pay2["降级单账户扣款 -> 流水入账 -> 顺延下期"]
    C2 --> |均不足| Fail["分文不扣 -> 生成/保持分期还款失败待办 (LIABILITY_OVERDUE)"]
    Pay1 & Pay2 --> ResolvePay["核销对应还款失败待办 -> RESOLVED"]

    C3 --> |累计结余 >= 心愿金额| Wish["生成心愿达成待办 (WISHLIST_REACHED)"]

    TodoUI["前端 待办中心 (TodoCenter.vue)"] --> |立即补扣 (换账户)| PayRetry["调用 retry-repay 接口 -> 核销待办"]
    TodoUI --> |立即兑现心愿| RealizeWish["选择账户兑现 -> 扣款入账 -> 核销待办"]
    TodoUI --> |忽略| Dismiss["状态置为 DISMISSED"]
```

---

## 2. 数据库设计 (MySQL)

### 新建 `todo_item` 表
```sql
CREATE TABLE IF NOT EXISTS `todo_item` (
    `id` BIGINT AUTO_INCREMENT PRIMARY KEY,
    `type` VARCHAR(30) NOT NULL COMMENT '待办类型: LIABILITY_OVERDUE(分期扣款失败), CYCLE_FIXED_ITEMS(新周期账单提醒), WISHLIST_REACHED(心愿达成)',
    `title` VARCHAR(100) NOT NULL COMMENT '待办标题',
    `content` VARCHAR(255) NOT NULL COMMENT '待办详细说明/金额/失败原因',
    `biz_id` VARCHAR(64) NOT NULL COMMENT '业务关联ID: liability_id, cycle_id, wishlist_id',
    `status` VARCHAR(20) NOT NULL DEFAULT 'PENDING' COMMENT '状态: PENDING(待处理), RESOLVED(已完成/已核销), DISMISSED(已忽略)',
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX `idx_status_type` (`status`, `type`),
    INDEX `idx_biz` (`biz_id`, `type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='待办事项与告警中心表';
```

---

## 3. 定时调度引擎设计 (`ScheduleTaskService`)

### 3.1 触发机制
1. **启用调度**：在 Spring Boot 启动类或配置类添加 `@EnableScheduling`；
2. **每日 Cron**：`@Scheduled(cron = "0 5 0 * * ?")` 每天凌晨 00:05 自动执行；
3. **开机自检补偿**：
   ```java
   @EventListener(org.springframework.boot.context.event.ApplicationReadyEvent.class)
   public void onApplicationReady() {
       log.info("MoneyDay 后端启动完成，开始执行开机自检补偿任务...");
       executeAllChecks();
   }
   ```

### 3.2 核心作业逻辑
1. **`checkAndRollCycle()`**：
   - 查找当前最新的周期记录或默认模板配置；
   - 若 `LocalDate.now().isAfter(latestCycle.getCycleEndDate())`：
     - 调用 `cycleRecordService.getOrCreateSnapshot(...)` 滚动生成当前新周期；
     - 检查该新周期是否存在固收或固支，若存在且尚未生成过对应周期的待办，插入一条 `CYCLE_FIXED_ITEMS` 待办，`biz_id = record.getId()`；
2. **`checkAndExecuteLiabilityRepayments()`**：
   - 遍历 `status = 'REPAYING'` 且 `next_repayment_date <= today` 的分期：
     - 检查默认账户 `default_account_id`，若余额 $\ge$ `period_amount`，选择该账户；
     - 若默认账户不足，从其余账户中筛选 `current_balance >= period_amount` 且余额最大的单一账户进行降级；
     - **扣款成功**：调用 `transactionService.addTransaction`，更新已还期数，下期还款日顺延（或全部还清置为 `SETTLED`），并将该分期的未处理待办更新为 `RESOLVED`；
     - **全系统无任一单账户能覆盖**：严禁扣款！检查是否已有关于该分期未解决的 `LIABILITY_OVERDUE` 待办，若无则新建一条详细待办（指出默认账户余额不足，需要补扣金额 ¥X）。
3. **`checkWishlistMilestones()`**：
   - 获取当前系统 `cumulativeBalance`；
   - 遍历未实现心愿 `is_realized = 0`，若 `cumulativeBalance >= target_amount`：
     - 检查该心愿是否已有 `PENDING` 或 `DISMISSED` 待办，若无则新增 `WISHLIST_REACHED` 待办。

---

## 4. 后端 API 接口设计

| 方法 | 路径 | 说明 | 入参 / 返回 |
| :--- | :--- | :--- | :--- |
| `GET` | `/api/todos` | 获取待办列表 | 参数 `status`（默认 PENDING），返回 `List<TodoItem>` |
| `GET` | `/api/todos/pending-count` | 未处理待办数量 | 返回 `{ count: 2 }` |
| `POST` | `/api/todos/{id}/dismiss` | 忽略待办 | 将状态置为 `DISMISSED` |
| `POST` | `/api/todos/{id}/retry-repay` | 分期还款失败待办的立即补扣 | Body: `{ accountId?: Long }`，成功扣款并核销待办 |

---

## 5. 前端界面设计 (`TodoCenter.vue` & `App.vue`)

1. **`App.vue` 导航栏联动**：
   - 一级导航菜单新增【待办中心】（路由 `/todos`）；
   - 挂载 `a-badge`，显示 `pendingCount`，有未处理待办时醒目提示；
2. **`TodoCenter.vue` 界面组件**：
   - **顶部统计与过滤**：全部待办 / 仅看待处理 / 历史记录；
   - **待办列表卡片**：
     - **分期扣款失败**：警告卡片（附带还款金额、期数、当前各账户余额），点击【立即补扣】弹出账户选择框；
     - **周期账单提醒**：信息卡片，展示新周期的待确认固收/固支项目，点击【前往核对】快捷跳至周期预算表；
     - **心愿达成通知**：达成徽章卡片，提示结余已攒够，点击【立即兑现】弹出确认扣款账户窗口，支持【暂不兑现/忽略】。
