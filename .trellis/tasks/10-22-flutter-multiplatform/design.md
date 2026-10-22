# Flutter 六端重构技术设计

## 边界
统一 Web、Android、iOS、Windows、macOS、Linux；完整迁移两套前端；Material 3；并行开发，验收后切换。
新增独立 flutter-frontend 工程；旧 Vue 与 Capacitor 工程保留。

## 架构与接口
采用 Views → ChangeNotifier ViewModel → Repository → Dio API Service。Provider 注入，go_router 路由，Freezed/JSON 类型模型，fl_chart 图表。
严格沿用 `/api` 和 `{code,message,data}`，DTO 以当前控制器和实体为准。请求捕获会话 generation，登录变化取消请求并丢弃迟到成功与错误。HTTP 状态与业务 code 都校验；没有财务写入自动重试。
Web sessionStorage，原生仅内存。`API_BASE_URL` 使用 dart-define；Web 默认同源，原生完整 HTTPS，Debug 可显式 HTTP。
宽度 <600 底部导航，600–1199 NavigationRail，>=1200 展开侧栏。

## 迁移与回退
Android 预览应用 ID 与旧版分离；正式 ID com.moneyday.app 使用原签名与递增版本号。保留历史 SQLite 文件但不导入、不读写。六端验收前不切换默认入口。

## 实施依赖
父任务负责集成与跨子任务验收。
