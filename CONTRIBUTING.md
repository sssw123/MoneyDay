# 参与贡献 MoneyDay

感谢你对 MoneyDay 项目的关注与支持！我们欢迎社区贡献，无论是修复问题、优化文档还是提出新功能想法。

## 贡献流程

1. **Fork 本仓库** 到你的 GitHub 个人账号。
2. **克隆你的 Fork** 到本地：
   ```bash
   git clone https://github.com/<your-username>/MoneyDay.git
   cd MoneyDay
   ```
3. **基于 `master` 分支创建功能分支**：
   ```bash
   git checkout -b feature/amazing-feature
   # 或修复分支
   git checkout -b fix/issue-description
   ```
4. **进行开发与本地验证**：
   - 遵循项目中已有的代码规范与分层设计；
   - 确保修改后构建与测试能够正常通过：
     - 后端：`mvn test-compile`
     - 前端：`npm run build`
5. **提交 Commit**（严格遵循提交规范，见下文）。
6. **推送至你的远程分支**：
   ```bash
   git push origin feature/amazing-feature
   ```
7. **发起 Pull Request**，详细描述改动内容与解决的问题。

---

## Git Commit 提交信息规范

所有 `git commit` 提交信息必须严格遵循 **`<type>: <中文描述>`** 格式：

```text
<type>: <中文描述>
```

### 常用 Type 类型

| Type | 说明 | 示例 |
| :--- | :--- | :--- |
| `feat` | 新功能 / 特性 | `feat: 增加按分类筛选导出报表功能` |
| `fix` | 修复缺陷 / Bug | `fix: 修复多账户联动时余额计算精度问题` |
| `refactor` | 重构代码（不改变对外行为） | `refactor: 提取公共 SQLite DAO 基础层` |
| `docs` | 仅更新文档相关 | `docs: 更新 README 中的 Android 打包命令` |
| `style` | 代码格式调整（空格、分号等，不涉及逻辑） | `style: 格式化 MyBatis-Plus 映射层代码` |
| `test` | 新增或修改测试用例 | `test: 增加账单周期快照边界值测试` |
| `chore` | 构建流程、依赖或辅助工具变动 | `chore: 升级 Vite 依赖版本` |

---

## 代码风格与规范

- **Java 后端**：
  - 遵循标准阿里巴巴 Java 开发规范与 Spring Boot 官方约定；
  - 金额统一采用 `BigDecimal`，接口传输统一使用带两位小数的数字字符串，禁止使用 float/double 进行资金计算；
  - 实体命名清晰，使用驼峰命名法。
- **Vue 前端**：
  - 使用 Vue 3 `<script setup lang="ts">` 组合式 API；
  - 严格保持 TypeScript 类型安全，避免滥用 `any`；
  - 保持组件单一职责，业务逻辑复杂时适当拆分 hooks。
- **保护隐私**：
  - 切勿将任何个人私钥、密码、本地私有代理地址提交至版本库；
  - 本地环境配置文件请使用 `application-local.yml`（已被 git 忽略）。

---

## 报告 Bug 与功能建议

- 如发现 Bug 或有新的功能提议，请先在 [Issues](https://github.com) 列表中搜索是否已有类似讨论；
- 若未找到，欢迎提交新的 Issue，并尽量详细描述复现步骤、预期行为与运行环境。
