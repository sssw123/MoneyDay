# Flutter 六端重构实施计划

1. 阅读父方案、当前前端规范及 research/shared-contract.md。
2. 实现本任务范围：统一 Web、Android、iOS、Windows、macOS、Linux；完整迁移两套前端；Material 3；并行开发，验收后切换。
3. 运行 `dart run build_runner build --delete-conflicting-outputs`、`dart format`、`flutter analyze`、`flutter test`。
4. 验证业务请求与后端控制器字段一致、旧用户结果不会污染新会话。
5. 在目标主机执行各端构建与集成测试；记录实际命令和阻塞原因。
6. 更新功能对照、验证记录、规范和回退文档。
7. 不自动提交；呈现具体提交文件与中文提交信息，等待用户确认。

## 回退点
旧版入口不变；Flutter 新目录可独立运行。构建或验收失败不切换入口。
