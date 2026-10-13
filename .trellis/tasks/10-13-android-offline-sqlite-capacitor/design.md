# Capacitor集成与离线本地SQLite脱机架构 (Technical Design)

## 1. 总体架构 (System Architecture)

```
+-------------------------------------------------------------------------+
|                        Vant 4 移动视图层 (Views)                          |
|  [Dashboard.vue] [Transactions.vue] [Budget.vue] [Plan.vue] [Todos.vue] |
+-------------------------------------------------------------------------+
                                    │
                                    ▼ 调用强类型接口
+-------------------------------------------------------------------------+
|                  TypeScript 业务服务层 (Domain Services)                |
|  - TransactionService  : 记账流水录入、流水回滚、账户余额原子联动            |
|  - CycleService        : 周期起止计算、快照生成、固定项记账与核销            |
|  - LiabilityService    : 分期计算、智能到期扣款、降级扣款、提前结清          |
|  - WishlistService     : 心愿预估天数计算、兑现扣款、撤销退回               |
|  - TargetService       : 净资产目标管理、达成兑现                           |
|  - TodoService         : 待办事件生成、分期逾期补扣、待办核销               |
|  - StatService         : 四大资产统计、周期收支汇总、支出分类饼图计算        |
+-------------------------------------------------------------------------+
                                    │
                                    ▼ 统一 SQL 操作
+-------------------------------------------------------------------------+
|                     底层数据仓储层 (DatabaseManager)                     |
|  - 执行 DDL 建表与数据升级迁移                                           |
|  - 提供参数化 SQL 查询与更新封装: execute(), query(), runTransaction()     |
+-------------------------------------------------------------------------+
                                    │
                  ┌─────────────────┴─────────────────┐
                  ▼                                   ▼
        [Android 原生环境]                      [PC 浏览器调试环境]
   Capacitor Native SQLite              jeep-sqlite / IndexedDB 降级驱动
   (/data/data/.../moneyday.db)             (Web 开发者工具快速调试预览)
```

---

## 2. 数据库设计 (SQLite Schema)

在 SQLite 中采用轻量无外键强依赖的设计，所有金额统一采用 `REAL` 存储，所有日期统一采用 `TEXT (YYYY-MM-DD)` 格式：

```sql
-- 1. 用户表 (单用户)
CREATE TABLE IF NOT EXISTS user (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  username TEXT NOT NULL,
  password TEXT NOT NULL,
  created_at TEXT DEFAULT CURRENT_TIMESTAMP
);

-- 2. 周期模板表
CREATE TABLE IF NOT EXISTS cycle_template (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,
  start_day INTEGER NOT NULL,
  is_default INTEGER DEFAULT 0,
  fixed_items TEXT NULL -- JSON 字符串
);

-- 3. 账户表
CREATE TABLE IF NOT EXISTS account (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,
  type TEXT NOT NULL,
  initial_balance REAL NOT NULL DEFAULT 0.0,
  current_balance REAL NOT NULL DEFAULT 0.0,
  created_at TEXT DEFAULT CURRENT_TIMESTAMP
);

-- 4. 收支分类表
CREATE TABLE IF NOT EXISTS category (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,
  type INTEGER NOT NULL, -- 1=收入, 2=支出
  is_active INTEGER NOT NULL DEFAULT 1,
  created_at TEXT DEFAULT CURRENT_TIMESTAMP
);

-- 5. 账单流水表
CREATE TABLE IF NOT EXISTS transaction_record (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  type INTEGER NOT NULL, -- 1=收入, 2=支出, 3=转账
  amount REAL NOT NULL,
  transaction_date TEXT NOT NULL,
  category_id INTEGER NULL,
  account_id INTEGER NOT NULL,
  to_account_id INTEGER NULL,
  remark TEXT NULL,
  liability_id INTEGER NULL,
  created_at TEXT DEFAULT CURRENT_TIMESTAMP
);

-- 6. 周期快照表
CREATE TABLE IF NOT EXISTS cycle_record (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  cycle_start_date TEXT NOT NULL,
  cycle_end_date TEXT NOT NULL,
  fixed_items TEXT NULL, -- JSON 字符串
  created_at TEXT DEFAULT CURRENT_TIMESTAMP
);

-- 7. 目标表 (净资产目标)
CREATE TABLE IF NOT EXISTS target (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,
  target_amount REAL NOT NULL,
  deadline TEXT NULL,
  start_date TEXT NOT NULL,
  is_realized INTEGER NOT NULL DEFAULT 0,
  created_at TEXT DEFAULT CURRENT_TIMESTAMP
);

-- 8. 心愿单表
CREATE TABLE IF NOT EXISTS wishlist (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,
  target_amount REAL NOT NULL,
  deadline TEXT NULL,
  start_date TEXT NOT NULL,
  is_realized INTEGER NOT NULL DEFAULT 0,
  created_at TEXT DEFAULT CURRENT_TIMESTAMP
);

-- 9. 透支分期表
CREATE TABLE IF NOT EXISTS liability (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,
  principal REAL NOT NULL,
  total_amount REAL NOT NULL,
  total_periods INTEGER NOT NULL,
  current_period INTEGER NOT NULL DEFAULT 0,
  period_amount REAL NOT NULL,
  rate_type TEXT NOT NULL DEFAULT 'NONE',
  interest_rate REAL NOT NULL DEFAULT 0.0,
  repayment_day INTEGER NOT NULL,
  next_repayment_date TEXT NULL,
  default_account_id INTEGER NOT NULL,
  category_id INTEGER NOT NULL,
  auto_cycle_fixed_expense INTEGER NOT NULL DEFAULT 1,
  status TEXT NOT NULL DEFAULT 'REPAYING', -- REPAYING / SETTLED
  start_date TEXT NOT NULL,
  settled_at TEXT NULL,
  created_at TEXT DEFAULT CURRENT_TIMESTAMP
);

-- 10. 待办事项表
CREATE TABLE IF NOT EXISTS todo_item (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  type TEXT NOT NULL, -- LIABILITY_OVERDUE / CYCLE_FIXED_ITEMS / WISHLIST_REACHED
  title TEXT NOT NULL,
  content TEXT NOT NULL,
  biz_id TEXT NOT NULL,
  status TEXT NOT NULL DEFAULT 'PENDING', -- PENDING / RESOLVED / DISMISSED
  created_at TEXT DEFAULT CURRENT_TIMESTAMP,
  updated_at TEXT DEFAULT CURRENT_TIMESTAMP
);
```

---

## 3. 核心算法移植规范 (Service Algorithms)

### 3.1 流水原子扣减 (`TransactionService`)
* **新增流水**：
  * 支出（type 2）：扣减 `account_id` 余额 `current_balance -= amount`；
  * 收入（type 1）：增加 `account_id` 余额 `current_balance += amount`；
  * 转账（type 3）：扣减 `account_id`，增加 `to_account_id`。
* **删除流水**：反向调整对应账户余额。若流水关联了周期固定项（`transaction_id`），重置该固定项为未记账状态（`isBooked = false`）。

### 3.2 周期自动推算与快照生成 (`CycleService`)
* 依据默认模板的 `start_day`（如自然月 1 号）计算当前日期的起止区间 `[startDate, endDate]`；
* 查询 `cycle_record` 是否存在该区间记录，不存在则根据模板创建新快照；
* 固定项点击到账/扣款：自动生成一条流水，将流水的 `id` 写回快照项的 `transactionId`，并将 `isBooked` 设为 `true`。

### 3.3 分期到期扣款与降级代扣 (`LiabilityService`)
* 巡检所有 `status = 'REPAYING'` 且 `next_repayment_date <= today` 的分期；
* 优先检查 `default_account_id` 余额是否 `>= period_amount`；
* **降级策略**：若默认账户不足，检索其他账户中是否有任意一个账户单户余额 `>= period_amount`；若存在，自动从该账户扣减；
* 若均不足：创建一条 `LIABILITY_OVERDUE` 待办，维持逾期待扣状态；
* 扣款成功后：
  * 自动插入一条支出流水（关联 `liability_id`）；
  * 更新 `current_period += 1`；
  * 顺延 `next_repayment_date` 到下一个月还款日；
  * 若期数达到总期数，标记 `status = 'SETTLED'`。

### 3.4 心愿单进度与时间预估算法 (`WishlistService`)
* **累计结余计算**：汇总所有历史周期结算结余与当前周期已发生结余；
* **储蓄速率推算**：
  * 计算历史已结算周期的平均结余，以及默认模板的基准预算结余；
  * 若结余速度 $> 0$，预估所需月数 `months = ceil((targetAmount - cumulativeBalance) / monthlySpeed)`，据此推算预估达成日期；
  * 若当前累计结余已能覆盖心愿金额，标记为“当前可实现”，并生成 `WISHLIST_REACHED` 待办。

### 3.5 开机自检补偿 (`App.vue` Lifecycle)
由于手机本地 App 没有常驻后台守护进程（Daemon），每次 App 启动（或从后台切回前台）时，通过 `LifecycleService.runStartupInspection()` 静默执行一次完整自检：
1. `CycleService.checkAndRollCycle()`（新周期检测）
2. `LiabilityService.checkAndExecuteDueRepayments()`（逾期与到期扣款）
3. `WishlistService.checkWishlistMilestones()`（心愿里程碑提醒）

---

## 4. Capacitor 集成与工程结构

```
android-frontend/
├── capacitor.config.ts        # Capacitor 配置文件
├── android/                   # 标准 Android Studio 原生工程
│   ├── app/
│   │   ├── src/main/AndroidManifest.xml
│   │   └── build.gradle
│   ├── build.gradle
│   └── gradlew
├── src/
│   ├── db/                    # 数据库驱动与建表
│   │   ├── index.ts           # SQLite 实例管理
│   │   └── schema.ts          # DDL 与预置种子数据
│   ├── services/              # 纯本地业务服务层
│   │   ├── transactionService.ts
│   │   ├── cycleService.ts
│   │   ├── liabilityService.ts
│   │   ├── wishlistService.ts
│   │   ├── targetService.ts
│   │   ├── todoService.ts
│   │   ├── statService.ts
│   │   └── inspectionService.ts
│   ├── views/                 # 视图层 (直接调用 services)
│   └── main.ts                # 初始化数据库后挂载 Vue
```
