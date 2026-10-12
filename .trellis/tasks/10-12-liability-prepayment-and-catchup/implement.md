# 执行计划: 透支还款与历史分期补录优化

## 1. 数据库升级与实体调整
- [x] 执行数据库迁移：在 `liability` 表添加 `next_repayment_date` 字段，并初始化现有数据的下次应还日期。
- [x] 实体更新：
  - 更新 `Liability.java` 增加 `nextRepaymentDate` 并配置 updateStrategy。
  - 更新 `LiabilityVO.java` 增加 `nextRepaymentDate`。

## 2. 后端核心业务改造
- [x] `LiabilityService` 与 `LiabilityServiceImpl`：
  - 改造 `addLiability`：支持接收 `currentPeriod` 与 `nextRepaymentDate`，补录时不生成任何扣款流水。
  - 新增 `repayPeriods`：提前还期逻辑，支持归还 1~N 期，扣款、推进期数、顺延 `nextRepaymentDate`。
  - 完善 `settleLiability`：结清逻辑，结清全部剩余期数并清空 `nextRepaymentDate`。
  - 重构 `checkAndExecuteDueRepayments`：以 `today >= nextRepaymentDate` 为触发条件，杜绝跨周期重复扣款。
- [x] `LiabilityController`：
  - 新增 `POST /api/liabilities/{id}/repay` 提前还期接口。

## 3. 前端界面与交互优化
- [x] `Liability.vue`：
  - 录入/编辑分期表单：增加「已还期数」与「下一次应还日期」字段。
  - 列表表格：展示「下期还款日」，优化进度条为「已还 X/Y 期」。
  - 还款弹窗：升级为双 Tab 模式（Tab 1: 提前还期，Tab 2: 提前结清），支持归还期数步进选择与金额微调。

## 4. 验证与测试
- [x] 后端编译与单元测试：`mvn test` 通过。
- [x] 前端打包编译：`npm run build` 0 报错通过。
- [x] 场景验收测试：
  - 验证补录历史期数（3/12 期）不产生流水、待还金额准确；
  - 验证提前还 1 期后，下次还款日后延 1 个月，状态保持还款中；
  - 验证提前结清后，状态标记为已结清。
- [x] 呈现 Commit Plan 等待用户确认。
