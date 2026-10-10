# 执行计划: 看板周期透视与固定项目分类

## 1. 后端改动
- [ ] `FixedItem.java` 增加 `categoryId` 与 `categoryName` 字段及 getter/setter。
- [ ] `StatDTO.java` 增加 `currentFixedDeposit` 和 `currentFinalBalance` 字段。
- [ ] `StatServiceImpl.java` 填充这两个字段的计算逻辑。
- [ ] `CycleRecordServiceImpl.java` 在 `bookItem` 记账时，将 `item.getCategoryId()` 赋给 `Transaction.setCategoryId()`。

## 2. 前端改动
- [ ] `Settings.vue`：
  - 获取分类列表 `/categories`。
  - 在固定项目标签行中增加分类下拉框（根据 INCOME/EXPENSE 智能过滤）。
- [ ] `Dashboard.vue`：
  - 重新设计指标卡片，清晰呈现：
    - 总资产 (账户总额)
    - 本期固存
    - 本期结余 / 超支 (红绿区分)
    - 最终结余 = 固存 + 结余 (红绿区分)
    - 目标预留与可用净资产对比
- [ ] 编译前后端并验证。
