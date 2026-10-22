# 基础架构与登录技术设计

## 前置依赖

无；必须先建立共享数据与会话契约。

## 模块与数据流

- View → ChangeNotifier ViewModel → Repository → Dio Service，Provider 注入依赖。
- Freezed/JSON DTO 对齐当前后端字段；HTTP 状态与业务 code 同时检查。
- generation + CancelToken + Dart Zone 隔离异步操作；弹窗绑定会话，退出动画结束后释放表单控制器。
- go_router 先验证会话再执行强制改密/管理员守卫，returnTo 仅允许内部登记业务路径。

## 兼容与回退

共享现有 Spring Boot 云端账本；沿用现有 /api 和 {code,message,data}。旧 Vue/Capacitor 保持独立可运行，六端验收之前不切默认入口；客户端回退不回滚有效云端流水。

## 决策依据

父任务 design.md 与 research/shared-contract.md；可执行规则见 ../../spec/frontend/flutter-architecture.md，结果见 acceptance.md。
