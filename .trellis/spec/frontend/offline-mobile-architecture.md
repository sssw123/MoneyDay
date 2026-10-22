# Android 云端架构（2026-10-20起生效）

本规范替代原离线架构。Vue3/Vant/Capacitor8保留；所有视图通过src/services HTTP适配器访问统一/api，禁止本地财务运算、直接SQL和本地巡检扣款。后端是唯一账本及业务规则来源。

原SQLite和jeep-sqlite代码仅保留兼容历史文件，不得从main.ts/App.vue/运行服务导入或初始化，不删除、不迁移用户本地数据。新版不离线记账或同步。网络失败显示重试，重试只刷新数据，不自动重放写请求。

sessionStorage存Bearer Token；路由在线profile校验，初始/重置密码强制改密，管理员入口按角色显示；旧用户响应必须按generation丢弃。

API与错误契约见后端multiuser-security.md。原生构建必须设置VITE_API_BASE_URL；正式android-release拒绝HTTP，debug可明确启用本机调试HTTP。Hash路由支持Capacitor本地资源路径。

Node22 npm test/npm run build后执行cap sync android、Gradle assembleDebug。Capacitor8需JDK21和SDK36。具体命令与环境边界见android-frontend/README.md。真机验证与纯Web构建分别报告。
