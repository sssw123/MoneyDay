# Flutter 共享实现契约

## 文件归属
- foundation 子代理：`flutter-frontend/lib/data/**`、`lib/app/**`、`lib/main.dart`、`lib/ui/core/**`、`lib/ui/features/auth/**`、pubspec.yaml、analysis_options.yaml。
- finance 子代理：`lib/ui/features/finance/**`，相应 `test/finance_*`。
- planning 子代理：`lib/ui/features/planning/**`、`lib/ui/features/admin/**`，相应 `test/planning_*`。
- 主代理：SDK 安装、生成六端原生工程、构建/CI、文档、共享契约测试、集成与修复。
- 不编辑旧前后端业务代码。不要提交、不要派生更多子代理。生成器、pub get 和全项目格式检查由主代理统一运行。

## 导出与模型
从 `package:moneyday/data/models/models.dart` 导出以下不可变 Freezed JSON DTO。金额用 num，缺省金额为 0，日期为服务端 YYYY-MM-DD 字符串，不做 UTC 日期平移。所需展示字段未列出时以实际后端 JSON 扩展。
- UserProfile: int id, String username/role/status, bool mustChangePassword, String? createdAt。
- LoginResult: String token/expiresAt, UserProfile user。
- UserPage: List<UserProfile> records, int total。
- Account: int id, String name/type, num initialBalance/currentBalance。
- Category: int id, String name, int type/isActive。
- TransactionEntry: int id/type/accountId, num amount, String transactionDate, int? categoryId/toAccountId/liabilityId, String? remark。
- FixedItem: String id/name/type, num amount, int? expectedDay/accountId/liabilityId/transactionId, bool isBooked。
- CycleTemplate: int id/startDay/isDefault, String name, List<FixedItem> fixedItems。
- CycleRecord: int id, String cycleStartDate/cycleEndDate, List<FixedItem> fixedItems, num income/expense/balance。
- CategoryExpense: String name, num value。
- Stats: num totalAssets/totalLiabilities/availableAssets/currentIncome/currentExpense/currentFixedDeposit/currentBalance/currentFinalBalance/cumulativeBalance, bool isOverdraft, List<CategoryExpense> categoryExpenses。
- Goal: int id/isRealized/progress, String name, num targetAmount/availableFunds/gap, String? startDate/deadline/estimatedCompletionDate/estimatedReason, bool isEstimatedFallback。
- Liability: 后端同名完整字段，id/totalPeriods/currentPeriod/repaymentDay/remainingPeriods/progressPercent 为 int；defaultAccountId/categoryId 为 int?；金额 num；name/rateType/status 为 String；startDate/nextRepaymentDate/defaultAccountName/categoryName 为 String?；autoCycleFixedExpense 为 int。
- TodoItem: int id, String type/title/content/bizId/status, String? createdAt。

## Repository
导出 `package:moneyday/data/repositories/moneyday_repository.dart` 的 `MoneydayRepository extends ChangeNotifier`，通过 Provider 读取。每次成功写入 notifyListeners，用于所有存活 ViewModel 刷新。
查询：`accounts()`, `categories()`, `transactions()`, `cycles()`, `templates()`, `stats()`, `goals({required bool wishlist})`, `liabilities()`, `todos({String status = 'PENDING'})`, `pendingCount()`, `users({int page = 1, int pageSize = 20, String keyword = '', String? status})`。分别返回 Future<List<T>>，stats 返回 Stats，pendingCount 返回 int，users 返回 UserPage。
写操作均 Future<void>：`saveAccount/Category/Transaction/Template/Liability(Map<String,Object?> body,{int? id})`；`saveGoal(Map<String,Object?> body,{int? id,required bool wishlist})`；`deleteAccount/Category/Transaction/Template/Liability(int id)`；`deleteGoal(int id,{required bool wishlist})`；`defaultTemplate(int id)`。
`bookItem(int cycleId,String itemId,{required int accountId,required num amount,required String date})`；`unbookItem(int cycleId,String itemId)`；`updateFixedDeposit(int cycleId,num amount)`。
`realizeGoal(int id,int accountId,{required bool wishlist})`；`unrealizeGoal(int id,{required bool wishlist})`。
`repay(int id,{required int accountId,required int periods,required num amount})`；`settle(int id,{required int accountId,required num amount})`。
`dismissTodo/resolveTodo(int id)`；`retryRepay(int id,{int? accountId})`。
`createUser(String username,String password)`；`updateUserStatus(int id,String status)`；`resetUserPassword(int id,String password)`；`deleteUser(int id)`。

## ViewModel 与公共组件
`package:moneyday/ui/core/feature_view_model.dart`：abstract FeatureViewModel extends ChangeNotifier，构造 `(MoneydayRepository repository)`。字段/getters repository, bool loading/saving, String? error。子类实现 `Future<void> fetch()`，由 `Future<void> load()` 统一处理 loading/errors/迟到响应/disposed；`Future<bool> run(Future<void> Function() command)` 处理保存及错误。监听 repository 更新自动 load；页面构造 Provider 后级联 `..load()`；dispose 解除监听。财务写入失败不得自动重试。
`package:moneyday/ui/core/widgets.dart`：
- `AsyncPage({required FeatureViewModel model, required Widget child})`，统一加载、错误与重试。构造时传 Widget，非 builder。
- `PageHeader({required String title,String? subtitle,List<Widget> actions = const []})`。
- `EmptyState({String message = '暂无数据'})`。
- `Future<bool> confirmAction(BuildContext context,String title,String message,{bool destructive = false})`。
- `Future<bool> showFormDialog(BuildContext context,{required String title,required Widget Function(BuildContext,void Function(VoidCallback)) builder,required Future<void> Function() onSubmit,String? description})`，内含 Form 验证、busy/error、取消与保存，成功返回 true。builder 第二参数用于弹窗局部 setState，不在父页面 setState。
- `String money(num? value)`（带 ¥、保留2位）；`String dateOnly(DateTime value)`。
- `String? requiredText(String? value)`；`String? positiveAmount(String? value)`；`num parseAmount(String value)`；`String? passwordError(String value)`（Unicode >=8码点、UTF8 <=72 bytes）。
- 表格/卡片按 LayoutBuilder 600 断点，各 feature 自行实现，以避免过度通用表单。

## 页面导出
finance：`dashboard_page.dart` DashboardPage、`accounts_page.dart` AccountsPage、`categories_page.dart` CategoriesPage、`transactions_page.dart` TransactionsPage、`budget_page.dart` BudgetPage、`settings_page.dart` SettingsPage。均无参 const Widget，由 Provider 读取 repository。
planning：`goals_page.dart` GoalsPage({required bool wishlist})、`liabilities_page.dart` LiabilitiesPage、`todos_page.dart` TodosPage。
admin：`users_page.dart` UsersPage。
路由 `/`, `/transactions`, `/accounts`, `/categories`, `/budget`, `/plan/targets`, `/plan/wishlist`, `/plan/liabilities`, `/todos`, `/settings`, `/admin/users`；别名 `/budgets`、`/wishlist`、`/plan`、`/mine`。桌面完整目的地；移动 5 项首页/记账/计划/待办/设置，预算和账户分类可从设置到达，计划内含子页导航。
