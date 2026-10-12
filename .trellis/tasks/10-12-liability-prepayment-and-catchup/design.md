# 技术设计: 透支还款与历史分期补录优化

## 1. 数据架构与表结构改造

### 1.1 数据库结构升级 (`liability` 表)
在 MySQL `liability` 表中增加 `next_repayment_date` 字段：
```sql
ALTER TABLE `liability`
ADD COLUMN `next_repayment_date` DATE NULL COMMENT '下一次应还日期' AFTER `repayment_day`;
```
对于已有数据，通过更新脚本基于 `start_date` 和 `repayment_day` 初始化默认值：
```sql
UPDATE `liability` 
SET `next_repayment_date` = DATE_ADD(start_date, INTERVAL current_period MONTH)
WHERE `status` = 'REPAYING' AND `next_repayment_date` IS NULL;
```

### 1.2 实体类更新
- `Liability.java`:
  - 增加 `@TableField(value = "next_repayment_date") private LocalDate nextRepaymentDate;`
- `LiabilityVO.java`:
  - 增加 `private LocalDate nextRepaymentDate;`

---

## 2. 后端接口与核心算法设计

### 2.1 录入与编辑逻辑 (`LiabilityServiceImpl`)
- **新增分期 (`addLiability`)**：
  - 用户传入 `currentPeriod`（若未传则默认 0）。
  - 用户传入 `nextRepaymentDate`（若未传，则根据 `startDate`、`repaymentDay` 与 `currentPeriod` 自动推算下一次到期日）。
  - **绝不生成历史交易流水**，不改动账户余额。
- **编辑分期 (`updateLiability`)**：
  - 允许微调已还期数与下一次还款日，重新计算待还剩余期数。

### 2.2 提前还期接口 (`repayPeriods`)
- **API 定义**：
  `POST /api/liabilities/{id}/repay`
  ```json
  {
    "periods": 1,
    "amount": 500.00,
    "accountId": 1
  }
  ```
- **核心逻辑**：
  1. 校验负债状态必须为 `REPAYING`。
  2. 校验 `periods >= 1 && periods <= remainingPeriods`。
  3. 校验账户存在且余额充足。
  4. 生成一条支出交易流水：
     - 类型：`2 (支出)`
     - 分类：`liability.categoryId` (分期还款)
     - 金额：`amount`
     - 关联：`liability_id = liability.getId()`
     - 备注：`【提前还款】{name} (第{curP + 1}期 ~ 第{curP + periods}期)`
  5. 推进期数：`liability.setCurrentPeriod(curP + periods)`。
  6. 顺延排期：`liability.setNextRepaymentDate(nextRepaymentDate.plusMonths(periods))`（对齐每月还款日）。
  7. 若 `liability.getCurrentPeriod() >= liability.getTotalPeriods()`：
     - `liability.setStatus("SETTLED")`
     - `liability.setSettledAt(LocalDateTime.now())`
     - `liability.setNextRepaymentDate(null)`
  8. 保存更新。

### 2.3 提前结清接口 (`settleLiability`)
- **API 定义**：
  `POST /api/liabilities/{id}/settle`
  ```json
  {
    "accountId": 1,
    "settleAmount": 4500.00
  }
  ```
- **核心逻辑**：
  1. 扣除账户 `settleAmount`，生成结清流水（备注：`【提前结清】{name} (结清剩余{N}期)`）。
  2. `liability.setCurrentPeriod(liability.getTotalPeriods())`。
  3. `liability.setStatus("SETTLED")`。
  4. `liability.setSettledAt(LocalDateTime.now())`。
  5. `liability.setNextRepaymentDate(null)`。

### 2.4 自动还款引擎防重重构 (`checkAndExecuteDueRepayments`)
废弃旧有易碎的“按当前周期日期区间查流水”判定，全面切换为**以排期为准**的绝对防重机制：
```java
for (Liability l : activeLiabilities) {
    if (l.getNextRepaymentDate() == null) continue;
    
    // 未到排期还款日，直接跳过 (即使今天在周期内，只要未到下一次应还日就不扣)
    if (today.isBefore(l.getNextRepaymentDate())) {
        continue;
    }
    
    // 执行一期自动扣款 (支持降级选择最大余额账户)
    executeSingleRepayment(l);
    
    // 顺延下一次排期
    int nextPeriod = l.getCurrentPeriod() + 1;
    l.setCurrentPeriod(nextPeriod);
    if (nextPeriod >= l.getTotalPeriods()) {
        l.setStatus("SETTLED");
        l.setSettledAt(LocalDateTime.now());
        l.setNextRepaymentDate(null);
    } else {
        l.setNextRepaymentDate(l.getNextRepaymentDate().plusMonths(1));
    }
    liabilityMapper.updateById(l);
}
```

---

## 3. 前端界面设计 (`Liability.vue`)

### 3.1 录入/编辑分期弹窗
- 新增表单项：
  - **已还期数**：数字输入框，初始默认为 0，限制 0 ~ 总期数。
  - **下一次还款日**：日期选择器，填写总期数、还款日及已还期数后自动推算推荐日期，支持手动选择。

### 3.2 还款操作弹窗升级
将原单一的「提前结清」弹窗重构为双 Tab 模式：
- **Tab 1: 提前还期**
  - 选择归还期数（数字步进器，1 ~ 待还剩余期数）。
  - 还款金额：自动联动 `期数 * 每期金额`，保持可编辑微调。
  - 选择扣款账户。
  - 提示说明：还款后下次扣款日将自动顺延对应月数，本周期不再重复扣款。
- **Tab 2: 提前结清**
  - 预填剩余待还总额，支持优惠折扣微调。
  - 选择扣款账户。
  - 确认后一键全部结清。

### 3.3 列表与进度展示
- 表格列中增加「下期还款日」展示（清晰标明下一次扣款的具体年月日）。
- 进度条显示：`已还 {currentPeriod} / {totalPeriods} 期`，百分比清晰。
