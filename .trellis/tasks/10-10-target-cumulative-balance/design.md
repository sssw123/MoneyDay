# 技术设计: 目标按累计结余自动推进与实现

## 1. 数据库升级
```sql
ALTER TABLE target DROP COLUMN allocated_amount;
ALTER TABLE target ADD COLUMN start_date DATE NULL;
UPDATE target SET start_date = DATE(created_at) WHERE start_date IS NULL;
ALTER TABLE target MODIFY COLUMN start_date DATE NOT NULL;
```

## 2. 后端设计

### 2.1 累计结余计算服务
在 `CycleRecordService` 中增加一个方法：
```java
BigDecimal getTotalCumulativeBalance();
```
实现逻辑：
- 遍历所有周期的结余之和。
- 或者通过 SQL 直接高效统计：
  `所有收入总和 - 所有支出总和 - 所有周期固存总和`。
  因为：
  每个周期的结余 = 该周期收入 - 该周期支出 - 该周期固存。
  所有周期的结余之和 = (所有收入总和) - (所有支出总和) - (所有周期固存之和)。
  - `所有收入总和` = `SELECT IFNULL(SUM(amount), 0) FROM transaction WHERE type = 1`
  - `所有支出总和` = `SELECT IFNULL(SUM(amount), 0) FROM transaction WHERE type = 2`
  - `所有周期固存之和` = 遍历所有 `cycle_record` 中的 `fixedItems` 中 `type == 'DEPOSIT'` 的金额之和。
  这个公式在数学上严格等价，且性能最好！

### 2.2 `Target` 实体与接口
- `Target.java`:
  - 移除 `allocatedAmount`。
  - 增加 `private LocalDate startDate;`。
- `TargetServiceImpl.java`:
  - `realizeTarget(Long id, Long accountId)`:
    - 校验 `isRealized == 0`。
    - 计算 `totalCumulativeBalance = cycleRecordService.getTotalCumulativeBalance()`。
    - 如果 `totalCumulativeBalance.compareTo(target.getTargetAmount()) < 0`，抛出 `IllegalArgumentException("累计结余不足，无法实现该目标！当前累计结余: " + totalCumulativeBalance)`。
    - 标记 `target.setIsRealized(1)`。
    - 生成 Transaction (type=2, amount=targetAmount, accountId=accountId, remark="实现目标：" + target.getName())。
    - 扣减账户余额。
- `TargetController.java`:
  - 增加一个辅助端点，或者在获取目标列表/统计时返回 `cumulativeBalance`。
  - 例如 `GET /api/targets/overview` 返回 `{ targets: [...], cumulativeBalance: 4980 }`。
  或者 `TargetDTO` 包含 `cumulativeBalance`。

## 3. 前端设计 (`BudgetAndTarget.vue`)
- 列变更：
  - 移除「已存金额」列。
  - 新增「开始时间」列 (`column.key = 'startDate'`)。
- 弹窗变更：
  - 移除 `allocatedAmount` 输入框。
  - 新增 `startDate` 日期选择器（默认 `new Date().toISOString().split('T')[0]`）。
- 进度计算：
  - 前端获取全局 `cumulativeBalance`。
  - 目标行的进度百分比：
    ```ts
    const getProgress = (record: any) => {
      if (record.isRealized === 1) return 100;
      if (!cumulativeBalance.value || cumulativeBalance.value <= 0) return 0;
      return Math.min(100, Math.round((cumulativeBalance.value / record.targetAmount) * 100));
    };
    ```
- 实现目标按钮控制：
  - `:disabled="record.isRealized === 1 || cumulativeBalance < record.targetAmount"`
  - 若 `cumulativeBalance < record.targetAmount`，tooltip 提示“累计结余不足，还需差额”。
