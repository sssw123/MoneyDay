# 后端数据库规范与契约 (Database Guidelines)

> 本文档沉淀了 MoneyDay MVP 开发过程中确立的数据库与持久层规范。

---

## 技术选型与持久层框架
- **关系型数据库**: MySQL 8.0。
- **ORM/持久层**: MyBatis-Plus (替代了原生 MyBatis)。
- **编码与时区**: 数据库及连接统一强制使用 `utf8mb4` 字符集。时区必须强绑定 `Asia/Shanghai`（中国北京时间）。

## 数据模型与实体映射 (MyBatis-Plus)
1. **实体注解 (Entities)**: 
   - 所有的 Entity 类必须显式使用 `@TableName("xxx")` 指定表名，避免由于各种系统或大小写原因导致的表名映射灾难。
   - 自增主键字段必须显式使用 `@TableId(type = IdType.AUTO)`。
2. **Mapper 接口**:
   - 基础 CRUD 统一继承 `BaseMapper<T>`，保持 Mapper 层的极简。
   - 复杂的关联查询或特定聚合计算（如 `StatMapper` 中的数据看板聚合查询）允许保留手写 SQL。
3. **事务管理**:
   - 对多表操作或跨账户金额更新（如 TransactionService）必须在服务实现层 (Impl) 方法上添加 `@Transactional` 注解保证强一致性回滚。

## 关键字段契约
- **金额精度 (Money & Precision)**:
  - 数据库字段严格使用 `DECIMAL(18,2)`。
  - Java 实体类严格使用 `BigDecimal`。
  - **切记**: 绝对禁止使用 `Double` 或 `Float` 计算金额；向前端传递接口时，由 Spring Boot 的 Jackson 自动或配置为将 BigDecimal 序列化为字符串，以避免前端 JS 浮点数截断。
- **账单与周期处理**:
  - 系统不再硬关联账单周期，而是抽象出 `CycleTemplate`（周期模板），由后端按需动态推算起算日及应对月末问题（如 1-31 日期的智能边界截断）。

## 命名规范
- **表名与字段名**: 统一使用 `snake_case`（下划线命名法），禁止使用复数。
- MyBatis-Plus 的 `map-underscore-to-camel-case` 设置已开启，Java 对象属性默认使用 `camelCase`。
