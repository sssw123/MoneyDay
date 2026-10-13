# 移动端离线 SQLite 与 Capacitor 架构规范 (Offline Mobile Architecture)

## 1. 架构定位与选型

`android-frontend` 是专为手机端设计的独立移动工程，具备脱机独立运行与 APK 打包能力：
* **核心技术栈**：Vue 3 + Vite + TypeScript + Vant 4
* **原生桥接**：Capacitor 8 (`@capacitor/core`, `@capacitor/cli`, `@capacitor/android`)
* **本地存储引擎**：`@capacitor-community/sqlite` (原生 SQLite) + `jeep-sqlite` (Web 调试降级)
* **业务服务层**：`src/services/` (纯 TypeScript 移植的领域业务服务)
* **数据库层**：`src/db/` (`database.ts` 封装连接与事务，`schema.ts` 维护 DDL 与种子数据)

---

## 2. 数据层设计原则与契约

1. **服务层统一调用原则**：
   * 视图层（`src/views/`）禁止直接调用底层 SQL 或发送 HTTP 请求，必须通过领域服务（如 `transactionService`、`cycleService` 等）进行业务操作；
   * 视图与服务之间传递强类型 DTO / 实体对象，避免 `any` 污染。

2. **数据持久化与双环境适配**：
   * **Android 原生环境**：自动建立物理文件 SQLite 数据库（`moneyday_db`），支持断网飞行模式与手机关机重启数据持久化；
   * **Web 调试环境**：自动挂载 `jeep-sqlite` 虚拟存储，将 SQL 读写透明持久化到浏览器的 IndexedDB 中，无需手机即可通过 `npm run dev` 在 PC 端完成全链路离线调试。

3. **开机自检与生命周期补偿 (Inspection)**：
   * 移动端无常驻守护进程。在 `App.vue` 挂载及路由初始化时，自动调用 `inspectionService.executeAllChecks()`；
   * 检查项包含：跨周期自动滚动生成快照、分期到期智能扣款与多账户降级代扣、心愿里程碑达成提醒。

---

## 3. APK 编译与同步工作流

当移动端 Web 代码修改后，必须同步至 Android 原生工程：
```bash
# 1. 编译前端产物
npm run build

# 2. 同步 Web 资源与插件配置至 Android 工程
npx cap sync android

# 3. 打包 APK
# 方式 A: 打开 Android Studio 编译输出 app-debug.apk
# 方式 B: 命令行执行: cd android && ./gradlew assembleDebug
```
