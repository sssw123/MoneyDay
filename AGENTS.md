<!-- TRELLIS:START -->
# Trellis Instructions

These instructions are for AI assistants working in this project.

This project is managed by Trellis. The working knowledge you need lives under `.trellis/`:

- `.trellis/workflow.md` — development phases, when to create tasks, skill routing
- `.trellis/spec/` — package- and layer-scoped coding guidelines (read before writing code in a given layer)
- `.trellis/workspace/` — per-developer journals and session traces
- `.trellis/tasks/` — active and archived tasks (PRDs, research, jsonl context)

If a Trellis command is available on your platform (e.g. `/trellis:finish-work`, `/trellis:continue`), prefer it over manual steps. Not every platform exposes every command.

If you're using Codex or another agent-capable tool, additional project-scoped helpers may live in:
- `.agents/skills/` — reusable Trellis skills
- `.codex/agents/` — optional custom subagents

<!-- TRELLIS:END -->

# 项目特定约束与契约 (Project Specific Conventions)

## Git Commit 提交信息规范
所有 `git commit` 提交信息必须严格遵循 **`<type>: <中文描述>`** 格式：
- `feat: <中文新功能描述>`
- `fix: <中文Bug修复描述>`
- `refactor: <中文重构描述>`
- `docs: <中文文档修改描述>`
- `style: <中文样式调整描述>`
- `test: <中文测试用例变动描述>`
- `chore: <中文构建/工具/配置变动描述>`

详情参见：[git-commit-convention.md](file:///d:/IDEAProjects/MoneyDay/.trellis/spec/guides/git-commit-convention.md)。

