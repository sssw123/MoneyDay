# MoneyDay · 记账与攒钱系统

<p align="center">
  <strong>专为个人日常设计的理财记账与攒钱资产管理系统</strong>
  <br>
  <span>Web 全功能在线版 + Android 纯离线脱机版，告别数据焦虑，掌控个人现金流</span>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Spring%20Boot-3.3.4-brightgreen.svg" alt="Spring Boot">
  <img src="https://img.shields.io/badge/Java-17-blue.svg" alt="Java 17">
  <img src="https://img.shields.io/badge/Vue.js-3.x-4fc08d.svg" alt="Vue 3">
  <img src="https://img.shields.io/badge/TypeScript-5.x-blue.svg" alt="TypeScript">
  <img src="https://img.shields.io/badge/SQLite-Offline-orange.svg" alt="SQLite">
  <img src="https://img.shields.io/badge/MySQL-8.0+-blue.svg" alt="MySQL">
  <img src="https://img.shields.io/badge/License-MIT-green.svg" alt="License">
</p>

---

## 💡 项目简介

**MoneyDay** 是一款兼顾日常收支流水、自定义账单周期、强制储蓄规划与负债管理的个人资产工具。不同于市面上依赖云端托管和繁琐广告的记账软件，MoneyDay 坚持**隐私第一、资产托底、逻辑闭环**：

- **双端支持**：既有功能完备、大屏可视化的 **Web 端**，也有开箱即用、完全不依赖服务器的 **Android 纯离线移动端**。
- **打破自然月限制**：支持任意自定义账单周期（如发薪日 10 号为起算日），结余与预算更贴合真实生活节奏。
- **严谨记账哲学**：区分“心愿单”与“长期资产目标”，引入“可用净资产”和“负债分期代扣”，避免盲目储蓄导致的资金透支。

---

## ✨ 核心特性

### 1. 双端运行形态
- **Web 全功能版** (`frontend` + `backend`)：
  - 基于 Spring Boot 3 + MyBatis-Plus + Vue 3 + Ant Design Vue 构建；
  - 拥有完整的收支看板、月度与历史趋势图表、全局多账户联动。
- **Android 纯离线脱机版** (`android-frontend`)：
  - 基于 Vue 3 + Vant 4 + Capacitor + 本地 SQLite 构建；
  - **飞行模式 / 无网络状态秒级响应**，无需启动后端服务器或数据库；
  - 所有数据存储在手机本地私有沙箱中，私密安全，关机不丢失。

### 2. 灵活账单周期与快照机制
- 支持自定义起始日（如每月 10 号至次月 9 号为一个账单周期）；
- 引入**周期快照 (Cycle Snapshot)**：固存金额与预期固收在周期首次访问时自动继承固化，历史账期参数变更互不干扰。

### 3. 真实资金闭环与强制储蓄
- **固存 (Fixed Deposit)**：在周期开始时设定强制储蓄额，真实结余公式：`结余 = 收入 - 固存 - 支出`，确保每月先存后花。
- **周期固收 (Cycle Fixed Income)**：支持薪资一键确认到账生成流水，具备防重复记账机制。

### 4. 心愿单 vs 长期目标双轨驱动
- **心愿单 (Wishlist)**：非刚性消费（如数码产品、旅游），由全局累计结余池提供进度与预计达成天数，超支时智能软预警。
- **长期资产目标 (Long-term Target)**：大额资产沉淀（如买车买房储备），由**可用净资产**真实托底，存钱速度按每周期净结余科学推算。

### 5. 透支负债与智能代扣引擎
- 支持各类免息/计息分期（信用卡分期、花呗、白条等）；
- 支持历史已还期数补录、提前还期与一键提前结清；
- 内置定时任务调度引擎与启动自检补偿，还款日自动代扣并滚动下期。

---

## 🛠️ 技术栈

| 模块 | 技术选型 | 说明 |
| :--- | :--- | :--- |
| **后端 (Backend)** | Java 17, Spring Boot 3.3.4 | 核心 RESTful API 业务服务 |
| | MyBatis-Plus 3.5.7, MySQL 8.0+ | 数据持久化与数据库交互 |
| **Web 前端 (Frontend)** | Vue 3, Vite, TypeScript | 桌面端与浏览器适配响应式界面 |
| | Ant Design Vue, ECharts, Pinia | UI 组件库与统计图表呈现 |
| **移动端 (Android)** | Vue 3, Vant 4, TypeScript | 移动端触屏体验与交互适配 |
| | Capacitor 8, Capacitor Community SQLite | 跨平台移动运行时与原生 SQLite 离线存储 |

---

## 📂 目录结构

```text
MoneyDay/
├── backend/                  # Spring Boot 后端工程
│   ├── src/main/java/        # 后端业务源码
│   └── src/main/resources/   # 配置文件与数据库 schema.sql
├── frontend/                 # Web 前端工程 (Vue 3 + Ant Design Vue)
│   ├── src/                  # 页面、组件与 Pinia Store
│   └── vite.config.ts        # Vite 开发服务器与代理配置
├── android-frontend/         # Android 离线移动端工程 (Vue 3 + Vant 4 + Capacitor)
│   ├── src/                  # 触屏端业务源码与 SQLite DAO 封装
│   └── android/              # Capacitor 生成的原生 Android Studio 工程
├── CONTEXT.md                # 核心业务领域模型与术语约定
├── CONTRIBUTING.md           # 代码贡献与提交规范
└── LICENSE                   # MIT 开源许可证
```

---

## 🚀 快速上手

### 1. 数据库初始化 (Web/后端版)

确保已安装 **MySQL 8.0+** 并启动服务：

```sql
CREATE DATABASE IF NOT EXISTS `moneyday` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
```

导入核心数据库结构与初始化预置数据：
- 脚本位置：[`backend/src/main/resources/schema.sql`](backend/src/main/resources/schema.sql)

### 2. 启动后端服务

1. 进入 `backend/src/main/resources/` 目录，复制示例配置：
   ```bash
   cp backend/src/main/resources/application-local.yml.example backend/src/main/resources/application-local.yml
   ```
2. 编辑 `application-local.yml` 中的数据库账号和密码。
3. 编译并启动服务：
   ```bash
   cd backend
   mvn spring-boot:run
   ```
   后端服务将默认运行在 `http://localhost:8080`。

### 3. 启动 Web 前端

打开新终端窗口：

```bash
cd frontend
npm install
npm run dev
```

在浏览器中访问 `http://localhost:5173` 即可开始使用。

---

### 4. 运行 Android 纯离线脱机版

Android 端支持在手机上脱机独立运行（无需启动后端及 MySQL）：

1. **安装依赖与构建资源**：
   ```bash
   cd android-frontend
   npm install
   npm run build
   npx cap sync android
   ```
2. **构建与运行 APK**：
   - **方式一（推荐）**：使用 **Android Studio** 打开 `android-frontend/android` 目录，点击 `Build` -> `Build Bundle(s) / APK(s)` -> `Build APK(s)`，生成的安装包位于 `android/app/build/outputs/apk/debug/app-debug.apk`。
   - **方式二（命令行）**：
     ```bash
     cd android-frontend/android
     ./gradlew assembleDebug
     ```
3. 将生成的 APK 安装到手机，首次打开会自动初始化本地 SQLite 数据库，离线立即可用。详细步骤可参阅 [Android 打包指引文档](android-frontend/android/README.md)。

---

## 📖 核心概念与设计约定

在开发或使用 MoneyDay 之前，建议先阅读 **[CONTEXT.md](CONTEXT.md)**，了解项目的核心设计哲学：
- **全局目标透支 (Global Target Overdraft)**：资产由全账户统一托底，避免因目标冻结资金导致误拦截记账。
- **可用净资产 (Available Net Assets)**：`所有账户总资产 - 所有未结清负债待还总额`。
- **透支负债 (Liability / Overdraft)**：消费分期的防重代扣、还款日自动顺延与提前结清逻辑。

---

## 🤝 参与贡献

欢迎提交 Issue 或 Pull Request！在开始之前，请阅读 [CONTRIBUTING.md](CONTRIBUTING.md)。

本项目严格遵循规范的 Git Commit 消息格式：
```text
<type>: <中文描述>
```
例如：
- `feat: 支持按分类导出 CSV 账单`
- `fix: 修复账单周期跨月时结余统计偶发负值的问题`

---

## 📄 开源许可证

本项目基于 [MIT License](LICENSE) 开源。
