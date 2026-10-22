# 核心记账技术设计

## 前置依赖

依赖基础架构与登录；共享 DTO、API、会话与导航契约先通过，再集成业务。

## 模块与数据流

- finance 按页面创建 ViewModel，组合查询全部完成并验证 generation 后统一赋值。
- 转账沿用服务端 type/accountId/toAccountId；不在本地修改账本余额。
- 固定项目沿用 cycleId/itemId，保存期间禁止重复；无真实周期 ID 时不开放写入。
- 图表只显示服务端实际数据；隐私开关遮罩金额文本及 tooltip。正金额最多两位小数，日期保留本地账务字符串。

## 兼容与回退

共享现有 Spring Boot 云端账本；沿用现有 /api 和 {code,message,data}。旧 Vue/Capacitor 保持独立可运行，六端验收之前不切默认入口；客户端回退不回滚有效云端流水。

## 决策依据

父任务 design.md 与 research/shared-contract.md；可执行规则见 ../../spec/frontend/flutter-architecture.md，结果见 acceptance.md。
