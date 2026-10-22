# Flutter 验证记录与运行手册

本文件将编译、自动化测试和真实后端运行分开记录。**没有实际命令输出或设备记录的条目保持待验收。** CI 文件已配置不表示 CI 已运行；编译占位地址不是业务后端。

## 固定环境与证据要求

Flutter stable 3.47.7 / Dart 3.13.5，依赖使用 `pubspec.lock`。每次验收附 Git SHA、日期、宿主 OS、设备/模拟器、完整命令、退出码、产物路径或 CI 链接；敏感配置只记录键名，不保存密码、令牌或账本隐私。

| 检查 | 命令 | 当前状态 |
| --- | --- | --- |
| SDK | `flutter --version` | 已安装 Flutter 3.47.7 stable / Dart 3.13.5；framework abaf9c5237 |
| 锁定依赖 | `flutter pub get --offline --enforce-lockfile` | 通过，exit 0；首次联网获取后验证锁文件可离线重现 |
| Freezed / JSON | `dart run build_runner build --delete-conflicting-outputs` | 通过，exit 0；生成前后 SHA-256 相同，3 个生成文件一致 |
| 格式 | `dart format --output=none --set-exit-if-changed lib test integration_test` | 通过，exit 0；41 个 Dart 文件无变化 |
| 静态分析 | `flutter analyze --no-pub` | 通过，exit 0；No issues found |
| 自动化测试 | `flutter test --no-pub --reporter expanded` | 通过，134 项，exit 0；模型、请求契约、ViewModel、关键页面与会话隔离 |
| 开发代理 | Python AST 检查 + 本机临时上游服务 smoke checks | 已通过 12 项路由/Authorization/query/body/HEAD/错误状态/断连检查；2026-10-22，Python 3.15，Windows |
| 真实后端集成 | 显式提供专用测试账户后运行 `integration_test/live_backend_test.dart` | 待验收；默认 CI 不运行 |

## 六端构建与运行矩阵

下面命令在 `flutter-frontend` 目录运行。将示例 API 替换为真实 HTTPS 后端。所有平台当前结果由主代理/目标宿主实际执行后更新；不把缺失平台视作通过。

| 平台 | 必需宿主 / 工具 | 构建命令 | 编译状态 | 登录、读取账本、记账核对 |
| --- | --- | --- | --- | --- |
| Web | 任意 Flutter 支持宿主，浏览器 | `flutter build web --release --no-pub` | 已通过，exit 0；build/web | 已在内置浏览器启动登录页、启用无障碍、验证空表单；真实账本待验收 |
| Android | JDK 17、Android SDK、已接受许可证 | `flutter build apk --debug --flavor preview --dart-define=API_BASE_URL=https://your-server.example/api` | 待验收：本机无 Android SDK | 待设备验收 |
| Windows | Windows、Visual Studio C++ 桌面开发工具 | `flutter build windows --release --no-pub --dart-define=API_BASE_URL=https://moneyday.example.invalid/api` | 已通过，exit 0；build/windows/x64/runner/Release/moneyday.exe | 待启动和真实账本验收；构建使用占位地址 |
| iOS | macOS、Xcode；真机需签名与设备 | `flutter build ios --release --no-codesign --dart-define=API_BASE_URL=https://your-server.example/api` | 待目标宿主验收 | 待签名/设备验收 |
| macOS | macOS、Xcode | `flutter build macos --release --dart-define=API_BASE_URL=https://your-server.example/api` | 待目标宿主验收 | 待验收 |
| Linux | Linux、clang/cmake/ninja/pkg-config/GTK 3 | `flutter build linux --release --dart-define=API_BASE_URL=https://your-server.example/api` | 待目标宿主验收 | 待验收 |

Android preview 使用独立应用 ID 与 Debug 签名，仅作为安装测试产物。production 必须原签名、递增版本号和真实 HTTPS 后端；缺少正式签名时应阻止构建成功。iOS `--no-codesign` 产物不构成真机安装或商店发布验收。

## CI 的实际含义

[三宿主工作流](../../.github/workflows/flutter.yml) 在 Ubuntu 构建 Web、Android preview Debug、Linux；Windows 构建 Windows；macOS 构建无签名 iOS 和 macOS。各宿主都运行锁定依赖、生成器、一致性检查、格式、分析和单元/Widget 测试。

CI 的 `BUILD_API_URL=https://moneyday.example.invalid/api` 是刻意不可用的保留域名。构建通过只证明源码可编译，不证明登录、权限、后端、数据或设备运行已通过。默认未配置专用后端账户，不运行真实后端写入测试；该项必须继续显示待验收。

产物由 `actions/upload-artifact` 保存 14 天。Linux bundle 与 Apple `.app` 使用 tar 保留权限及符号链接；Windows 需保留整个 Release 目录及其 DLL/data，Web 需保留整个 `build/web`。安装与运行产物应重新用目标环境 API 构建。

## 专用后端集成验收

`integration_test/live_backend_test.dart` 必须使用可访问的测试 API 和专用普通用户账号；账号已完成初始改密，数据可清理。显式提供 `API_BASE_URL`、`TEST_USERNAME`、`TEST_PASSWORD`、`ALLOW_TEST_WRITES=true`，禁止把密码提交到仓库或 CI 日志。测试创建隔离账户与流水并精确清理；使用共享生产账本不属于授权范围。

在仓库外创建专用配置文件（或使用已忽略的 `test.local.json`），结构如下，所有示例值需替换：

```json
{
  "API_BASE_URL": "https://test-server.example/api",
  "TEST_USERNAME": "dedicated_test_user",
  "TEST_PASSWORD": "replace-with-dedicated-password",
  "ALLOW_TEST_WRITES": "true"
}
```

先运行 `flutter devices` 选设备，再在目标宿主执行：

```sh
flutter test integration_test/live_backend_test.dart -d <device-id> --dart-define-from-file=<仓库外专用测试配置.json>
```

Android 设备需加 `--flavor preview`。配置缺失或设备/网络不可用时记录阻塞原因和待验收；不得把跳过测试算作通过。目标平台完整业务流程和旧 Web 对账仍按 [迁移清单](migration-checklist.md) 执行。

## 手工界面及故障场景

- 尺寸至少覆盖 390×844、800×1024、1440×900，并补 320 窄屏、横屏、窗口缩放和键盘弹起；检查导航断点 599/600/1199/1200。
- 触摸、鼠标、Tab 键焦点、Enter 提交与 Escape 取消；表格横向滚动，长标题/金额/中文消息、空数据和加载状态不溢出。
- 用两用户会话切换模拟迟到成功和错误；旧请求取消、旧弹窗关闭、令牌过期、首次/重置密码强制改密、普通用户直接打开管理员 URL。
- 写入后故意丢响应或断网，确认没有自动重放；恢复网络后刷新，与后端/旧 Web 核对余额和流水。
- 固定到账重复提交被阻止；心愿超支取消不扣款；目标净资产/账户余额不足不兑现；负债提前多期还款顺延日期、结清后不再自动扣款。

## 执行记录模板

```text
日期 / 执行者：
Git SHA / 后端版本：
OS / Flutter / Dart / 设备：
命令与退出码：
产物或 CI 链接：
登录 → 读账本 → 记账 → 后端与旧 Web 对账证据：
界面与故障场景：
结论（通过 / 失败 / 待验收）与阻塞原因：
```

## 本次本地证据（2026-10-22）

- 执行者：Codex；基线 Git SHA `5246103c0c4be257afdeed8670baf787d4d10468`，本次修改尚未提交。
- 宿主：Windows 11 x64 `10.0.26300.9711`，Visual Studio Build Tools 2026 `18.11.12315.225`，Windows SDK `10.0.26100.0`。
- SDK：Flutter `3.47.7` stable / Dart `3.13.5`，engine `deb287481e3ce9468f3434937ced4240a70539ca`。SDK 和便携 JDK `17.0.20.1` 位于仓库忽略的 `.tools/`，不作为源码提交。
- `frontend`：`npm ci --no-audit --no-fund`、`npm run test:auth`（8/8）、`npm run build` 均 exit 0。Vite 保留既有大 chunk 提示；未修改旧版业务源码。
- `android-frontend`：`npm ci --no-audit --no-fund`、`npm test`（66 项 HTTP/会话映射检查）、`npm run build` 均 exit 0。构建首次受沙箱目录权限阻止，提权重跑通过；这是旧端 Web 资源构建，不能代替 Android APK/设备验收。
- `backend`：本进程设置 `JAVA_HOME=.tools/jdk17/jdk-17.0.20.1+1` 后执行 `mvnw.cmd -Dtest=BackendApplicationTests test`，4 项通过，0 failure/error/skipped，exit 0；未加载 Spring 数据库上下文。真实 MySQL 集成测试未运行。
- Flutter 自动化覆盖：请求字段及响应包络、迟到成功/401/403、强制改密、旧表单跨会话、转账、固定项目防重、心愿超支确认、目标资产门槛、多期还款及结清、待办、管理员、断网不重放、320 窄屏/双倍文字/键盘、连续缩放 599/600/1199/1200 断点、手机/平板/桌面、冷启动深链接和查询参数恢复。
- Web 通过本地静态服务 `127.0.0.1:5187` 在内置浏览器实际打开，中文登录页可见，用户名/密码及按钮具有无障碍语义，空提交被表单校验阻止。未输入真实凭据，未连接账本；这仅是启动烟测。
- 本地原始日志：`.tools/flutter-test-final.log`、`.tools/flutter-web-build-final.log`、`.tools/flutter-windows-build-final.log`、`.tools/backend-regression.log`、`.tools/flutter-doctor-final.log`。可提交的[真实输出摘录与关键产物 SHA-256](evidence/2026-10-22-checks.txt)便于后续核对；机器相关缓存与大体积产物不提交。
- 生成器提示 SDK language 3.13 比当前 analyzer language 3.11 新；本次生成一致性、静态分析、测试和两端构建均通过，暂不升级已锁定依赖。
- `flutter doctor -v` 已实际执行：Android SDK 缺失；maven.google.com 与 github.com 的网络探测超时，SDK Git 来源另有 doctor 提示。诊断命令 exit 0 不等于全部工具链就绪，以逐项状态和实际构建为准。
- 用户已明确选择“暂未准备，记录为待验收”：无专用 API/账号，不运行 `integration_test/live_backend_test.dart`，不把假 HTTP 测试算成真实业务验收。

尚待：Android SDK/许可证及设备；macOS/Xcode 上的 iOS、macOS；Linux 宿主；六端真实后端运行及旧 Web 对账；完整手工输入/故障回归；真实 MySQL 回归。CI 已配置但未推送执行。当前不满足切换门槛，旧默认入口保留。
