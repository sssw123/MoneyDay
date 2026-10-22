# MoneyDay Android 云端客户端

本客户端通过 `src/services` 的 HTTP 适配器访问后端 `/api`，与 Web 共享账户和账本。没有注册、离线记账或离线同步。原 SQLite 文件保留，新版不再初始化、读取或迁移，自动扣款与周期巡检由后端执行。

## 开发

使用 Node 22：

```sh
npm ci
npm test
npm run dev
```

浏览器开发地址为 `http://localhost:5174`，默认通过 Vite 代理 `/api` 到 `http://localhost:8080`。登录使用管理员分配的账户，首次登录及重置密码后必须修改密码；管理员在「设置 → 用户管理」管理普通用户。

## Android Debug

原生客户端必须在构建时设置完整 API 地址，包含 `/api`。Android 模拟器访问宿主机使用 `10.0.2.2`，真机使用宿主机局域网 IP，并确保网络可达及后端 CORS 允许 `https://localhost`。开发 HTTP 只在 Debug Manifest 中允许：

```sh
VITE_API_BASE_URL=http://10.0.2.2:8080/api npm run build -- --mode android-debug
MONEYDAY_ANDROID_DEBUG=true npx cap sync android
cd android
ANDROID_HOME="$HOME/Library/Android/sdk" ./gradlew assembleDebug
```

项目使用 Capacitor 8，需要 JDK 21、Android SDK Platform 36、相应构建工具和已接受的许可证。`app/build/outputs/apk/debug/app-debug.apk` 为输出位置。

## 正式包

```sh
VITE_API_BASE_URL=https://your-moneyday-host.example/api npm run build -- --mode android-release
npx cap sync android
```

`android-release` 模式拒绝非 HTTPS API 地址，Release Manifest 关闭明文网络请求。正式签名与发布使用现有 Android 流程。Debug 同步过后，正式同步必须不带 `MONEYDAY_ANDROID_DEBUG`，以恢复混合内容限制。

## 登录及网络行为

会话只保存在 `sessionStorage`；应用重启可能需要重新登录。服务端会话最多 7 天，两端可以同时在线。退出、改密、停用、删除及管理员重置按服务端规则撤销会话。切换用户重建业务视图，旧会话请求的结果丢弃。

无网络时显示连接失败及重新连接入口。重试只刷新当前页面，不自动重放财务写请求；写入结果未知时，恢复网络后先刷新核对结果再手动操作。

`npm test` 在临时本机 HTTP 服务上验证全部财务服务路径、负债/周期 payload、Bearer 头、强制改密与管理员路由、退出/改密/401清理、旧会话响应丢弃和断网写入不自动重放。它不连接业务数据库，也不替代真机验收。

## 本轮本地验证边界

Node 22 下 `npm test`、`npm run build`、Android Debug 模式前端构建及 `cap sync android` 已通过。`./gradlew assembleDebug` 未产出 APK：用户全局 Gradle 代理 `127.0.0.1:7890` 拒绝连接；使用独立临时 Gradle 缓存绕过代理后，Gradle 8.14.3 分发下载连接超时。本轮 Android 构建使用 JDK 17，尚未配置所需 JDK 21，Android SDK 仅有 Platform 33，需补齐 Platform 36。未进行真机或模拟器云端业务验收。
