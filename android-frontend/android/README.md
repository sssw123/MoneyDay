# MoneyDay Android APK 打包与脱机运行指引

本项目基于 **Vue 3 + Vant 4 + Capacitor + Capacitor SQLite** 构建，已实现数据源与业务逻辑完全本地化，无需联网、无需启动电脑 Spring Boot 或 MySQL 即可在手机上独立使用。

---

## 一、 打包前置准备

1. **已安装 Android 开发环境**：
   * **Android Studio**（推荐，内置 Android SDK、ADB 与 Gradle 支持）或独立的 **Android Command-line Tools**；
   * **JDK 17 或以上**（本项目已使用 JDK 17）。
2. **Web 资源已最新同步**：
   在 `android-frontend` 根目录下执行：
   ```bash
   npm run build
   npx cap sync android
   ```

---

## 二、 两种 APK 打包方式

### 方式一：通过 Android Studio 一键打包（推荐）

1. 启动 **Android Studio**；
2. 选择 **Open**（打开已有项目），选择项目下的目录：
   `android-frontend/android`
3. 首次打开会自动下载 Gradle Wrapper 及 Android SDK 依赖（请确保网络畅通）；
4. 同步完成后，在顶部菜单栏依次点击：
   **`Build`** -> **`Build Bundle(s) / APK(s)`** -> **`Build APK(s)`**；
5. 打包成功后，右下角会弹出提示，点击 **`locate`** 即可直接定位到生成的安装包：
   * 路径：`android/app/build/outputs/apk/debug/app-debug.apk`
6. 通过微信/QQ/数据线将 `app-debug.apk` 发送到 Android 手机，直接点击安装即可。

---

### 方式二：命令行 Gradle 直接编译打包

若已配置好 `ANDROID_HOME` 环境变量：
```bash
cd android-frontend/android

# Windows PowerShell:
.\gradlew assembleDebug
```
编译产物同样输出至：
`android/app/build/outputs/apk/debug/app-debug.apk`

---

## 三、 手机脱机使用特性与验证

1. **开箱即用**：
   * 首次打开应用时，底层自动初始化手机内置的 SQLite 数据库（`moneyday_db`）；
   * 自动生成默认自然月周期、常用收支分类（工资、餐饮、交通等）与默认账户（微信钱包、支付宝、招商银行）。
2. **纯离线闭环**：
   * 手机处于**飞行模式 / 无网络状态**下，收支记账、周期核销、心愿单兑现、分期自动代扣均可秒级响应；
   * 所有账务数据均持久化在手机本地私有存储沙箱中，手机关机重启数据永不丢失。
3. **开机自检机制**：
   * 每日或每次打开 App 时，本地引擎会自动检查账单周期是否跨越滚动，以及分期是否到期并自动执行智能代扣与逾期待办提醒。
