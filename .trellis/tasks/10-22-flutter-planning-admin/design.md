# 计划与管理技术设计

## 前置依赖

依赖基础架构和核心记账的账户/分类/周期契约，之后集成计划与管理。

## 模块与数据流

- Goals/Liabilities/Todos/Users 四个 ViewModel，数据通过 Repository 与共享 Service 访问。
- 心愿超支二次确认不能绕过账户余额；长期目标保留净资产门槛，最终仍由后端校验。
- 分期利率/手续费仅用于表单预填；repay 使用 periods/amount，settle 使用 settleAmount。
- 所有财务写入成功广播刷新，按 generation 原子提交组合查询；权限由前端守卫和服务端共同校验。

## 兼容与回退

共享现有 Spring Boot 云端账本；沿用现有 /api 和 {code,message,data}。旧 Vue/Capacitor 保持独立可运行，六端验收之前不切默认入口；客户端回退不回滚有效云端流水。

## 决策依据

父任务 design.md 与 research/shared-contract.md；可执行规则见 ../../spec/frontend/flutter-architecture.md，结果见 acceptance.md。
