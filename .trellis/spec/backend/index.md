# 后端开发主干规范 (Backend Specs)

> MoneyDay MVP 后端全局技术栈与准则概览。
> 详情请查阅侧边栏的具体细分规范文档。

---

## 核心技术栈
- **语言**: Java 17
- **框架**: Spring Boot 3.x
- **依赖管理**: Maven
- **持久层**: MyBatis-Plus + MySQL 8.0
- **配置文件**: `application.yml` (不再使用 properties)

## 核心契约与开发纪律
1. **统一路由前缀**: 所有提供给前端的接口，必须以 `/api` 开头。
2. **极简主义原则**:
   - 如果 MyBatis-Plus 的 `BaseMapper` 能满足需求，坚决不要手写 SQL。
   - 不引入无意义的过度设计和无用的依赖包，坚守项目轻量化。
3. **全局时区约束**: 
   - 所有的 `application.yml` 配置、Jackson 序列化配置以及数据库连接参数中，时间统一锚定 `Asia/Shanghai` 时区，无视客户端本地时区环境。
4. **全局统一响应 (Result)**:
   - 全局遵守 `{ code, msg, data }` 的返回体结构，配合 `GlobalExceptionHandler` 处理异常。
5. **依赖注入**: 业务层采用 `Service` 接口与 `Impl` 实现类分离的结构，通过面向接口的方式进行 `@Autowired`。
