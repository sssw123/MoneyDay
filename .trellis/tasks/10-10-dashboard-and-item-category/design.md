# 技术设计: 看板周期透视与固定项目分类

## 1. 后端改动

### 1.1 `FixedItem.java`
增加分类属性：
```java
private Long categoryId;
private String categoryName;
```

### 1.2 `CycleRecordServiceImpl.java`
在 `bookItem` 生成 `Transaction` 时：
```java
tx.setCategoryId(targetItem.getCategoryId());
```

### 1.3 `StatDTO.java` 与 `StatServiceImpl.java`
在 `StatDTO` 中增加周期财务拆解字段：
```java
private BigDecimal currentFixedDeposit;   // 本期固存
private BigDecimal currentBalance;        // 本期结余(可能为负=超支)
private BigDecimal currentFinalBalance;   // 最终结余 = 固存 + 结余
```
计算逻辑：
- `currentFixedDeposit` = 统计当前周期内 `type == 'DEPOSIT'` 的金额和。
- `currentBalance` = `currentIncome - currentExpense - currentFixedDeposit`。
- `currentFinalBalance` = `currentFixedDeposit + currentBalance` (实际即 `currentIncome - currentExpense`)。
- 当 `currentBalance < 0` 时，前端标红显示“超支”。

## 2. 前端改动

### 2.1 `Settings.vue`
- 拉取全部分类列表 (`/categories`)。
- 在固定项目行中，新增 `<a-select>` 分类下拉框：
  - 当 `item.type === 'INCOME'` 时，过滤 `type === 1` 的分类。
  - 当 `item.type === 'EXPENSE'` 时，过滤 `type === 2` 的分类。
  - 选择后绑定 `item.categoryId` 和 `item.categoryName`。

### 2.2 `Dashboard.vue`
- 顶层卡片布局升级：
  - 卡片 1：总资产（所有账户余额和）。副标题/标签显示可用资产（总资产 - 目标预留）。
  - 卡片 2：本期固存（¥xxxx）。
  - 卡片 3：本期结余 / 超支。若 >= 0 显示绿色“本期结余: +¥X”，若 < 0 显示红色“本期超支: -¥X”。
  - 卡片 4：本期最终留存（`固存 + 结余`），红绿分明。
- 下方可直观看到目标预留与本周期分类支出饼图。
