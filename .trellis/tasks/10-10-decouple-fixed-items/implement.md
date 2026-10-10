# 执行计划: 固收/固支/固存 JSON 解耦

## 1. 数据库与实体层
- [ ] 执行 MySQL `ALTER TABLE` 语句，移除旧的 `fixed_deposit`/`fixed_income` 字段，增加 `fixed_items JSON` 字段。
- [ ] 创建 `com.moneyday.backend.entity.FixedItem` (id, name, type, amount, isBooked)。
- [ ] 更新 `CycleTemplate.java` 和 `CycleRecord.java`，配置 `@TableName(autoResultMap = true)` 与 `@TableField(typeHandler = JacksonTypeHandler.class)`。

## 2. 后端服务层
- [ ] 调整 `CycleRecordServiceImpl.getOrCreateSnapshot`：拷贝模板的 `fixedItems` 到快照，初始化 `isBooked = false`。
- [ ] 调整 `CycleRecordServiceImpl.getRecentCycles`：结余公式更新为 `income - expense - (sum of DEPOSIT)`，并在返回体暴露 `fixedItems`。
- [ ] 调整 `CycleTemplateServiceImpl.updateCurrentAndFutureCycles`：实现基于 ID 继承 `isBooked` 状态的合并算法。
- [ ] 废弃原有的 `bookIncome` 接口和 `updateFixedDeposit` 接口。
- [ ] 新增统一的记账接口 `POST /api/cycles/{id}/book-item/{itemId}`，实现生成交易、扣减余额、更新 `isBooked` 的闭环。

## 3. 前端层
- [ ] `Settings.vue`：
  - 移除原表单中的 `defaultFixedDeposit` 和 `defaultFixedIncome`。
  - 引入动态表单组件，支持增删改 `fixedItems` 数组。
- [ ] `BudgetAndTarget.vue`：
  - 更新 Columns，移除固存单列，新增「固定项目」列，渲染标签集合。
  - 前端结余高亮显示。
  - 更新弹窗逻辑（复用或重写为一个统一的 `itemVisible` 弹窗），适配固收（选转入账户）和固支（选扣款账户）的语境。
  - 对接 `/book-item/{itemId}` 接口。

## 4. 验证检查
- [ ] 验证：在模板中新增一条固收、一条固支、一条固存。
- [ ] 验证：进入看板，查看当月是否正确继承 3 个标签。结余扣减了固存。
- [ ] 验证：点击固支标签支付，余额正确扣减，标签变灰，结余扣减。
- [ ] 验证：修改模板中某个标签的金额，回到看板，已支付的标签状态保留，未支付的金额正确更新。
