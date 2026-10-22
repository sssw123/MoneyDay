# 计划与管理实施计划

## 执行顺序

依赖基础架构和核心记账的账户/分类/周期契约，之后集成计划与管理。

- [x] 阅读父任务与前端云端账本契约，核对现有后端/两套旧前端。
- [x] 迁移心愿单与长期目标 CRUD、兑现/撤销、超支确认、资产与账户余额校验。
- [x] 迁移负债录入、利率试算预览、已还补录、多期提前还款、金额校准、提前结清。
- [x] 迁移待办计数/筛选/补扣/预算跳转/兑现/忽略/完成。
- [x] 迁移管理员用户分页搜索、创建、停启用、重置密码和删除；支持个人密码管理。
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
