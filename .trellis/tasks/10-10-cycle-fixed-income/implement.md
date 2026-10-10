# 执行计划: 新增周期固收功能

## 1. 数据库迁移

- [ ] `ALTER TABLE cycle_template ADD COLUMN default_fixed_income DECIMAL(18,2) NOT NULL DEFAULT 0.00`
- [ ] `ALTER TABLE cycle_record ADD COLUMN fixed_income DECIMAL(18,2) NOT NULL DEFAULT 0.00`
- [ ] `ALTER TABLE cycle_record ADD COLUMN is_fixed_income_booked TINYINT(1) NOT NULL DEFAULT 0`

## 2. 后端实体类

- [ ] `CycleTemplate`：新增 `defaultFixedIncome` 字段 + getter/setter
- [ ] `CycleRecord`：新增 `fixedIncome`、`isFixedIncomeBooked` 字段 + getter/setter

## 3. 后端 Service 逻辑

- [ ] `CycleRecordServiceImpl.getOrCreateSnapshot()`：创建快照时写入 `fixedIncome`（from template）
- [ ] `CycleRecordServiceImpl.getRecentCycles()`：返回 map 中加入 `fixedIncome`、`isFixedIncomeBooked`
- [ ] `CycleTemplateServiceImpl.update()` / `setDefault()`：同步更新当前及未来快照的 `fixed_income`

## 4. 新增接口

- [ ] `CycleRecordController`：新增 `POST /api/cycles/{id}/book-income`
- [ ] `CycleRecordServiceImpl`：实现 `bookIncome(id, accountId, amount, date)` 逻辑（校验 → 插入 Transaction → 更新账户余额 → 更新快照）

## 5. 前端

- [ ] `Settings.vue`：新增默认固收输入行，保存到模板
- [ ] `BudgetAndTarget.vue`：周期表每行新增「到账」按钮（已到账变灰）
- [ ] `BudgetAndTarget.vue`：实现到账弹窗（金额可改 + 账户选择 + 日期选择）
- [ ] `BudgetAndTarget.vue`：确认调用接口，成功刷新列表

## 验证

- [ ] 设置固收 → 新周期快照自动继承
- [ ] 修改模板固收 → 当前及未来快照同步，历史不变
- [ ] 点击到账 → 弹窗预填正确 → 确认后收入增加、按钮变灰
- [ ] 历史周期到账 → 日期默认周期首日 → 收入正确记录
- [ ] 重复点击已到账按钮 → 按钮灰色不可点
