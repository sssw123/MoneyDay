# Capacitor集成与离线本地SQLite脱机架构 (Implementation Plan)

## 1. 执行清单 (Execution Checklist)

### 步骤 1: 依赖引入与 Capacitor 工程初始化
- [x] 1.1 在 `android-frontend` 中安装 Capacitor 核心依赖：`@capacitor/core`、`@capacitor/cli`、`@capacitor/android`、`@capacitor-community/sqlite`、`jeep-sqlite`。
- [x] 1.2 创建 `capacitor.config.ts`，配置 App ID (`com.moneyday.app`)、App Name (`MoneyDay`)、webDir (`dist`)。
- [x] 1.3 执行 `npm run build && npx cap add android`，生成 `android/` 原生工程骨架。

### 步骤 2: 本地 SQLite 数据引擎与 DDL 落地 (`src/db/`)
- [x] 2.1 编写 `src/db/schema.ts`：定义 10 张表的 SQLite DDL 语句以及初始预置种子数据（默认自然月周期模板、常用收支分类、默认现金/银行账户）。
- [x] 2.2 编写 `src/db/database.ts`：封装 SQLite 连接池与执行包装器（支持 Capacitor 原生环境与 Web 调试模式降级）。
- [x] 2.3 在 `src/main.ts` 中加入应用启动时数据库初始化逻辑，确保建表完成后再挂载 Vue。

### 步骤 3: 移植 Spring Boot 业务算法到 TypeScript 服务层 (`src/services/`)
- [x] 3.1 编写 `transactionService.ts`：实现流水增删改查、账户余额事务级增减回滚、周期固定项联动关联。
- [x] 3.2 编写 `cycleService.ts`：实现默认模板解析、自然月周期边界推算、周期快照生成、固定项确认到账/支出记账与反记账。
- [x] 3.3 编写 `liabilityService.ts`：实现透支分期录入、还款期数扣减、提前结清、到期自动代扣、跨账户降级代扣逻辑。
- [x] 3.4 编写 `wishlistService.ts`：实现心愿单 CRUD、基于历史平均结余与预算结余的达成天数预估、任性兑现扣款与撤销退款。
- [x] 3.5 编写 `targetService.ts`：实现净资产目标管理、达成扣款与撤销退款。
- [x] 3.6 编写 `todoService.ts`：实现待办流转、分期逾期补扣（支持更换账户）、待办核销。
- [x] 3.7 编写 `statService.ts`：实现四大资产卡片折算、当期收支统计、累计结余与分类饼图数据计算。
- [x] 3.8 编写 `inspectionService.ts`：统一开机自检与前台恢复补偿逻辑。

### 步骤 4: 视图层适配解耦 (Views Refactoring)
- [x] 4.1 改造 `App.vue`：应用启动与路由切换触发自检补偿与待办角标刷新。
- [x] 4.2 改造 `Dashboard.vue`：接入 `statService`、`cycleService`、`liabilityService`、`wishlistService` 本地服务。
- [x] 4.3 改造 `Transactions.vue`：接入 `transactionService`，支持本地脱机增删查。
- [x] 4.4 改造 `Budget.vue`：接入 `cycleService`，实现本地固定项核销。
- [x] 4.5 改造 `Plan.vue`：接入 `wishlistService`、`targetService`、`liabilityService`。
- [x] 4.6 改造 `Todos.vue`：接入 `todoService`，实现本地待办补扣与核销。
- [x] 4.7 改造 `Mine.vue`：接入账户与分类管理本地服务。

### 步骤 5: 构建验证与脱机运行检验
- [x] 5.1 运行 `npm run build`，确保 TypeScript 类型校验与静态编译 100% 通过。
- [x] 5.2 运行 `npx cap sync`，将 Web 构建产物同步到 `android/` 目录。
- [x] 5.3 验证断开后端服务后本地记账、刷新、重启仍能完整保持持久化。
- [x] 5.4 编写 APK 打包指引文档（`android/README.md`）。

---

## 2. 校验命令 (Validation Commands)

```bash
# 1. 移动端工程编译检查
cd d:\IDEAProjects\MoneyDay\android-frontend
npm run build

# 2. Capacitor 原生工程同步
npx cap sync android

# 3. PC 前端兼容性检查
cd d:\IDEAProjects\MoneyDay\frontend
npm run build
```

---

## 3. 回滚点与风险控制

- **风险 1：Web 端预览没有真实 SQLite 原生层**
  - **对策**：引入 `jeep-sqlite` 或轻量级 Web 适配器，使得在 `npm run dev` 浏览器中同样支持 IndexedDB 持久化存储，开发调试体验丝滑。
- **风险 2：原生 Android 目录与构建配置**
  - **对策**：Capacitor 的 `android/` 目录可安全提交至 Git，通过标准 `gradlew assembleDebug` 或 Android Studio 即可一键生成 `app-debug.apk`。
