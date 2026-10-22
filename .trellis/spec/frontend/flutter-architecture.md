# Flutter 六端客户端契约

## 1. Scope / Trigger：适用范围与触发条件

本规范适用于独立 `flutter-frontend`，包括 Web、Android、iOS、Windows、macOS、Linux。Flutter 引入新命令、环境键和跨层会话/HTTP 契约，必须按以下可执行约定实现。旧 Vue/Capacitor 继续按既有规范运行，六端验收前不替换默认入口。

固定 Flutter stable `3.47.7`、Dart `3.13.5`；`.fvmrc`、CI 和 `pubspec.lock` 保持一致。后端是唯一账本，禁止增加 SQLite 读写、离线账本、客户端自动扣款或快照计算。分期试算只预填表单，最终金额和资产约束由服务端校验。

## 2. Signatures：命令、调用层与 API

```sh
flutter pub get --enforce-lockfile
dart run build_runner build --delete-conflicting-outputs
dart format --output=none --set-exit-if-changed lib test integration_test
flutter analyze
flutter test --reporter expanded
flutter run -d web-server --web-hostname=127.0.0.1 --web-port=5175
python tool/dev_proxy.py --port 5173 --api-port 8080 --web-port 5175
flutter build apk --debug --flavor preview --dart-define=API_BASE_URL=https://your-server.example/api
```

依赖方向为 View → ChangeNotifier ViewModel → Repository → Dio API Service，以 Provider 注入。页面不直接拼 HTTP 或解析响应；模型使用 Freezed/JSON。新业务 DTO 加入 `lib/data/models/models.dart`，重新运行生成器；禁止手改 `.freezed.dart` / `.g.dart`。

```dart
Future<dynamic> ApiClient.request(String method, String path, {
  Object? data, Map<String, dynamic>? query,
  bool authenticated = true, bool handleAuthError = true,
  String? capturedToken, bool isolate = true,
});
Future<T> ApiClient.inSession<T>(int generation, Future<T> Function() operation);
Future<void> FeatureViewModel.fetch();
Future<void> FeatureViewModel.load();
Future<bool> FeatureViewModel.run(Future<void> Function() command);
```

Repository 成功写入后 `notifyListeners()`，存活 ViewModel 自动重新读取受影响数据。`fetch()` 先 await 本次所需全部数据，再统一赋值，避免半途混合用户状态；含筛选的页面还需防止旧查询覆盖新查询。

沿用现有端点，尤其不得混淆下面几个字段：

| 操作 | 方法与路径（相对 `/api`） | 请求 / 响应要点 |
| --- | --- | --- |
| 登录 | `POST /user/login` | `{username,password}` → `{token,expiresAt,user}` |
| 资料与改密 | `GET /user/profile`、`PUT /user/password` | 改密体 `{oldPassword,newPassword}`，成功后重新登录 |
| 目标/心愿兑现 | `POST /targets/{id}/realize`、`POST /wishlists/{id}/realize` | `{accountId}`，撤销使用对应 `/unrealize` |
| 多期还款 | `POST /liabilities/{id}/repay` | `{accountId,periods,amount}` |
| 提前结清 | `POST /liabilities/{id}/settle` | `{accountId,settleAmount}`，不能用 `amount` 作为 wire 字段 |
| 待办计数 | `GET /todos/pending-count` | `data: {count: int}` |
| 管理员列表 | `GET /admin/users` | query `page,pageSize,keyword,status` → `data: {records,total,...}` |

## 3. Contracts：请求、响应、环境与平台

- 使用 Bearer Authorization；响应为 `{code:200,message:String,data:any}`。HTTP 状态与业务 `code` 都成功才返回 `data`，HTTP 错误不能被 body 中 `200` 覆盖。
- 金额 DTO 使用 `num`，正金额表单只接受有限、大于零、最多两位小数的普通十进制，拒绝科学计数及超过分精度，避免数据库静默舍入；账务日期是服务端 `YYYY-MM-DD` 字符串，不进行 UTC 日期平移。日期弹窗的初始日期须夹取到 picker 的允许范围。保存字段以真实控制器为准。
- `API_BASE_URL` 为 `--dart-define`：Web 未设置或为 `/api` 时走同源；原生必须完整 HTTP(S) 地址。末尾自动补 `/api`；拒绝 userinfo、query、fragment，Release 显式地址必须 HTTPS。
- Web 使用 `sessionStorage`，原生仅进程内会话。登录、退出、到期和换用户递增 generation，取消请求，丢弃迟到成功和错误。403 重新读取 profile，401 清会话。首次/重置密码限制业务路由，普通用户不能直接进入管理员路由。
- `showFormDialog` / `confirmAction` 捕获 generation；切换会话精确关闭旧弹窗，提交前再次验证，避免旧表单使用新用户令牌。
- 小于 600 使用底部导航；600–1199 使用 NavigationRail；1200 及以上展开侧栏。手机卡片、桌面表格，表格宽时允许水平滚动；表单适配键盘和短视口。
- 保留 `/`, `/transactions`, `/accounts`, `/categories`, `/budget`, `/plan/targets`, `/plan/wishlist`, `/plan/liabilities`, `/todos`, `/settings`, `/admin/users`；别名 `/budgets`,`/wishlist`,`/plan`,`/mine` 映射至现有业务入口。
- 冷启动验证会话或登录后恢复原业务路径和查询参数，别名跳转也保留查询。返回地址只接受内部已登记业务路由，拒绝外部 URL、登录/会话循环；恢复后继续执行改密和管理员守卫。
- Web path URL 必须配置 SPA `index.html` 回退，`/api` 先由后端代理匹配。开发代理只监听 `127.0.0.1`，保留查询、Authorization、请求体及上游状态，不记录凭据或跟随重定向，不重试写入。
- Android preview ID 为 `com.moneyday.app.flutter.preview`，与旧版共存；production 为 `com.moneyday.app`，使用原签名和更高版本号。`android/key.properties` 的 `storeFile/storePassword/keyAlias/keyPassword` 本地保存，不提交；缺失时 ProductionRelease 必须失败，禁止 Debug 签名兜底。
- 真后端集成配置键为 `API_BASE_URL`、`TEST_USERNAME`、`TEST_PASSWORD`、`ALLOW_TEST_WRITES=true`，通过未提交 JSON 的 `--dart-define-from-file` 传入。仅在专用测试账本运行；CI 默认不运行该测试。

## 4. Validation & Error Matrix：校验与错误矩阵

| 条件 | 必需行为 |
| --- | --- |
| 未配置原生 API / Release 显式 HTTP | 显示配置错误，不能连接默认生产后端 |
| HTTP 非 2xx 或业务 code 非 200 | 失败，展示服务端可用消息；401/403 只处理当前 generation |
| 退出或用户切换后的成功/错误 | 丢弃，不刷新新用户 UI、不使新用户退出 |
| 断网/超时 GET | 显示错误和刷新入口 |
| 断网/超时写入 | 提示操作结果未知，刷新核对；无自动重放 |
| 密码少于 8 Unicode 码点 / UTF-8 超过 72 字节 | 阻止提交 |
| 用户名不满足 `[A-Za-z0-9_.-]{3,50}` | 阻止创建，服务端最终校验并归一化 |
| 目标可用净资产不足 / 扣款账户余额不足 | 阻止兑现；服务端最终校验 |
| 心愿累计结余不足 | 明确二次确认；账户余额仍是硬限制 |
| 固定项目已到账 / 多次提交还款 | 禁止按钮重复提交，服务端保证业务防重，客户端不本地扣款 |
| 无生产 Android 签名 | ProductionRelease 失败，preview 可独立 Debug 构建 |
| 无目标宿主或真实后端 | 标为待验收，不记为通过 |

## 5. Good / Base / Bad Cases：可验证示例

- Good：Web 通过 `127.0.0.1:5173` 访问 `/api/accounts?q=...`，代理保留 Bearer 及 query；真实测试账号完成记账后与旧 Web 对账。
- Base：`flutter test` 使用内存/假 HTTP 响应验证请求契约及 UI；CI 使用 `https://moneyday.example.invalid/api` 构建六端，结果只标编译通过。
- Bad：拿 CI 占位地址声称已完成登录验收；没有 macOS 主机却把 iOS/macOS 记为通过；将原生 token 写入持久化偏好；网络恢复后重放全部财务写请求；用 Debug 签名覆盖旧 Android。

## 6. Tests Required：测试与断言点

- API 契约：验证实际方法、路径、query、wire 字段和 Authorization；HTTP 错误/body错误、无效 envelope、401/403、写入不重试。
- 会话：A 的迟到成功和错误在 B 登录后均不可见；旧弹窗移除，提交被阻止；Web 会话存储与原生进程内存、过期清除、改密/管理员守卫。
- 业务：转账、固定项目防重/撤销、心愿超支取消不写入、目标资产限制、多期还款及金额调整、提前结清、待办账户补扣、管理员分页与 Unicode 密码。
- UI：手机/平板/桌面及 599/600/1199/1200 断点，横屏、键盘、长文案、加载、失败和空数据；无布局溢出。
- 平台：三宿主 CI 构建六端，逐平台真机/模拟器或桌面启动、登录、读账本、写入后核对；旧后端与两个旧前端回归。缺环境时保留待验收。

执行命令、状态和切换门槛保存在 `flutter-frontend/docs/validation.md` 与 `migration-checklist.md`，六端与功能对照全部通过再切默认入口。

## 7. Wrong vs Correct：错误与正确写法

错误：结清字段与服务端不一致，失败后自动重放，可能重复财务操作。

```dart
await dio.post('/liabilities/$id/settle', data: {'amount': amount});
// 网络恢复后再次执行此写入。
```

正确：通过 Repository 使用真实 `settleAmount` wire 字段；失败后只刷新核对。

```dart
await repository.settle(id, accountId: accountId, amount: amount);
// Repository: POST /liabilities/{id}/settle
// body: {accountId: accountId, settleAmount: amount}
// 写入结果未知时展示错误，用户刷新并核对后自行决定下一步。
```
