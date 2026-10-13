# Capacitor集成与离线本地SQLite脱机架构 (PRD)

## 1. 目标与背景 (Goal & Background)

目前 MoneyDay 前端已完成 PC 端（`frontend`）与移动端（`android-frontend`）的双端 UI 适配，但移动端仍依赖本地 Spring Boot 8080 后端与 MySQL 数据库。
本阶段目标是将 `android-frontend` 彻底改装为**可独立脱机运行的 Android 应用**：
1. 集成 Capacitor 框架，生成标准 Android 原生工程骨架；
2. 抽象前端数据仓储服务层（`DataRepository` / `Service` 模式）；
3. 将 Spring Boot 中的账务、周期、分期、待办与心愿算法完整无损地移植至前端 TypeScript；
4. 数据库切换为手机本地内置的 Capacitor SQLite，无需联网、无需开启电脑后端即可在手机上独立记账并持久化；
5. 打包生成独立的 `.apk` 安装包。

---

## 2. 需求范围 (Scope)

### 2.1 In Scope (本次实现)
1. **Capacitor 移动端工程集成**：
   - 安装 `@capacitor/core`、`@capacitor/cli`、`@capacitor/android`；
   - 配置 `capacitor.config.ts`（AppId: `com.moneyday.app`，AppName: `MoneyDay`）；
   - 执行 `npx cap add android` 生成 `android/` 原生工程骨架。
2. **手机本地 SQLite 数据库适配**：
   - 集成 `@capacitor-community/sqlite` 驱动（并配置 Web 调试兼容组件）；
   - SQLite DDL 迁移脚本：将当前 10 张核心表（`user`, `account`, `category`, `transaction`, `cycle_template`, `cycle_record`, `target`, `wishlist`, `liability`, `todo_item`）转为 SQLite 语法；
   - 首次启动自动建表并灌入预置数据（默认分类、自然月周期模板、现金/微信默认账户）。
3. **数据服务层与业务算法移植 (Spring Boot -> TypeScript)**：
   - **流水记账服务 (`TransactionService`)**：收/支/转账流水录入，联动更新账户当前余额；删除/修改流水反向回滚余额。
   - **周期账单服务 (`CycleService`)**：基于默认模板推算当前周期起止日期；生成/读取周期快照；固定项快速到账/支出记账（联动流水）与撤销记账。
   - **分期透支服务 (`LiabilityService`)**：分期录入；按期手动还款、提前全额结清；到期智能自动扣款（支持多账户降级扣款检查）；逾期自动报警。
   - **心愿单服务 (`WishlistService`)**：立项管理；达成预估日期计算（基于历史周期结余平均值与默认模板结余）；兑现扣款与撤销退回。
   - **资产目标服务 (`TargetService`)**：净资产目标管理、达成兑现与撤销。
   - **待办中心服务 (`TodoService`)**：分期还款失败代扣提醒（支持更换账户一键补扣）、新周期账单核对提醒、心愿达成可兑现提醒；应用启动时静默自检补偿。
   - **统计看板服务 (`StatService`)**：总资产、未还负债、可用净资产、周期收支、累计结余与分类支出统计。
4. **视图层平滑解耦改造**：
   - 将移动端 6 大核心视图（`Dashboard`, `Transactions`, `Budget`, `Plan`, `Todos`, `Mine`）从 Axios HTTP 请求改造为直接调用本地服务层；
   - 页面启动时触发开机自检（周期滚动、分期扣款、心愿里程碑提醒）。
5. **构建与 APK 打包指引**：
   - 提供 Vite 打包并同步至 Android 的命令脚本；
   - 编写 APK 编译说明与常见问题处理文档。

### 2.2 Out of Scope (未来演进)
- 远程多设备数据双向云同步（本阶段聚焦纯本地独立脱机使用）；
- iOS 平台打包发布（本阶段聚焦 Android APK）。

---

## 3. 验收标准 (Acceptance Criteria)

- **AC-1: Capacitor 原生工程完整生成**：`android-frontend` 目录下成功生成 `capacitor.config.ts` 与 `android/` 原生工程，`npm run build && npx cap sync` 可顺利执行无报错。
- **AC-2: 本地 SQLite 自动初始化**：在无网络、无 Spring Boot 后端的情况下，应用首次启动自动创建 SQLite 数据库与全部 10 张数据表，并注入默认周期模板与分类。
- **AC-3: 离线记账与资产实时联动**：用户录入支出/收入/转账后，账户余额即时更新，向左滑动删除流水后账户余额正确回滚，刷新应用数据保持持久化。
- **AC-4: 周期账单与固定收支离线核销**：能正常查看当前周期与历史周期，固定收支点击“确认到账/扣款”能在本地生成流水并核销。
- **AC-5: 分期与待办全流程离线闭环**：录入分期可计算每期金额与到期日；手动还款或结清正常扣减账户；逾期分期可在待办中心选择账户立即补扣。
- **AC-6: 纯脱机 APK 独立可用**：应用无需联网权限，不发任何外部 HTTP 请求，在手机断网飞行模式下依然流畅记账。
