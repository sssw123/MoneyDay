# 技术设计: 固收/固支/固存 JSON 标签化解耦

## 1. 数据结构 (JSON Schema)

明细项目 `FixedItem` 的 JSON 结构：
```json
[
  {
    "id": "1697204918231",      // 唯一标识 (时间戳或 UUID)
    "name": "房租",              // 项目名称
    "type": "EXPENSE",          // 类型: INCOME(固收) / EXPENSE(固支) / DEPOSIT(固存)
    "amount": 2000.00,          // 金额
    "isBooked": false           // 是否已到账/已支付 (仅在 CycleRecord 中有意义)
  }
]
```

## 2. 数据库变更

移除旧字段，引入 `fixed_items` (JSON 类型)：

```sql
ALTER TABLE cycle_template DROP COLUMN default_fixed_deposit;
ALTER TABLE cycle_template DROP COLUMN default_fixed_income;
ALTER TABLE cycle_template ADD COLUMN fixed_items JSON;

ALTER TABLE cycle_record DROP COLUMN fixed_deposit;
ALTER TABLE cycle_record DROP COLUMN fixed_income;
ALTER TABLE cycle_record DROP COLUMN is_fixed_income_booked;
ALTER TABLE cycle_record ADD COLUMN fixed_items JSON;
```

## 3. 后端架构 (MyBatis-Plus)

### 3.1 实体映射
- 新增 `FixedItem` Java POJO。
- `CycleTemplate` 和 `CycleRecord` 类需添加 `@TableName(autoResultMap = true)` 以支持 JSON 反序列化。
- `fixedItems` 字段使用 `@TableField(typeHandler = JacksonTypeHandler.class)` 注解映射到 `List<FixedItem>`。

### 3.2 同步算法 (模板修改 -> 影响快照)
当模板的标签数组改变时，需要更新所有 `cycle_end_date >= today` 的快照。由于快照中可能已有被用户标记为 `isBooked = true` 的流水，合并策略为：
- 遍历所有符合条件的 `CycleRecord`。
- 将模板的新 `fixedItems` 赋予给快照，但如果新旧 items 中存在相同的 `id`，则继承旧 item 的 `isBooked` 状态。
- 批量更新入库。

### 3.3 记账接口
```http
POST /api/cycles/{id}/book-item/{itemId}
Body: { accountId: 1, date: "2023-10-10", amount: 2000 }
```
逻辑：
- 找到 `CycleRecord` 并在 `fixedItems` 中找到匹配的 `itemId`。
- 校验 `isBooked == false`。
- 生成真实 `Transaction`。更新账户余额。
- 修改该 item 的 `isBooked = true`，并（可选）更新其 `amount` 为实际填写的 amount，写回 DB。

## 4. 前端交互 (Vue3 + Ant Design)

### 4.1 Settings.vue (模板设置)
在编辑模板的表单中，替换原有的两个数字输入框为**动态列表**。
支持：添加项目、选择类型(下拉)、输入名称、输入金额、删除项目。

### 4.2 BudgetAndTarget.vue (周期表)
- **展示**：在周期表新增一列「固定项目」。用不同的颜色标签渲染这组 JSON。
  - 固存：普通标签，显示金额。
  - 固收/固支：交互式按钮标签。如果是 `isBooked: false` 显示为高亮可点击；`isBooked: true` 显示为灰色。
- **结余计算调整**：`balance = income - expense - sum(DEPOSIT items)`。不再减去单一的 `fixedDeposit`。
- **点击交互**：点击未处理的固收/固支标签，弹出一个复用的“入账/支付”弹窗，走 `/book-item/{itemId}` 接口。
