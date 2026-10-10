# 执行计划: 目标按累计结余自动推进与实现

## 1. 数据库升级
- [ ] 执行 MySQL `ALTER TABLE target DROP COLUMN allocated_amount`。
- [ ] 执行 MySQL `ALTER TABLE target ADD COLUMN start_date DATE NULL`。
- [ ] 初始化已有目标的 `start_date` 为创建日期，修改为 `NOT NULL`。

## 2. 后端开发
- [ ] 更新 `Target.java`：移除 `allocatedAmount`，增加 `startDate` 字段及 getter/setter。
- [ ] 在 `CycleRecordService` 与 `CycleRecordServiceImpl` 中实现 `getTotalCumulativeBalance()`。
- [ ] 在 `TargetService` 与 `TargetServiceImpl` 的 `realizeTarget` 中增加强拦截：当 `累计结余 < 目标金额` 时抛出异常禁止实现。
- [ ] 新增 `GET /api/targets/cumulative-balance` 接口供前端实时获取累计结余。
- [ ] 更新 `StatServiceImpl.java` 中对 `targetAllocated` 的计算引用（因字段废除，可返回 0 或返回累计已实现的金额）。

## 3. 前端开发 (`BudgetAndTarget.vue` & `Dashboard.vue`)
- [ ] `BudgetAndTarget.vue`：
  - 表格移除「已存金额」列，新增「开始时间」列。
  - 目标新建/编辑表单移除「已存金额」，新增「开始时间」日期选择（默认当天）。
  - 调用接口获取 `cumulativeBalance`。
  - 进度条按 `(cumulativeBalance / targetAmount) * 100%` 动态渲染。
  - 「实现目标」按钮：当 `cumulativeBalance < targetAmount` 时禁用并标灰。
- [ ] `Dashboard.vue`：
  - 移除已废除的 `targetAllocated` 概念，调整为展示「累计结余」推进情况。
- [ ] 编译前后端并验证。
