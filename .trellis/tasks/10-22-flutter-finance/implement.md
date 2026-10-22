# 核心记账实施计划

## 执行顺序

依赖基础架构与登录；共享 DTO、API、会话与导航契约先通过，再集成业务。

- [x] 阅读父任务与前端云端账本契约，核对现有后端/两套旧前端。
- [x] 迁移看板资产、收支、固存、累计结余、趋势及分类图表，金额隐藏、前三笔待还分期、历史周期表。
- [x] 迁移账户、分类、收入、支出、转账、流水编辑删除和筛选。
- [x] 迁移周期预算、固定项目到账及撤销、防重复记账、周期模板设置。
- [x] 手机显示卡片，桌面显示表格与多列看板；财务写入成功后刷新相关数据。
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
