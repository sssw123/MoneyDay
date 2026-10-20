# MoneyDay 多用户运行与验收

## 运行

后端使用 Java 17、MySQL 8；两个前端使用 Node 22。Web 为 `http://127.0.0.1:5173/`，Android 浏览器调试为 `http://127.0.0.1:5174/`。

后端本地配置 `backend/src/main/resources/application-local.yml` 指向 **moneyday_multiuser**。本轮已在用户新建的云端空库完成初始化，原单用户库保留。认证、用户管理与所有账本数据均在新库中。数据库配置文件不会提交。

```sh
cd backend
mvn spring-boot:run
# 另一终端
cd frontend
npm ci
npm run dev
# Android 浏览器调试（另一终端）
cd android-frontend
npm ci
npm run dev
```

初始管理员用户名为 `admin`，密码通过 `MONEYDAY_ADMIN_PASSWORD` 注入创建，首次登录强制修改。首次初始化缺少合法环境密码时启动失败，不会创建默认弱密码。管理员已存在时重启无需该变量，设置新环境密码也不会重置既有管理员。

本轮生成的临时初始密码保存在本机 `/tmp/moneyday-multiuser-admin-password`（仅当前用户可读），不写入代码或日志。登录改密后应删除该文件。普通用户在「用户管理」创建，不开放注册。两端可同时在线，Token 仅存 sessionStorage，关闭应用或会话失效需重新登录。

## 新环境初始化

仅新库支持初始化；工具对非空目标库拒绝执行。新建实例时由有权限的数据库管理员先执行 `backend/tools/create-multiuser-database.sql`，替换其中的应用账号/来源占位符。若账号本身有建库权限，工具也可直接建库。

设置环境变量 `MONEYDAY_DB_URL`（完整 JDBC URL，库名为 moneyday_multiuser 或 moneyday_test_*）、`MONEYDAY_DB_USERNAME`、`MONEYDAY_DB_PASSWORD`。不要把真实密码写进命令参数或版本库。

```sh
cd backend
mvn -DskipTests compile
# MYSQL_DRIVER_JAR 设置为本机 mysql-connector-j 的 jar 路径
java --class-path "$MYSQL_DRIVER_JAR" tools/InitializeDatabase.java src/main/resources/schema.sql
# 首次启动前通过当前终端环境注入 MONEYDAY_ADMIN_PASSWORD
mvn spring-boot:run
```

数据库编码为 utf8mb4，时区为 Asia/Shanghai。`spring.sql.init.mode=never`；启动不自动运行 DDL。缺少多用户结构标记时后端拒绝启动，不能直接对旧库运行新版。

## 安全与业务规则

- 所有财务表按 user_id 隔离；用户归属从服务端上下文取得，前端不能指定。管理员无跨用户查看权限。
- 停用可重新启用；删除不可恢复且用户名继续占用；两种操作均撤销全部会话。密码修改/重置同样撤销全部会话。重置后必须改密。
- 用户停用/删除后不再执行自动巡检。重新启用不修改既有还款日期；后续巡检按现有到期规则处理。
- 普通用户无管理员接口权限；跨用户记录访问返回404；匿名/失效会话401；首次改密限制与角色拒绝403。响应为 `{code,message,data}`，无密码哈希。
- Token 数据库存 SHA256，密码 BCrypt；关闭 SQL 参数日志。登录有效期返回带时区时间，两端以服务器校验为准。
- 同一用户财务服务在事务中持有用户行锁，手动及自动还款另外锁定负债记录；默认周期及快照唯一性按用户维护。
- CORS 采用精确来源白名单；部署时通过 `MONEYDAY_CORS_ORIGINS`（Spring relaxed binding：`moneyday.cors-origins`）配置实际来源，逗号分隔。

Android 原生地址、Debug/Release 构建步骤及本地 SQLite 兼容边界见 `android-frontend/README.md`。新版不读取、删除或迁移已有 Android SQLite 数据，不支持断网记账。

## 回退

停止新版后端，恢复本次改造前代码，再将本地 datasource URL 切回原数据库。当前聊天旧配置备份在 `/tmp/moneyday-single-user-application-local.yml`，仅本机当前用户可读。不要把该文件复制到版本库。旧代码必须与旧库成对恢复；新库的用户和财务数据不会自动合并回旧库。

## 测试命令

```sh
cd backend
mvn test  # 纯单元测试；真实数据库集成默认跳过
# 用独立 moneyday_test_* 空库初始化并注入以下环境变量后执行集成测试：
# MONEYDAY_TEST_DB_URL / MONEYDAY_TEST_DB_USERNAME / MONEYDAY_TEST_DB_PASSWORD
# MONEYDAY_ADMIN_PASSWORD
mvn test
cd ../frontend
npm run test:auth
npm run build
cd ../android-frontend
npm test
npm run build
```

集成测试不得使用应用数据库。自动测试通过不等于已完成真实浏览器像素、动画、真机/模拟器和生产 HTTPS 验收；本轮实际验证结果会在任务验收记录中补充。

## 本轮验证结果

- Java 17 在独立 MySQL 测试库通过 13 项测试（4 项单元、9 项真实 HTTP/数据库集成），`mvn package` 成功。覆盖认证、强制改密、角色、软删除、会话撤销、全业务隔离及关联 ID、定时任务、并发还款和 CORS 预检。
- Node 22：Web 8 项认证测试、Android 66 次 HTTP 适配/认证断言通过；两个前端均通过类型检查和生产构建，Android Debug 前端构建及 Capacitor 同步通过。Web 原有大包警告保留。
- 专用 Headless Chrome + 独立测试后端：Web 11 个业务路由在 1440/1024/390px、Android 7 个业务路由在 390/1024px 检查通过，无页面级横向溢出及未捕获 JavaScript 异常。通过 Web 首登改密、管理员全部操作，以及 Android 管理员创建/删除和角色限制。
- 实际 UI 双向创建账户并核对金额；Web → Android、Android → Web 均一致。停用用户后两端返回登录页；Android API 断网出现提示，重新连接可恢复。旧请求丢弃、失败写入不重放由前端测试另行覆盖。
- 已初始化用户提供的云端 `moneyday_multiuser`，并验证再次初始化非空库会拒绝。Java 17 打包服务、Web 代理、管理员初登状态及原生/Web CORS 白名单检查通过。
- **尚未完成 APK/设备验收**：Gradle 全局代理拒绝连接，独立缓存下载 Gradle 8.14.3 超时；另需 JDK 21、Android SDK Platform 36。未验证真机/模拟器、生产 HTTPS 或负载性能。

实际预览服务：后端 `8080`、Web `5173`、Android 浏览器调试 `5174`。独立测试数据未写入云端应用库；旧库未执行 DDL/DML，未做数据迁移。修改保持未提交。
