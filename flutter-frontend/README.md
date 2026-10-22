# MoneyDay Flutter 客户端

独立 Flutter 工程，目标平台为 Web、Android、iOS、Windows、macOS、Linux。采用中文 Material 3 界面，与旧 Vue Web、Capacitor Android 共用现有 Spring Boot `/api` 和用户账本。

旧工程保留运行；本目录的存在、测试通过或某个平台构建成功均不表示已完成六端上线验收。逐端证据见 [验证记录](docs/validation.md)，功能对照和切换门槛见 [迁移清单](docs/migration-checklist.md)。

## 工具链与依赖

- 固定 Flutter stable **3.47.7**，对应 Dart **3.13.5**；版本记录于 `.fvmrc` 和 CI。
- 提交 `pubspec.lock`；使用 `flutter pub get --enforce-lockfile` 重现依赖，不自动升级 SDK 或依赖。
- Android：JDK 17、Android SDK，以及已接受的许可证；Windows：Visual Studio 的 Desktop development with C++；iOS/macOS：macOS 和 Xcode；Linux：clang、cmake、ninja、pkg-config、GTK 3 开发包。
- 安装相应平台工具链后运行 `flutter doctor -v`。缺少宿主、SDK、签名或设备的条目保留为待验收。

```sh
cd flutter-frontend
flutter --version
flutter pub get --enforce-lockfile
dart run build_runner build --delete-conflicting-outputs
flutter analyze
flutter test
```

`lib/data/models/models.freezed.dart` 和 `models.g.dart` 由 Freezed/JSON 生成器维护。修改模型后重新生成，禁止手改生成文件。CI 校验生成文件与源码一致。

## 本地 Web 开发

先按根目录文档启动 MySQL 和 Spring Boot（`127.0.0.1:8080`），然后在两个终端运行：

```sh
# 终端一：Flutter 开发资源服务器
flutter run -d web-server --web-hostname=127.0.0.1 --web-port=5175
```

```sh
# 终端二：Python 3 标准库同源代理
python tool/dev_proxy.py
```

浏览器打开 `http://127.0.0.1:5173`。Web 默认请求同源 `/api`；代理将 `/api` 及其子路径发往后端，其他资源路径发往 Flutter web-server，SPA 回退由 Flutter web-server 处理。旧 Vue Web 默认也使用 5173，运行前需停止它，或使用 `python tool/dev_proxy.py --port 5176` 并打开新端口。

代理只绑定回环地址，可通过 `--api-port`、`--web-port` 调整上游端口。它保留 Authorization、查询参数、请求体、HTTP 错误状态和响应体，不记录 URL、密码、令牌或请求体；不重试写请求。它仅服务本地开发，不作为生产代理。

Web 生产环境应把静态资源和后端 `/api` 放在同一 HTTPS origin；业务路径如 `/plan/wishlist` 需要静态服务器回退至 `index.html`，`/api` 必须先匹配并反向代理至后端。例如 Nginx 路由：

```nginx
location /api/ { proxy_pass http://127.0.0.1:8080; }
location / { try_files $uri $uri/ /index.html; }
```

## 原生开发与构建

原生端必须通过 `--dart-define=API_BASE_URL=完整地址` 配置后端。末尾不带 `/api` 时会自动补齐；禁止用户名、密码、查询参数或片段。Release 原生构建运行时只接受 HTTPS。Debug 可显式使用 HTTP；Android 模拟器访问宿主机使用 `http://10.0.2.2:8080/api`，真机使用可达的局域网地址。

```sh
# Windows 开发示例
flutter run -d windows --dart-define=API_BASE_URL=http://127.0.0.1:8080/api

# Android 预览版，可与旧版共存
flutter run --flavor preview -d <android-device-id> --dart-define=API_BASE_URL=http://10.0.2.2:8080/api
flutter build apk --debug --flavor preview --dart-define=API_BASE_URL=https://your-server.example/api
# 仅在正式签名已配置、版本号已核对后
flutter build appbundle --release --flavor production --dart-define=API_BASE_URL=https://your-server.example/api

# 按宿主平台执行
flutter build web --release
flutter build windows --release --dart-define=API_BASE_URL=https://your-server.example/api
flutter build linux --release --dart-define=API_BASE_URL=https://your-server.example/api
flutter build macos --release --dart-define=API_BASE_URL=https://your-server.example/api
flutter build ios --release --no-codesign --dart-define=API_BASE_URL=https://your-server.example/api
```

`your-server.example` 仅为示例，必须替换为可用后端。CI 使用 `https://moneyday.example.invalid/api` 验证编译，此保留域名没有业务服务，不能登录或用于后端验收。无签名 iOS `.app` 只能证明构建成功，不能直接安装到真机。

Android `preview` 应用 ID 为 `com.moneyday.app.flutter.preview`，仅用于共存预览。`production` 为旧版 ID `com.moneyday.app`；正式切换必须使用原签名和高于已发布版的版本号，禁止回退到 Debug 签名。生产包缺少正式签名配置时构建必须失败。正式签名凭据及商店发布不在本次源码重构交付范围。

生产签名使用本地 `android/key.properties`（不提交），键为 `storeFile`、`storePassword`、`keyAlias`、`keyPassword`，参照同目录示例文件。当前工程版本为 `0.1.0+2`，正式发布前必须与实际已发布版本核对并递增，不能仅依此默认值判断满足升级条件。

## 架构与运行规则

```text
lib/app/                  路由、会话守卫、响应式导航
lib/data/models/          Freezed JSON DTO
lib/data/services/        Dio API、认证、会话存储
lib/data/repositories/    数据访问与成功写入广播
lib/ui/core/              FeatureViewModel、表单与加载错误组件
lib/ui/features/          finance、planning、admin、auth 页面
test/                     单元、契约、ViewModel 和 Widget 测试
integration_test/         显式连接专用后端的集成测试
```

View → ChangeNotifier ViewModel → Repository → API Service，通过 Provider 注入。`go_router` 保留旧业务路径及别名。窗口宽度 `<600` 使用底部导航、`600–1199` 使用 NavigationRail、`>=1200` 使用展开侧栏；手机显示卡片，桌面显示可横向滚动的表格和看板。

后端是唯一账本来源。客户端不执行自动扣款、周期快照、资产分配或离线同步；分期计算仅作表单预填。金额和日期请求字段沿用现有 API；日期使用 `YYYY-MM-DD`，禁止把本地账务日期先转 UTC 后截取。

Web 会话只存在 `sessionStorage`，原生端只存在进程内存；原生重启后重新登录。登录、退出、到期及切用户更新 generation，取消旧请求并丢弃旧成功和错误响应；旧对话框也不得跨会话提交。初始/重置密码登录必须改密，管理员入口和直达路由均按角色限制。

断网提供刷新入口；写入失败结果不确定时先刷新核对，不自动重放财务写请求。旧 Android SQLite 文件保留，不读取、不迁移、不删除。

## 验证与切换

```sh
dart format --output=none --set-exit-if-changed lib test integration_test
flutter analyze
flutter test --reporter expanded
```

[CI](../.github/workflows/flutter.yml) 在 Ubuntu 构建 Web/Android/Linux、Windows 构建 Windows、macOS 构建 iOS/macOS，并归档产物。默认 CI 仅验证代码和编译；专用后端账户、逐端运行记账核对、正式签名与生产切换需要按 [验证记录](docs/validation.md) 单独验收。

六端功能对照、构建和真实业务运行全部通过前，不修改旧版默认入口。切换后若失败，恢复旧客户端或 Web 静态资源；共享后端账本继续使用，禁止用旧数据库快照覆盖新流水。详细过程见 [迁移清单](docs/migration-checklist.md)。
