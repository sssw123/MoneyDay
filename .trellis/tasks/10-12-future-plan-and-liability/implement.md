# 执行计划: 未来计划架构与透支分期管理

## 1. 数据库改造与实体构建
- [x] 执行数据库迁移：
  - 创建 `wishlist` 表并将 `target` 中已有心愿单数据迁移至 `wishlist`。
  - 创建 `liability` 表。
  - 为 `transaction` 表增加 `liability_id` 字段。
- [x] 后端数据持久层实体与 Mapper：
  - `Wishlist.java` & `WishlistMapper.java`。
  - `Liability.java` & `LiabilityMapper.java`。
  - `Target.java` 纯化为长期目标实体。
  - `Transaction.java` 增加 `liabilityId` 字段。

## 2. 后端业务逻辑开发
- [x] 心愿单业务：`WishlistService` 及 Controller，实现独立的增删改查、结余进度、兑现与撤销。
- [x] 长期目标业务：`TargetService` 纯化，基于 `availableNetAssets` 测算与托底。
- [x] 透支负债业务：`LiabilityService` 及 Controller：
  - 录入支持免息、手续费率、年化等额本息计算，支持每期金额用户手动微调。
  - 自动扣款引擎（还款日自动生成支出流水，支持默认账户不足降级为全系统最大余额账户）。
  - 提前结清接口（支持微调结清金额，生成结清流水并更新状态）。
- [x] 周期与统计服务对齐：
  - 周期固定支出与有效分期项自动联动展示与状态更新。
  - `StatService` 计算并输出 `totalLiabilities`，对齐 `availableNetAssets = totalAssets - totalLiabilities`。

## 3. 前端导航与页面重构
- [x] 路由改造 (`router/index.ts`)：
  - 注册 `/budget`、`/plan/targets`、`/plan/wishlist`、`/plan/liabilities`。
- [x] 导航栏改造 (`App.vue`)：
  - 【预算】独立一级菜单（纯周期表）。
  - 新增一级子菜单【未来计划】，包含【目标】、【心愿单】、【透支】。
- [x] 页面改造：
  - `Budget.vue`：精简为纯粹的周期表。
  - `TargetPlan.vue`：专属于长期资产目标。
  - `Wishlist.vue`：专属于心愿单管理。
  - `Liability.vue`：全新透支分期管理界面（汇总卡片、分期列表、还款进度条、提前结清、新增分期弹窗含智能计算器）。
  - `Dashboard.vue`：顶部升级为总资产、未还总负债、可用净资产、累计结余 4 张卡片。

## 4. 验证与测试
- [x] 后端编译与单元测试：`mvn test` 100% 通过。
- [x] 前端打包编译：`npm run build` 0 报错通过。
- [x] 呈现 Commit Plan 等待用户确认。
