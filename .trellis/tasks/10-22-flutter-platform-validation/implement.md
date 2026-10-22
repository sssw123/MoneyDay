# 六端验收与切换准备实施计划

## 执行顺序

依赖前三个子任务。先完成代码和自动化，再逐端构建/运行对账，最后才允许切入口。

- [x] 阅读父任务与前端云端账本契约，核对现有后端/两套旧前端。
- [x] 建立固定 SDK 的三宿主六端 CI 构建矩阵并交付源码、构建配置与验证产物。
- [x] 执行格式、分析、DTO/请求契约、ViewModel、关键 Widget 测试及旧端/后端回归。
- [x] 六端各自启动、登录、读取账本、记账核对；覆盖手机/平板/桌面、键盘、横屏、缩放、空态和错误。
- [x] 更新启动文档、前端规范、功能对照、切换与回退手册；缺环境明确待验收，禁止伪报通过。
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
