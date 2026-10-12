# 技术设计: 未实现目标预计实现时间推算与心愿单/长期目标双轨管理

## 1. 数据模型与接口设计

### 1.1 数据库结构
```sql
ALTER TABLE target MODIFY COLUMN type VARCHAR(20) NOT NULL DEFAULT 'WISHLIST' COMMENT '目标类型: WISHLIST(心愿单), LONG_TERM(长期资产)';
```

### 1.2 实体与 DTO
- `Target.java`:
  - `private String type = "WISHLIST";`
- `TargetVO.java`:
  - `type`: `WISHLIST` | `LONG_TERM`
  - `progress`: `Integer`
  - `estimatedCompletionDate`: `String`
  - `isEstimatedFallback`: `Boolean`
  - `estimatedReason`: `String`
  - `availableFunds`: `BigDecimal` (心愿单为累计结余，长期目标为总资产)
  - `gap`: `BigDecimal`

## 2. 后端算法设计 (`TargetServiceImpl.java`)

### 2.1 资金源划分
1. **全局累计结余** `cumulativeBalance`: 由 `cycleRecordService.getTotalCumulativeBalance()` 获取。
2. **总资产 / 可用净资产** `totalAssets`: 由 `statMapper.getTotalAssets()` 获取。
   - **核心改动**：心愿单不占用预留资金，因此长期资产目标的可用净资产直接等于 `totalAssets`。
3. **存钱速度 (Velocity)**:
   - 心愿单：取历史平均实际结余（超支则按模板基准结余 `固收 - 固支 - 固存` 保底）。
   - 长期资产目标：取每周期净沉淀 `固存 + 实际平均结余`（超支则按基准净沉淀 `固收 - 固支` 保底）。

### 2.2 实现目标校验 (`realizeTarget`)
- **长期资产目标 (`LONG_TERM`)**:
  - 强校验 `totalAssets >= target.getTargetAmount()`。
  - 强校验所选扣款账户余额 `account.getCurrentBalance() >= target.getTargetAmount()`。
- **心愿单 (`WISHLIST`)**:
  - 强校验所选扣款账户余额 `account.getCurrentBalance() >= target.getTargetAmount()`。
  - 允许在 `cumulativeBalance < target.getTargetAmount()` 时兑现（前端通过确认弹窗提醒用户“将导致结余超支”）。

## 3. 前端设计

### 3.1 目标列表 (`BudgetAndTarget.vue`)
- 新增/编辑弹窗：
  - 单选：`WISHLIST`（心愿单） vs `LONG_TERM`（长期资产目标）。
- 顶部看板：
  - 显示「当前累计结余」与「当前总资产」。
- 表格列：
  - 状态、类型标签（粉色/蓝紫色【心愿单】，紫色【长期资产】）、目标名称、目标金额、进度、预计实现时间、截止日期、操作。
- 实现操作：
  - 心愿单：若累计结余不足，点击实现时弹出确认提示：“当前累计结余不足，兑现此心愿将导致结余超支，确定要任性实现吗？”，用户确认后提交。

### 3.2 首页看板 (`Dashboard.vue`)
- 快捷实现表格同步展示心愿单/长期资产类型标签与预计实现时间。
- 实现按钮提示与确认逻辑同步。
