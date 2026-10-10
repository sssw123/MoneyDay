# 技术设计: 新增周期固收功能

## 数据库变更

### `cycle_template` 表

```sql
ALTER TABLE cycle_template ADD COLUMN default_fixed_income DECIMAL(18,2) NOT NULL DEFAULT 0.00;
```

### `cycle_record` 表

```sql
ALTER TABLE cycle_record ADD COLUMN fixed_income DECIMAL(18,2) NOT NULL DEFAULT 0.00;
ALTER TABLE cycle_record ADD COLUMN is_fixed_income_booked TINYINT(1) NOT NULL DEFAULT 0;
```

## 后端变更

### 实体类

- `CycleTemplate`：新增 `defaultFixedIncome (BigDecimal)`
- `CycleRecord`：新增 `fixedIncome (BigDecimal)`、`isFixedIncomeBooked (Integer)`

### CycleRecordService

- `getOrCreateSnapshot()`：创建快照时，从模板读取 `defaultFixedIncome` 并写入 `fixedIncome`（与现有 `fixedDeposit` 逻辑对称）
- `getRecentCycles()`：返回数据中加入 `fixedIncome` 和 `isFixedIncomeBooked` 字段

### CycleTemplateService

- `update()` / `setDefault()`：修改模板时，同步更新 `cycle_end_date >= today` 的快照的 `fixed_income` 字段（与现有 `fixed_deposit` 同步逻辑对称）

### 新接口：到账

```
POST /api/cycles/{id}/book-income
Body: { accountId: Long, amount: BigDecimal, date: String }
```

逻辑：
1. 校验 `CycleRecord` 存在且 `isFixedIncomeBooked = 0`
2. 插入 Transaction（type=1, amount, accountId, date, categoryId=null 或固收分类）
3. 更新对应账户 `current_balance += amount`
4. 更新 `cycle_record.fixed_income = amount`，`is_fixed_income_booked = 1`
5. 返回更新后的 CycleRecord 数据

## 前端变更

### Settings.vue

在固存输入行下方新增"默认固收"输入行，调用 `PUT /api/cycle-templates/{id}` 保存。

### BudgetAndTarget.vue（周期表）

- 每行新增「到账」按钮：`isFixedIncomeBooked` 为 false 时正常可用，true 时变灰禁用
- 到账弹窗（复用现有实现目标弹窗结构）：
  - 金额输入框（预填 `fixedIncome`，可改）
  - 账户下拉选择
  - 日期选择（当前周期默认今天，历史周期默认 `cycleStartDate`）
- 确认调用 `POST /api/cycles/{id}/book-income`，成功后刷新周期列表

## 关键约束

- 历史快照（`cycle_end_date < today`）的 `fixed_income` 不随模板变更而更新
- `is_fixed_income_booked` 一旦为 true，接口层拒绝重复调用（返回 400）
- 金额使用 `DECIMAL(18,2)` / `BigDecimal`，禁止 Double
