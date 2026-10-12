# 技术设计: 未来计划架构与透支分期管理

## 1. 架构与边界设计

### 1.1 数据库物理模型 (DDL)

```sql
-- 1. 心愿单表 (从原有 target 剥离)
CREATE TABLE IF NOT EXISTS `wishlist` (
    `id` BIGINT AUTO_INCREMENT PRIMARY KEY,
    `name` VARCHAR(100) NOT NULL COMMENT '心愿名称',
    `target_amount` DECIMAL(12, 2) NOT NULL COMMENT '心愿金额',
    `is_realized` TINYINT NOT NULL DEFAULT 0 COMMENT '0: 心愿中, 1: 已实现',
    `start_date` DATE NOT NULL COMMENT '立项时间',
    `deadline` DATE NULL COMMENT '期望日期',
    `realized_account_id` BIGINT NULL COMMENT '扣款账户ID',
    `realized_at` DATETIME NULL COMMENT '实现时间',
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 2. 长期目标表 (专属于正向资产沉淀)
-- 保留 target 表结构，移除/忽略旧 type 字段或设为统一，仅用于 LONG_TERM 目标

-- 3. 透支/分期负债表 (新增全新实体)
CREATE TABLE IF NOT EXISTS `liability` (
    `id` BIGINT AUTO_INCREMENT PRIMARY KEY,
    `name` VARCHAR(100) NOT NULL COMMENT '分期/负债名称',
    `principal` DECIMAL(12, 2) NOT NULL COMMENT '分期本金',
    `total_amount` DECIMAL(12, 2) NOT NULL COMMENT '总待还本息总额',
    `total_periods` INT NOT NULL COMMENT '总期数',
    `current_period` INT NOT NULL DEFAULT 0 COMMENT '已还期数',
    `period_amount` DECIMAL(12, 2) NOT NULL COMMENT '每期应还金额',
    `rate_type` VARCHAR(20) NOT NULL DEFAULT 'NONE' COMMENT 'NONE: 免息, FEE: 每期手续费率, APR: 年化等额本息',
    `interest_rate` DECIMAL(8, 4) NOT NULL DEFAULT 0.0000 COMMENT '利率/费率百分比',
    `repayment_day` INT NOT NULL COMMENT '每月还款日 (1-31)',
    `default_account_id` BIGINT NOT NULL COMMENT '默认扣款账户',
    `category_id` BIGINT NOT NULL COMMENT '支出记账分类ID',
    `auto_cycle_fixed_expense` TINYINT NOT NULL DEFAULT 1 COMMENT '1: 自动纳入周期固定支出, 0: 否',
    `status` VARCHAR(20) NOT NULL DEFAULT 'REPAYING' COMMENT 'REPAYING: 还款中, SETTLED: 已结清',
    `start_date` DATE NOT NULL COMMENT '首期起算日期',
    `settled_at` DATETIME NULL COMMENT '提前结清时间',
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 4. 流水表支持透支溯源
ALTER TABLE `transaction` ADD COLUMN IF NOT EXISTS `liability_id` BIGINT NULL COMMENT '关联的负债ID';
```

---

## 2. 后端核心流程与接口契约

### 2.1 自动扣款引擎 (Auto-Repayment Engine)
- **触发时机**：应用启动时、每次进入仪表盘或周期表接口时触发幂等检查。
- **扣款判定**：
  1. 查询所有 `status = 'REPAYING'` 且 `auto_cycle_fixed_expense = 1` 的负债。
  2. 针对当期周期，若还款日已到且当期尚未生成该负债的还款流水：
     - **账户选择**：检查 `default_account_id` 余额，若余额 `>= period_amount`，选用默认账户；否则在系统所有账户中寻找 `current_balance` 最大的账户扣款；
     - **流水生成**：生成一条支出流水（`type = 2`, `amount = period_amount`, `category_id = liability.category_id`, `liability_id = liability.id`, 备注格式 `【分期还款】名称 (X/N期)`）；
     - **负债进度推进**：`current_period = current_period + 1`；若 `current_period >= total_periods`，则 `status = 'SETTLED'`；
     - **快照更新**：当期 `CycleRecord` 的固定支出项标记为已完成。

### 2.2 提前结清逻辑 (Early Settlement)
- 接口：`POST /api/liabilities/{id}/settle`
- 参数：`{ accountId: Long, settleAmount: BigDecimal }`
- 业务处理：
  1. 校验负债处于 `REPAYING` 状态；
  2. 生成支出流水（`amount = settleAmount`，备注 `【提前结清】名称 剩余 X 期全额还款`）；
  3. 更新负债：`current_period = total_periods`, `status = 'SETTLED'`, `settled_at = now()`；
  4. 从当期及后续周期的固定支出中移除该负债项。

### 2.3 资产与指标计算
- `totalLiabilities = SUM(total_amount - (current_period * period_amount))` 针对所有未结清负债。
- `availableNetAssets = totalAssets - totalLiabilities`。
- 长期资产目标缺口计算直接使用 `availableNetAssets`。

---

## 3. 前端路由与界面架构

### 3.1 路由结构 (`router/index.ts`)
- `/dashboard` -> 仪表盘
- `/transactions` -> 流水明细
- `/accounts` -> 账户管理
- `/categories` -> 分类管理
- `/budget` -> 预算（纯周期表视图，原 `BudgetAndTarget.vue` 精简）
- `/plan/targets` -> 未来计划 - 长期目标
- `/plan/wishlist` -> 未来计划 - 心愿单
- `/plan/liabilities` -> 未来计划 - 透支管理
- `/settings` -> 系统设置

### 3.2 侧边栏布局 (`App.vue`)
- 使用 Ant Design Vue `<a-sub-menu key="plan" title="未来计划">`，内置三个子菜单项：`目标`、`心愿单`、`透支`。
- 【预算】独立为一级菜单，内部无 Tab，直观呈现周期表。
