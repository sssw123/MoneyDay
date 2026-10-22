import 'dart:async';
import 'package:fl_chart/fl_chart.dart';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:moneyday/data/models/models.dart';
import 'package:moneyday/data/repositories/moneyday_repository.dart';
import 'package:moneyday/data/services/api_client.dart';
import 'package:moneyday/data/services/auth_controller.dart';
import 'package:moneyday/ui/features/finance/accounts_page.dart';
import 'package:moneyday/ui/features/finance/budget_page.dart';
import 'package:moneyday/ui/features/finance/categories_page.dart';
import 'package:moneyday/ui/features/finance/dashboard_page.dart';
import 'package:moneyday/ui/features/finance/finance_view_models.dart';
import 'package:moneyday/ui/features/finance/finance_widgets.dart';
import 'package:moneyday/ui/features/finance/settings_page.dart';
import 'package:moneyday/ui/features/finance/transactions_page.dart';

class FinanceRepositoryFake extends ChangeNotifier
    implements MoneydayRepository {
  List<Account> accountRecords = [
    const Account(id: 1, name: '现金', type: 'CASH', currentBalance: 1000),
    const Account(id: 2, name: '储蓄卡', type: 'BANK', currentBalance: 2000),
  ];
  List<Category> categoryRecords = [
    const Category(id: 1, name: '餐饮', type: 2),
    const Category(id: 2, name: '工资', type: 1),
  ];
  List<TransactionEntry> transactionRecords = [];
  List<CycleTemplate> templateRecords = [];
  List<CycleRecord> cycleRecords = [];
  List<Liability> liabilityRecords = [];
  List<Goal> goalRecords = [];
  Stats statsRecord = const Stats();
  int generation = 1;
  Completer<List<Account>>? accountResponse;
  Completer<void>? pendingWrite;
  bool failDelete = false;
  int writes = 0;
  Map<String, Object?>? lastBody;
  int? lastId;
  int accountReads = 0;
  @override
  bool get authenticated => true;
  @override
  int get sessionGeneration => generation;
  @override
  Future<List<Account>> accounts() async {
    accountReads++;
    return accountResponse == null
        ? accountRecords
        : await accountResponse!.future;
  }

  @override
  Future<List<Category>> categories() async => categoryRecords;
  @override
  Future<List<TransactionEntry>> transactions() async => transactionRecords;
  @override
  Future<List<CycleRecord>> cycles() async => cycleRecords;
  @override
  Future<List<CycleTemplate>> templates() async => templateRecords;
  @override
  Future<Stats> stats() async => statsRecord;
  @override
  Future<List<Goal>> goals({required bool wishlist}) async => goalRecords;
  @override
  Future<List<Liability>> liabilities() async => liabilityRecords;
  Future<void> record(Map<String, Object?> body, int? id) async {
    writes++;
    lastBody = body;
    lastId = id;
    if (pendingWrite != null) await pendingWrite!.future;
    notifyListeners();
  }

  @override
  Future<void> saveAccount(Map<String, Object?> body, {int? id}) =>
      record(body, id);
  @override
  Future<void> saveCategory(Map<String, Object?> body, {int? id}) =>
      record(body, id);
  @override
  Future<void> saveTransaction(Map<String, Object?> body, {int? id}) =>
      record(body, id);
  @override
  Future<void> saveTemplate(Map<String, Object?> body, {int? id}) =>
      record(body, id);
  @override
  Future<void> deleteTransaction(int id) async {
    writes++;
    if (failDelete) throw const ApiException('结果未知，请刷新核对数据', uncertain: true);
    notifyListeners();
  }

  @override
  Future<void> bookItem(
    int cycleId,
    String itemId, {
    required int accountId,
    required num amount,
    required String date,
  }) => record({
    'cycleId': cycleId,
    'itemId': itemId,
    'accountId': accountId,
    'amount': amount,
    'date': date,
  }, null);
  @override
  Future<void> unbookItem(int cycleId, String itemId) =>
      record({'unbookCycle': cycleId, 'itemId': itemId}, null);
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FinanceAuthFake extends ChangeNotifier implements AuthController {
  @override
  UserProfile? get user =>
      const UserProfile(id: 1, username: '测试用户', role: 'USER');
  @override
  bool get isAdmin => false;
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  test('金额输入拒绝精度丢失、非有限数、零支出与负数，余额调整允许负数', () {
    for (final amount in ['NaN', 'Infinity', '1e3', '0.001', '', '-1', '0']) {
      expect(financeAmountError(amount), isNotNull, reason: amount);
    }
    expect(financeAmountError('1234.56'), isNull);
    expect(financeAmountError('0', allowZero: true), isNull);
    expect(financeAmountError('-12.34', allowNegative: true), isNull);
  });
  test('日期按本地日历校验且不接受溢出日期或时间字符串', () {
    expect(financeDateError('2024-02-29'), isNull);
    expect(financeDateError('2025-02-29'), isNotNull);
    expect(financeDateError('2026-10-22T00:00:00Z'), isNotNull);
    expect(transferAccountError(1, 1), isNotNull);
    expect(transferAccountError(1, 2), isNull);
  });
  test('流水数据一起加载，切换用户后不提交旧用户结果', () async {
    final repository = FinanceRepositoryFake()
      ..accountResponse = Completer<List<Account>>()
      ..transactionRecords = [const TransactionEntry(id: 1, amount: 12)];
    final model = TransactionsViewModel(repository);
    final load = model.load();
    expect(model.transactions, isEmpty);
    repository.generation++;
    repository.accountResponse!.complete(repository.accountRecords);
    await load;
    expect(model.transactions, isEmpty);
    expect(model.accounts, isEmpty);
    expect(model.error, isNull);
    model.dispose();
    repository.dispose();
  });
  test('财务写入失败不会重放，并保留可核对的错误提示', () async {
    final repository = FinanceRepositoryFake()..failDelete = true;
    final model = TransactionsViewModel(repository);
    expect(await model.remove(const TransactionEntry(id: 4)), isFalse);
    expect(repository.writes, 1);
    expect(model.error, contains('刷新核对'));
    await model.load();
    expect(repository.writes, 1);
    model.dispose();
    repository.dispose();
  });
  test('分类停用保持原名称和类型，流水筛选不改变服务端账本', () async {
    final repository = FinanceRepositoryFake();
    final categories = CategoriesViewModel(repository);
    await categories.toggle(repository.categoryRecords.first, false);
    expect(repository.lastBody, {'name': '餐饮', 'type': 2, 'isActive': 0});
    final transactions = TransactionsViewModel(repository);
    repository.transactionRecords = [
      const TransactionEntry(id: 1, type: 2, accountId: 1, remark: '午餐'),
      const TransactionEntry(id: 2, type: 1, accountId: 2),
    ];
    await transactions.load();
    transactions.filter(2);
    transactions.searchFor('午餐');
    expect(transactions.filtered.single.id, 1);
    expect(repository.writes, 1);
    categories.dispose();
    transactions.dispose();
    repository.dispose();
  });

  Future<void> pumpPage(
    WidgetTester tester,
    FinanceRepositoryFake repository,
    Widget page, {
    Size size = const Size(1280, 900),
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<MoneydayRepository>.value(value: repository),
          ChangeNotifierProvider<AuthController>.value(
            value: FinanceAuthFake(),
          ),
        ],
        child: MaterialApp(home: Scaffold(body: page)),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('新增账户区分期初余额，编辑时提交当前余额', (tester) async {
    final repository = FinanceRepositoryFake();
    await pumpPage(tester, repository, const AccountsPage());
    await tester.tap(find.text('新增账户'));
    await tester.pumpAndSettle();
    await tester.enterText(find.widgetWithText(TextFormField, '账户名称'), '零用钱');
    await tester.enterText(find.widgetWithText(TextFormField, '期初余额'), '20.50');
    await tester.tap(find.widgetWithText(FilledButton, '保存'));
    await tester.pumpAndSettle();
    expect(repository.lastBody?['initialBalance'], 20.5);
    expect(repository.lastBody?.containsKey('currentBalance'), isFalse);
    await tester.tap(find.text('编辑').first);
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextFormField, '当前余额'),
      '-10.25',
    );
    await tester.tap(find.widgetWithText(FilledButton, '保存'));
    await tester.pumpAndSettle();
    expect(repository.lastBody?['currentBalance'], -10.25);
    expect(repository.lastBody?.containsKey('initialBalance'), isFalse);
    expect(tester.takeException(), isNull);
  });
  testWidgets('转账只允许另一个账户，保存清空分类且仅提交一次', (tester) async {
    final repository = FinanceRepositoryFake();
    await pumpPage(tester, repository, const TransactionsPage());
    await tester.tap(find.text('记一笔'));
    await tester.pumpAndSettle();
    await tester.tap(
      find.descendant(
        of: find.byType(SegmentedButton<int>),
        matching: find.text('转账'),
      ),
    );
    await tester.pumpAndSettle();
    await tester.enterText(find.widgetWithText(TextFormField, '金额'), '123.45');
    final toField = find.byWidgetPredicate(
      (widget) => widget is FinanceAccountField && widget.label == '转入账户',
    );
    await tester.tap(toField);
    await tester.pumpAndSettle();
    await tester.tap(find.textContaining('储蓄卡').last);
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, '保存'));
    await tester.pumpAndSettle();
    expect(repository.writes, 1);
    expect(repository.lastBody?['type'], 3);
    expect(repository.lastBody?['accountId'], 1);
    expect(repository.lastBody?['toAccountId'], 2);
    expect(repository.lastBody?['categoryId'], isNull);
    expect(repository.lastBody?['amount'], 123.45);
    expect(tester.takeException(), isNull);
  });
  testWidgets('固定项目保存期间防重，固存不开放支付', (tester) async {
    final repository = FinanceRepositoryFake()
      ..pendingWrite = Completer<void>()
      ..cycleRecords = [
        const CycleRecord(
          id: 1,
          cycleStartDate: '2026-10-01',
          cycleEndDate: '2026-10-31',
          fixedItems: [
            FixedItem(id: 'salary', name: '工资', type: 'INCOME', amount: 100),
            FixedItem(id: 'saving', name: '应急金', type: 'DEPOSIT', amount: 10),
          ],
        ),
      ];
    await pumpPage(
      tester,
      repository,
      const BudgetPage(),
      size: const Size(390, 844),
    );
    final deposit = tester.widget<ActionChip>(
      find.widgetWithText(ActionChip, '固存 · 应急金\n¥10.00 · 计划必攒'),
    );
    expect(deposit.onPressed, isNull);
    await tester.tap(find.textContaining('固收 · 工资'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, '保存'));
    await tester.pump();
    expect(repository.writes, 1);
    expect(
      tester
          .widget<FilledButton>(find.widgetWithText(FilledButton, '保存'))
          .onPressed,
      isNull,
    );
    repository.pendingWrite!.complete();
    await tester.pumpAndSettle();
    expect(repository.lastBody?['itemId'], 'salary');
    expect(repository.lastBody?['date'], matches(RegExp(r'^2026-10-\d{2}$')));
    expect(tester.takeException(), isNull);
  });
  testWidgets('编辑模板保留固定项目标识、分类及默认状态', (tester) async {
    final repository = FinanceRepositoryFake()
      ..templateRecords = [
        const CycleTemplate(
          id: 5,
          name: '发薪日',
          startDay: 31,
          isDefault: 1,
          fixedItems: [
            FixedItem(
              id: 'rent-uuid',
              name: '房租',
              type: 'EXPENSE',
              categoryId: 1,
              categoryName: '餐饮',
              amount: 800,
            ),
          ],
        ),
      ];
    await pumpPage(tester, repository, const SettingsPage());
    await tester.ensureVisible(find.text('编辑'));
    await tester.tap(find.text('编辑'));
    await tester.pumpAndSettle();
    await tester.enterText(find.widgetWithText(TextFormField, '项目名称'), '新房租');
    await tester.tap(find.widgetWithText(FilledButton, '保存'));
    await tester.pumpAndSettle();
    expect(repository.lastId, 5);
    expect(repository.lastBody?['startDay'], 31);
    expect(repository.lastBody?['isDefault'], 1);
    final fixed = (repository.lastBody?['fixedItems'] as List).single as Map;
    expect(fixed['id'], 'rent-uuid');
    expect(fixed['name'], '新房租');
    expect(fixed['categoryId'], 1);
    expect(tester.takeException(), isNull);
  });
  testWidgets('看板隐藏所有金额及估算提示，历史快照仍展示固存和最终结余', (tester) async {
    final repository = FinanceRepositoryFake()
      ..statsRecord = const Stats(
        availableAssets: 12345.67,
        categoryExpenses: [CategoryExpense(name: '交通', value: 99.12)],
      )
      ..goalRecords = [
        const Goal(
          id: 1,
          name: '测试目标',
          targetAmount: 777.77,
          estimatedReason: '计划金额 ¥777.77',
        ),
      ]
      ..cycleRecords = [
        const CycleRecord(
          id: 1,
          cycleStartDate: '2026-09-01',
          cycleEndDate: '2026-09-30',
          income: 200.01,
          expense: 50.02,
          balance: 39.99,
          fixedItems: [
            FixedItem(id: 'saving', name: '储蓄', type: 'DEPOSIT', amount: 10),
          ],
        ),
      ]
      ..liabilityRecords = [
        const Liability(
          id: 1,
          name: '设备分期',
          periodAmount: 88.88,
          totalPeriods: 12,
          currentPeriod: 2,
          progressPercent: 17,
          nextRepaymentDate: '2026-11-10',
        ),
      ];
    await pumpPage(tester, repository, const DashboardPage());
    expect(find.text('固存'), findsOneWidget);
    expect(find.text('最终结余'), findsOneWidget);
    expect(find.text('¥10.00'), findsOneWidget);
    expect(find.text('¥49.99'), findsOneWidget);
    expect(find.text('¥99.12'), findsOneWidget);
    expect(find.text('¥88.88 / 期'), findsOneWidget);
    expect(find.byType(PieChart), findsOneWidget);
    await tester.tap(find.byTooltip('隐藏金额'));
    await tester.pumpAndSettle();
    expect(find.textContaining('¥'), findsNothing);
    expect(find.text('••••'), findsWidgets);
    final tooltips = tester.widgetList<Tooltip>(find.byType(Tooltip));
    expect(
      tooltips.any((tooltip) => tooltip.message?.contains('¥') ?? false),
      isFalse,
    );
    expect(find.text('交通'), findsOneWidget);
    await tester.tap(find.byTooltip('显示金额'));
    await tester.pumpAndSettle();
    expect(find.text('¥12,345.67'), findsOneWidget);
    expect(repository.writes, 0);
    expect(tester.takeException(), isNull);
  });
  testWidgets('首页只速览前三笔待还分期，并能进入完整负债页', (tester) async {
    final repository = FinanceRepositoryFake()
      ..liabilityRecords = [
        const Liability(id: 9, name: '已结清分期', status: 'SETTLED'),
        for (var index = 1; index <= 4; index++)
          Liability(
            id: index,
            name: '分期$index',
            periodAmount: 100,
            totalPeriods: 12,
            currentPeriod: index,
            progressPercent: index * 8,
            nextRepaymentDate: '2026-11-10',
          ),
      ];
    final router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          builder: (_, _) => const Scaffold(body: DashboardPage()),
        ),
        GoRoute(
          path: '/plan/liabilities',
          builder: (_, _) => const Scaffold(body: Text('完整负债页')),
        ),
      ],
    );
    addTearDown(router.dispose);
    await tester.binding.setSurfaceSize(const Size(1280, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      ChangeNotifierProvider<MoneydayRepository>.value(
        value: repository,
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('待还分期 · 4 笔'), findsOneWidget);
    expect(find.text('分期1'), findsOneWidget);
    expect(find.text('分期3'), findsOneWidget);
    expect(find.text('分期4'), findsNothing);
    expect(find.text('已结清分期'), findsNothing);
    expect(find.text('已还 2/12 期'), findsOneWidget);
    expect(find.text('下期 2026-11-10'), findsNWidgets(3));
    await tester.ensureVisible(find.text('查看全部分期'));
    await tester.tap(find.text('查看全部分期'));
    await tester.pumpAndSettle();
    expect(find.text('完整负债页'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
  for (final width in [390.0, 768.0, 1440.0]) {
    testWidgets('核心页面在 $width 宽度无溢出，看板无伪支出图', (tester) async {
      final repository = FinanceRepositoryFake()
        ..transactionRecords = [
          const TransactionEntry(
            id: 1,
            type: 2,
            accountId: 1,
            amount: 12,
            transactionDate: '2026-10-22',
            remark: '午餐',
          ),
        ];
      for (final page in [
        const DashboardPage(),
        const AccountsPage(),
        const CategoriesPage(),
        const TransactionsPage(),
        const BudgetPage(),
        const SettingsPage(),
      ]) {
        await pumpPage(tester, repository, page, size: Size(width, 900));
        expect(
          tester.takeException(),
          isNull,
          reason: page.runtimeType.toString(),
        );
        if (page is DashboardPage) {
          expect(find.byType(PieChart), findsNothing);
          expect(find.text('本周期还没有分类支出，记下第一笔后再来看看。'), findsOneWidget);
        }
      }
    });
  }
}
