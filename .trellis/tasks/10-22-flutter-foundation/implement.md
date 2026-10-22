# 基础架构与登录实施计划

## 执行顺序

无；必须先建立共享数据与会话契约。

- [x] 阅读父任务与前端云端账本契约，核对现有后端/两套旧前端。
- [x] 锁定 Flutter stable 3.47.7、Dart 3.13.5 和依赖版本，生成 Web、Android、iOS、Windows、macOS、Linux 六端工程。
- [x] 提供 Material 3 中文主题、底部导航、NavigationRail 和展开侧栏，断点为 600/1200。
- [x] 支持登录、退出、过期、强制改密、管理员权限及 Web 会话存储/原生内存会话。
- [x] 保持 /api 与包络契约，切用户取消旧请求、丢弃旧响应，财务写入不重试，恢复内部深链接。
- [x] 执行生成器一致性、格式、flutter analyze 和 flutter test，修正审查问题。
- [x] 记录本机 Web/Windows 构建、旧端与后端安全单测结果。
- [x] 更新规范、对照表、运行/切换/回退手册和 acceptance.md。
- [ ] 专用后端与目标宿主就绪后逐端运行、核对账本和完整手工回归。
- [ ] 六端及旧端/后端业务门槛通过后评审默认入口切换。
- [ ] 提交具体文件和中文 commit 计划，用户明确确认后提交；不自动 push。

## 验证命令

```sh
dart run build_runner build --delete-conflicting-outputs
dart format --output=none --set-exit-if-changed lib test integration_test
flutter analyze --no-pub
flutter test --no-pub --reporter expanded
```

逐平台构建与真实集成命令、退出码及待验收项见 ../../../flutter-frontend/docs/validation.md。

## 回退点

维持旧入口，不删除旧源码、历史SQLite或有效云端流水；出现不确定写入先刷新核对。
