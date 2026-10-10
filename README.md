# MoneyDay · 记账与攒钱

MoneyDay 是为个人日常使用设计的记账与攒钱项目：记录钱从哪里来、花到哪里去，了解账户余额与每月预算，并持续跟踪攒钱目标。

第一阶段开发适配手机和电脑浏览器的网站；后续可增加 PWA 安装体验，让网站可以从手机桌面打开。原生 Android / iOS App 暂不属于第一阶段。

> 当前状态：需求与工程规划，尚未创建前后端代码、数据库或部署环境。本文中的功能、目录、配置和启动命令均为计划约定，不能视为已经实现或验收通过。
>
> 技术栈已确认 Vue 3 + TypeScript、Java + Spring Boot、MySQL

## Scope · 项目范围

### 第一阶段：完成记账与攒钱闭环

| 模块 | 计划功能 | 范围约定 |
| --- | --- | --- |
| 登录与个人设置 | 登录、退出、修改密码、时区设置 | 初期个人自用，不开放公众注册；不提供固定默认密码 |
| 收支记账 | 新增、编辑、删除收入与支出，记录金额、日期、分类、账户和备注 | 以手动录入为主；删除与修改同步修正余额和统计 |
| 账户管理 | 现金、银行卡、电子钱包等账户，期初余额、当前余额、账户间转账 | 账户表示手动维护的账本，不连接银行或支付平台 |
| 分类管理 | 收入分类、支出分类和自定义分类 | 已使用的分类可停用；避免删除后历史记录失去分类 |
| 月度预算 | 设置每月总支出预算，展示已花、剩余和超支情况 | 首期只做总预算，按分类预算留到后续 |
| 攒钱目标 | 设置名称、目标金额、可选截止日期，记录存入与取出，查看进度 | 记录目标资金分配，不提供实际转账或理财服务 |
| 首页与统计 | 本月收入、支出、结余、账户总余额、预算进度、分类占比、月度趋势 | 所有统计来自实际记录；空数据展示空状态 |

### 后续可扩展

- PWA：手机桌面安装与独立窗口打开；离线记账需要单独设计同步和冲突处理。
- 定期记账、分类预算、提醒与账单导入。
- 多用户注册或家庭共享账本，另行确认成员权限和数据隔离规则。

### 第一阶段不包含

银行 / 微信 / 支付宝自动抓取、支付与真实资金托管、证券交易、投资建议、复杂信用卡账期、多币种汇率换算、微服务和原生移动 App。

## Accounting Rules · 记账规则

- 默认币种暂定人民币 CNY，首期只使用一种币种；默认时区暂定 `Asia/Shanghai`，待确认。
- 金额使用后端 `BigDecimal` 与数据库 `DECIMAL(18,2)`；接口以十进制字符串传递金额，避免浮点误差。普通收支金额必须大于零，输入超过两位小数时明确拒绝，不静默舍入。
- 收入增加账户余额，支出减少账户余额。期初余额不计入当月收入；当前余额由期初余额和账户流水计算。
- 账户间转账同时记录转出与转入，并在同一事务中完成；不计入收入、支出或月度预算。
- 月度结余 = 当月收入 − 当月支出；账户总余额包含历史积累，与月度结余分开展示。
- 月度预算按记账日期所在月份汇总支出，账户转账和目标分配不消耗预算。
- 攒钱目标表示现有资金的用途分配。为目标存入 500 元，不会凭空增加总资产，也不重复计为支出；取出仅减少目标已分配金额。
- 目标资金必须关联账户；同一账户各目标的已分配金额合计不得超过其余额。会导致超额分配的支出、转账或历史记录修改应明确提示，先调整目标分配再保存。
- 一笔记录的新增、修改、删除与相关余额、预算和目标校验必须一致完成；失败时回滚，不允许只更新部分数据。
- 有历史流水的账户采用停用处理，保留历史记录；停用前应处理余额及目标分配。

## Technical Scope · 技术方案

| 层次 | 计划方案 | 说明 |
| --- | --- | --- |
| 前端 | Vue 3、TypeScript、Vite、Vue Router、Pinia | 手机优先的响应式页面 |
| UI 与图表 | Ant Design Vue、ECharts | 页面按个人记账场景精简 |
| 后端 | Java 17、Spring Boot | 单应用，按账户、记账、预算、目标划分业务包 |
| 数据访问 | MyBatis、MySQL | SQL 与数据库迁移脚本纳入版本管理 |
| 会话 | 模拟随机验证码 + 随机token + redis | 引入 Redis 方式 |
| 发布物 | 前端静态资源 + 后端可执行 JAR | 使用嵌入式服务器 |

具体 Spring Boot、Vite 及其他依赖版本在工程初始化时确认兼容性，再固定到构建文件与锁文件。参考文件中的版本号不直接作为本项目依赖版本。

## Required Tools · 本机环境

以下是 2026-10-10 在本机 PowerShell 的 PATH 中实际查询到的结果，不代表 IDEA、Docker 或远程服务使用相同版本。

| 工具 | 本机检测结果 | 项目处理方式 |
| --- | --- | --- |
| Java | 17.0.20.1 | 计划以 Java 17 为基线；初始化时核对 IDEA Project SDK 与 Maven 使用的 JDK |
| Maven | 3.6.3 | 已检测到；能否满足最终依赖组合待确认，初始化时固定 Maven Wrapper 版本 |
| Node.js | 24.9.0 | 已检测到；最终以选定 Vite 的要求为准 |
| MySQL 客户端 | 8.0.46 | 客户端版本已检测；服务端版本、运行状态和连接配置待确认 |
| Redis 服务程序 | 8.10.1 | 命令可用；不代表服务正在运行，首期是否使用尚未确定 |

### 如何查询本机版本

在 PowerShell 中逐条运行：

```powershell
java -version
javac -version
mvn -version
node --version
npm --version
mysql --version
redis-server --version
git --version
```

如果提示找不到命令，可能是未安装，也可能是未加入 PATH。可检查命令位置：

```powershell
Get-Command java, javac, mvn, node, npm, mysql, redis-server, git -ErrorAction SilentlyContinue |
    Select-Object Name, Source
```

IDEA 中还需检查 **File → Project Structure → Project SDK**，以及 **Settings → Build Tools → Maven** 的 Maven 路径和 Runner JRE；终端的版本不保证与 IDEA 配置相同。

### 查询 MySQL 服务端版本

下面的命令需要 MySQL 已启动，以及有效的连接信息。将占位值替换为本机配置；`-p` 会交互式询问密码，不要把密码直接写在命令中：

```powershell
mysql -h <数据库主机> -P <数据库端口> -u <数据库用户名> -p -e "SELECT VERSION();"
```

## Project Layout · 计划目录

下列目录尚未创建，将在工程初始化阶段落地：

```text
MoneyDay/
├─ README.md
├─ frontend/                  # Vue 前端
│  └─ src/
├─ backend/                   # Spring Boot 后端
│  └─ src/main/
│     ├─ java/                 # 按业务包组织
│     └─ resources/
│        └─ db/migration/      # 数据库迁移脚本
└─ deploy/                    # 部署与备份恢复说明
```

## Local Development · 计划启动方式

> 以下命令是未来工程的启动约定。目前没有 `frontend`、`backend`、`package.json` 或 Maven 工程，暂时不能执行这些启动命令。

### 启动后端

完成数据库初始化和外部配置后，在 IDEA终端 中执行：

```
cd D:\IDEAProjects\MoneyDay\backend
$env:SPRING_PROFILES_ACTIVE="dev,local"; bash app.sh start
```

计划后端地址为 `http://localhost:8080`，API 前缀为 `/api`。

### 启动前端

另开一个 IDEA终端 窗口：

```
cd D:\IDEAProjects\MoneyDay\frontend
npm run dev
```

计划前端地址为 `http://localhost:5173`，开发代理将 `/api` 转发至后端。手机访问需要另行配置局域网监听、防火墙与 API 访问方式，不能直接使用手机上的 `localhost` 连接电脑。


## Build · 计划构建方式

工程建立后，分别执行：

```powershell
cd D:\IDEAProjects\MoneyDay\frontend
npm run build
```

```powershell
cd D:\IDEAProjects\MoneyDay\backend
.\mvnw.cmd clean verify
```

计划输出为 `frontend/dist/` 与 `backend/target/` 下的可执行 JAR。初期部署采用单实例，前端与 `/api` 由同一入口提供服务。具体部署位置和反向代理方案待确认。
