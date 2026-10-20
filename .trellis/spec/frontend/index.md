# 前端开发主干规范 (Frontend Specs)

> MoneyDay MVP 前端全局技术栈与准则概览。

---

## 核心技术栈
- **框架**: Vue 3 (Composition API) + Setup 语法糖
- **语言**: TypeScript (TS)
- **构建工具**: Vite
- **UI 组件库**: Ant Design Vue
- **路由状态**: Vue Router + Pinia
- **图表展示**: ECharts
- **网络请求**: Axios

## 核心契约与开发纪律
1. **网络拦截与代理 (Proxy)**:
   - 前端代码中的请求统一向 `/api` 发送。
   - 开发环境通过 Vite 的 `server.proxy` 拦截并将 `/api` 代理到后端的 `http://localhost:8080`，解决跨域问题并统一步调。
2. **移动端优先与响应式 (Mobile-First)**:
   - UI 构建优先适配手机端浏览体验，表单、表格及卡片组件要保证在小屏幕下的可用性。
3. **状态管理 (Pinia) 与数据传递**:
   - 不要为了状态而滥用全局状态，只有当多个组件共享核心数据（例如当前选中的默认账单周期）时才放入 Pinia 中管理；一般性的页面数据通过 Axios 直接获取并在组件级 `ref` 中维护。
4. **组件解耦**:
   - 视图和视图组件应当按业务边界分离（例如 `AccountList`, `CategoryList`, `Settings` 等），并汇总至外层的 Router。
5. **图表与性能 (ECharts)**:
   - 在图表加载与销毁时，确保释放 ECharts 实例，防止内存泄漏。
   - 数据聚合计算尽可能由后端负责（如月度收支汇总由 `/api/stats` 统一吐出），前端 ECharts 只负责“纯渲染”。
6. **移动端云端架构 (Capacitor + HTTP)**:
   - 移动端 `android-frontend` 已改为通过 TypeScript HTTP 服务适配器访问统一云端 API；旧 SQLite 文件保留但不读写，不支持离线记账。
   - 详见：[offline-mobile-architecture.md](./offline-mobile-architecture.md)。
7. **Git 提交规范**: Commit 提交说明必须严格使用中文编写。格式要求为 `<type>: <中文简介>`（例如：`feat: 新增账单页面`, `docs: 更新前端组件文档`, `fix: 修复图表不刷新问题`）。

## Web 展示与动效

主题 tokens、共享导航、响应式布局、表格操作与按钮动效约定见 [component-guidelines.md](./component-guidelines.md#web-主题与响应式约定2026-10-20)。
