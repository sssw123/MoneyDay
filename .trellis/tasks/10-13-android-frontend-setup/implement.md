# 实施计划与任务清单：移动端前端项目构建与触屏适配

## Phase 1: 工程初始化与基础配置
- [x] 1.1 初始化 `android-frontend` 基础配置文件（`package.json`, `vite.config.ts`, `tsconfig.json`, `index.html`）。
- [x] 1.2 安装项目核心依赖（`vue`, `vue-router`, `vant`, `axios`, `@vant/use` 等）。
- [x] 1.3 封装 `src/utils/request.ts` 与入口 `src/main.ts`（引入 Vant 全局样式与组件）。

## Phase 2: 导航与全局架构
- [x] 2.1 编写 `src/App.vue`（配置全局移动端视口、底部常驻 Tabbar 与待办 Badge 联动）。
- [x] 2.2 编写 `src/router/index.ts`（配置移动端 5 大核心路由）。

## Phase 3: 各业务视图移动端适配开发
- [x] 3.1 编写 `src/views/Dashboard.vue`（四重资产卡片、周期结余池、近期透支提醒）。
- [x] 3.2 编写 `src/views/Transactions.vue`（按日期分组流水列表、底部浮窗记账面板）。
- [x] 3.3 编写 `src/views/Budget.vue`（移动端周期预算卡片、固定收支一键到账/支付）。
- [x] 3.4 编写 `src/views/Plan.vue`（顶部分段器集成【目标】、【心愿单】、【透支负债】，支持还款/兑现操作）。
- [x] 3.5 编写 `src/views/Todos.vue`（移动端待办中心卡片流，支持立即补扣分期与心愿兑现）。
- [x] 3.6 编写 `src/views/Mine.vue`（账户资产管理、分类管理与周期模板设置）。

## Phase 4: 编译打包与验证
- [x] 4.1 执行 `npm run build` 确保 TypeScript 类型与 Vite 打包无报错。
- [x] 4.2 验证移动端交互与后端 API 联调顺畅。
