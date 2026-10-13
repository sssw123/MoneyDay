# 技术设计：移动端前端项目构建与触屏适配 (android-frontend)

## 1. 架构总览

`android-frontend` 是独立于现有 PC 端 `frontend` 的移动端前端应用，针对小屏幕、触屏手势、单手操作习惯进行全新设计。

```
MoneyDay/
├── backend/            # Spring Boot 后端
├── frontend/           # PC 桌面端 (Ant Design Vue)
└── android-frontend/   # 移动端 (Vue 3 + Vant 4 + Capacitor Ready)
    ├── index.html
    ├── package.json
    ├── vite.config.ts
    ├── tsconfig.json
    └── src/
        ├── App.vue           # 根组件 (带全局 Vant Tabbar)
        ├── main.ts           # 入口 (注册 Vant 组件与样式)
        ├── router/           # 移动端路由
        ├── utils/            # 网络请求与通用格式化工具
        └── views/
            ├── Dashboard.vue     # 首页资产看板
            ├── Transactions.vue  # 流水明细与记账
            ├── Budget.vue        # 周期预算与固收支
            ├── Plan.vue          # 未来计划 (目标/心愿/透支 Tab)
            ├── Todos.vue         # 移动端待办中心
            └── Mine.vue          # 我的与系统设置
```

---

## 2. 核心移动端交互设计规范 (Vant 4)

1. **色彩与主题**：
   - 品牌主色：保持与 PC 端一致的现代财务蓝 `#1989fa` 或墨绿；
   - 负债/支出：红色 `#ee0a24`；收入/储蓄：绿色 `#07c160`；
2. **主要组件选型**：
   - 底部导航：`van-tabbar` + `van-tabbar-item`（带角标 badge）；
   - 页面顶部：`van-nav-bar` 提供返回键与标题；
   - 列表展示：`van-card` / `van-cell-group` / `van-cell`；
   - 表单输入：`van-field` + `van-popup` 配合 `van-picker` / `van-date-picker`；
   - 操作反馈：`showToast` / `showDialog` / `showConfirmDialog`。

---

## 3. 数据层与未来 Capacitor 适配设计

1. **网络层配置 (`utils/request.ts`)**：
   - 开发环境支持 Vite 代理 `/api`；
   - 生产/手机端支持配置 `VITE_API_BASE_URL`（如局域网 `http://192.168.x.x:8080/api`），允许手机在真机调试时直接通信；
2. **未来 Capacitor 脱机接口预留**：
   - 所有数据请求收敛在视图或 API 模块，便于未来直接无缝替换为 `@capacitor-community/sqlite` 驱动。
