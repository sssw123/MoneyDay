# 执行计划 (Implementation Plan)

## 阶段 1：数据库结构变更与模型更新
- [ ] 1. 数据库 DDL：
  - 在 `cycle_template` 表中添加 `default_fixed_deposit` (DECIMAL(18,2))，默认值 0。
  - 创建 `cycle_record` 表（id, cycle_start_date, cycle_end_date, fixed_deposit, created_at, updated_at）。
  - 在 `target` 表中添加 `is_realized` (TINYINT(1))，默认 0。
- [ ] 2. 实体类更新：
  - 更新 `CycleTemplate.java`，增加 `defaultFixedDeposit`。
  - 创建 `CycleRecord.java` 实体及 Mapper。
  - 更新 `Target.java`，增加 `isRealized`。

## 阶段 2：后端业务逻辑实现
- [ ] 1. **CycleService 逻辑**：
  - 实现获取周期列表接口，包含快照自动生成逻辑。即查询前检查最近 N 个周期是否在 `cycle_record` 有记录，若无，则用当前 `CycleTemplate` 的值生成。
  - 实现修改单个周期固存的接口。
- [ ] 2. **TargetService 逻辑**：
  - 新增 `realizeTarget(Long targetId)` 接口。
  - 将 Target 标记为已完成，同时调用 TransactionService 创建一笔真实的“支出”流水。

## 阶段 3：前端 UI 与组件开发
- [ ] 1. **移除旧预算管理**：在 `BudgetAndTarget.vue` 或对应组件中，移除顶部的“设置预算”区块及相关的 Axios 调用。
- [ ] 2. **开发周期表视图**：
  - 使用 Ant Design Vue 的 `Table` 组件渲染周期列表。
  - 列：周期（起止日期）、总收入、固存（带编辑按钮）、总支出、周期结余。
  - 颜色渲染：利用 `<span :style="{ color: balance >= 0 ? 'green' : 'red' }">` 处理红绿显示。
- [ ] 3. **实现目标交互**：在目标卡片区域增加“实现目标”按钮，并对接后端新 API，完成后刷新数据与全局看板。

## 检查点 (Review Gates)
- [ ] 测试快照机制：修改全局模板固存，检查是否仅影响未生成的全新周期。
- [ ] 测试目标流转：分配目标不再影响“周期结余”，点击实现目标后，“周期结余”必须因产生的实际支出而相应减少。
