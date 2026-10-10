# 后端目录结构与分层架构 (Directory Structure)

> 沉淀 MoneyDay 后端 Java 项目的架构层级与分包规范。

---

## 核心包结构

```
com.moneyday.backend
├── common/         # 全局通用配置（全局异常处理、统一 Result 包装器等）
├── controller/     # RESTful API 控制器层（路由分发、参数校验）
├── entity/         # 数据库映射实体类（@TableName, @TableId）
├── mapper/         # 数据持久层接口（extends BaseMapper<T>）
└── service/        # 业务逻辑层接口 (Interfaces)
    └── impl/       # 业务逻辑具体实现类 (@Service)
```

## 架构契约与约定

### 1. 经典接口与实现分离模式 (Service + Impl)
- 为了保持代码扩展性和 Spring 标准规范，业务逻辑层**必须拆分**为接口和实现。
- `service/` 目录下存放定义业务能力的公共接口（例如 `UserService.java`）。
- `service/impl/` 目录下存放具体的实现类（例如 `UserServiceImpl.java`），并在此类上标注 `@Service`。
- **依赖注入**: Controller 层必须面向接口编程，通过 `@Autowired private UserService userService;` 注入，不得直接注入 Impl 实现类。

### 2. 统一 API 响应格式 (Result Wrapper)
- Controller 层的返回值不得直接返回实体或基础类型。
- 必须统一通过 `com.moneyday.backend.common.Result<T>` 进行包装，返回标准的 `{ "code": xxx, "msg": "xxx", "data": ... }` 格式。

### 3. 全局异常处理 (Global Exception Handler)
- 严禁在业务代码中到处写 `try-catch` 捕捉业务异常。
- 业务发生错误时，直接 `throw new RuntimeException()` 或自定义业务异常。
- 由 `GlobalExceptionHandler` 统一进行拦截并转换为标准的错误 `Result` 抛给前端。
