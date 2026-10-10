# 架构设计 (Technical Design)

## 数据流与模型变更

1. **CycleTemplate (周期模板)**
   - 增加字段 `default_fixed_deposit` (DECIMAL(18,2))：存储全局默认的固存金额。

2. **CycleRecord (周期记录 - 新增实体)**
   - 目的：实现历史周期数据的“快照固化隔离”。
   - 字段：
     - `id` (PK, AUTO)
     - `cycle_start_date` (DATE)
     - `cycle_end_date` (DATE)
     - `fixed_deposit` (DECIMAL(18,2)) - 当前周期生效的固存金额
     - `created_at`, `updated_at`

3. **目标实现机制 (Target Realization)**
   - 前端在 Target 卡片中新增一个“实现目标”按钮。
   - 点击后，后端生成一条类型为 `2` (支出) 的 Transaction，将目标金额实际从账户扣除。同时可以标记该 Target 的状态为“已实现 (is_realized)”。
   *(需在 Target 表中新增 `is_realized` 字段)*

## 后端接口约定
- **获取周期列表**: `/api/cycles`
  - 返回最近 N 个月的周期记录快照，计算每个周期的总收入、总支出、固存，然后返回给前端进行结余渲染。
  - 如果某个周期的 `CycleRecord` 不存在，则按 `CycleTemplate` 的 `default_fixed_deposit` 自动生成快照并存入数据库，然后再返回。
- **更新指定周期固存**: `PUT /api/cycles/{id}/fixed-deposit`
  - 更新单个 `CycleRecord` 的固存。

## 兼容性与迁移说明
- `Budget` 相关表结构和接口保留，但不与新功能交互，保证前端历史代码（如果有其他地方调用）不崩溃。
- `CycleTemplate` 添加新字段需要进行数据库 DDL 变更。
