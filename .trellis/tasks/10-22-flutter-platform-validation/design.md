# 六端验收与切换准备技术设计

## 前置依赖

依赖前三个子任务。先完成代码和自动化，再逐端构建/运行对账，最后才允许切入口。

## 模块与数据流

- GitHub Actions 在 Ubuntu 构建 Web/Android/Linux、Windows 构建 Windows、macOS 构建 iOS/macOS。
- CI 使用保留域名只验证编译；真实集成测试显式读取专用配置，缺配置失败，默认不执行真实写入。
- Android preview 独立 ID，production 使用原 ID/签名并递增版本；缺正式签名必须构建失败。
- 验证记录区分源码、自动化、编译和真实运行；六端门槛未全通过，维持旧入口，任务保持 in_progress。

## 兼容与回退

共享现有 Spring Boot 云端账本；沿用现有 /api 和 {code,message,data}。旧 Vue/Capacitor 保持独立可运行，六端验收之前不切默认入口；客户端回退不回滚有效云端流水。

## 决策依据

父任务 design.md 与 research/shared-contract.md；可执行规则见 ../../spec/frontend/flutter-architecture.md，结果见 acceptance.md。
