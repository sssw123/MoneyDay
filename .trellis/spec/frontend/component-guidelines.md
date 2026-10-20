# Component Guidelines

> How components are built in this project.

---

## Overview

<!--
Document your project's component conventions here.

Questions to answer:
- What component patterns do you use?
- How are props defined?
- How do you handle composition?
- What accessibility standards apply?
-->

(To be filled by the team)

---

## Component Structure

<!-- Standard structure of a component file -->

(To be filled by the team)

---

## Props Conventions

<!-- How props should be defined and typed -->

(To be filled by the team)

---

## Styling Patterns

<!-- How styles are applied (CSS modules, styled-components, Tailwind, etc.) -->

(To be filled by the team)

---

## Accessibility

<!-- A11y requirements and patterns -->

(To be filled by the team)

---

## Common Mistakes

<!-- Component-related mistakes your team has made -->

(To be filled by the team)

## Web 主题与响应式约定（2026-10-20）

- 全局主题在 `src/App.vue` 的 ConfigProvider 中定义，公共样式由 `src/main.ts` 导入 `src/style.css`。颜色变量 `--positive` / `--negative` 保留业务语义，主按钮为深色；不要全局覆盖所有文本/标签颜色。
- 当前 Ant Design **Vue** 4.x 的 Menu tokens 使用 `colorItemBgSelected`、`colorItemTextSelected`、`radiusItem`，不能复制 React Ant Design 的 `itemSelectedBg` 等 token。Button、Table 特有外观优先使用合法 alias tokens 和公共 CSS，必须经过 vue-tsc 验证。
- 桌面侧栏与移动抽屉复用 `AppNavigation.vue`；768px 以下为抽屉，768–1199px 默认折叠，1200px 以上默认展开。matchMedia change 监听器须在卸载时清除。
- 业务页根容器使用 `business-page`，操作栏使用 `page-toolbar`。表格添加 `:scroll="{ x: 'max-content' }"`，数值列右对齐；不要通过隐藏页面 overflow 掩盖布局超宽。
- 无 href 的表格操作使用 `<a-button type="link" size="small">`，删除使用 `danger`，保留原有 Popconfirm 确认。弹窗固定项目行使用 `fixed-item-row`，小屏内每项占满一行。
- 按钮动效由公共 `.ant-btn` CSS 控制，仅操作 transform 和阴影，不使用计时器延迟请求。hover 不得覆盖释放时的 400ms 回弹时间；disabled/loading 禁用位移，prefers-reduced-motion 关闭动画但保留 focus-visible。
- 数据图表没有正数数据时显示明确空态，不能用示例值填图；vue-echarts 使用 autoresize 跟随侧栏和视口变化。
