import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:moneyday/data/models/models.dart';
import 'package:moneyday/data/repositories/moneyday_repository.dart';
import 'package:moneyday/data/services/api_client.dart'
    show StaleSessionException;
import 'package:moneyday/ui/core/widgets.dart';
import 'package:moneyday/ui/features/planning/goals_page.dart';
import 'package:moneyday/ui/features/planning/liabilities_page.dart';
import 'package:moneyday/ui/features/planning/todos_page.dart';
import 'package:moneyday/ui/features/admin/users_page.dart';

class PlanningRepositoryFake extends ChangeNotifier
    implements MoneydayRepository {
  List<Goal> goalRecords = [
    const Goal(id: 1, name: '旅行', targetAmount: 1000, progress: 20),
  ];
  List<Account> accountRecords = [
    const Account(id: 1, name: '银行卡', currentBalance: 2000),
  ];
  Stats statsRecord = const Stats(availableAssets: 200, cumulativeBalance: 200);
  List<TodoItem> todoRecords = [];
  List<UserProfile> userRecords = [];
  List<Liability> liabilityRecords = [];
  int realizationCount = 0;
  int generation = 1;
  int repayCount = 0;
  int? repaidPeriods;
  num? repaidAmount;
  num? settledAmount;
  String? queriedStatus;
  int? queriedPage;
  @override
  bool get authenticated => true;
  @override
  int get sessionGeneration => generation;
  @override
  Future<List<Goal>> goals({required bool wishlist}) async => goalRecords;
  @override
  Future<List<Account>> accounts() async => accountRecords;
  @override
  Future<Stats> stats() async => statsRecord;
  @override
  Future<List<Category>> categories() async => [];
  @override
  Future<List<Liability>> liabilities() async => liabilityRecords;
  @override
  Future<List<TodoItem>> todos({String status = 'PENDING'}) async {
    queriedStatus = status;
    return todoRecords;
  }

  @override
  Future<int> pendingCount() async => 3;
  @override
  Future<UserPage> users({
    int page = 1,
    int pageSize = 20,
    String keyword = '',
    String? status,
  }) async {
    queriedPage = page;
    return UserPage(records: userRecords, total: 45);
  }

  @override
  Future<void> realizeGoal(
    int id,
    int accountId, {
    required bool wishlist,
  }) async {
    realizationCount++;
    notifyListeners();
  }

  @override
  Future<void> repay(
    int id, {
    required int accountId,
    required int periods,
    required num amount,
  }) async {
    repayCount++;
    repaidPeriods = periods;
    repaidAmount = amount;
    notifyListeners();
  }

  @override
  Future<void> settle(
    int id, {
    required int accountId,
    required num amount,
  }) async {
    settledAmount = amount;
    notifyListeners();
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class DelayedPlanningRepository extends PlanningRepositoryFake {
  final goalResponse = Completer<List<Goal>>();
  final liabilityResponse = Completer<List<Liability>>();
  @override
  Future<List<Goal>> goals({required bool wishlist}) => goalResponse.future;
  @override
  Future<List<Liability>> liabilities() => liabilityResponse.future;
}

void main() {
  test('旧会话目标与负债组合查询不会写入 ViewModel', () async {
    final repository = DelayedPlanningRepository();
    final goals = GoalsViewModel(repository, wishlist: false);
    final liabilities = LiabilitiesViewModel(repository);
    final goalCheck = expectLater(
      goals.fetch(),
      throwsA(isA<StaleSessionException>()),
    );
    final liabilityCheck = expectLater(
      liabilities.fetch(),
      throwsA(isA<StaleSessionException>()),
    );
    repository.generation++;
    repository.goalResponse.complete([const Goal(id: 5, name: '旧用户目标')]);
    repository.liabilityResponse.complete([
      const Liability(id: 7, name: '旧用户负债'),
    ]);
    await Future.wait([goalCheck, liabilityCheck]);
    expect(goals.goals, isEmpty);
    expect(goals.accounts, isEmpty);
    expect(goals.availableAssets, 0);
    expect(liabilities.liabilities, isEmpty);
    expect(liabilities.accounts, isEmpty);
    goals.dispose();
    liabilities.dispose();
    repository.dispose();
  });
  test('分期试算覆盖免息、手续费和等额本息，不生成账本', () {
    expect(installmentPreview(1200, 12, 'NONE', 0), 100);
    expect(installmentPreview(1200, 12, 'FEE', 0.5), 106);
    expect(installmentPreview(1200, 12, 'APR', 12), 106.62);
    expect(installmentPreview(1200, 12, 'APR', 0), 100);
    expect(installmentPreview(1200, 0, 'NONE', 0), 0);
  });
  test('还款日期兼容月底、闰年和跨年', () {
    expect(
      defaultRepaymentDate(DateTime(2024, 2, 1), 31),
      DateTime(2024, 2, 29),
    );
    expect(
      defaultRepaymentDate(DateTime(2025, 2, 1), 31),
      DateTime(2025, 2, 28),
    );
    expect(
      defaultRepaymentDate(DateTime(2025, 12, 10), 10),
      DateTime(2026, 1, 10),
    );
  });
  test('目标净资产和账户余额为硬限制，心愿只放宽结余限制', () {
    expect(
      goalRealizationBlock(
        wishlist: false,
        availableAssets: 10,
        targetAmount: 100,
        accountBalance: 200,
      ),
      isNotNull,
    );
    expect(
      goalRealizationBlock(
        wishlist: true,
        availableAssets: 10,
        targetAmount: 100,
        accountBalance: 200,
      ),
      isNull,
    );
    expect(
      goalRealizationBlock(
        wishlist: true,
        availableAssets: 200,
        targetAmount: 100,
        accountBalance: 20,
      ),
      isNotNull,
    );
  });
  test('用户名和 Unicode 密码与服务端约束保持一致', () {
    expect(usernameError('ab'), isNotNull);
    expect(usernameError('User_123'), isNull);
    expect(usernameError('中文用户名'), isNotNull);
    expect(passwordError('😀😀😀😀😀😀😀😀'), isNull);
    expect(passwordError('😀😀😀😀😀😀😀'), isNotNull);
    expect(passwordError(List.filled(19, '😀').join()), isNotNull);
  });
  test('待办筛选和管理员分页交给查询接口，待办保留服务端计数', () async {
    final repository = PlanningRepositoryFake();
    final todos = TodosViewModel(repository);
    final users = UsersViewModel(repository);
    await todos.filter('DISMISSED');
    expect(repository.queriedStatus, 'DISMISSED');
    expect(todos.pendingCount, 3);
    await users.changePage(2);
    expect(repository.queriedPage, 2);
    expect(users.total, 45);
    todos.dispose();
    users.dispose();
    repository.dispose();
  });

  Future<void> pumpGoals(
    WidgetTester tester,
    PlanningRepositoryFake repository,
    bool wishlist,
    Size size,
  ) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      ChangeNotifierProvider<MoneydayRepository>.value(
        value: repository,
        child: MaterialApp(
          home: Scaffold(body: GoalsPage(wishlist: wishlist)),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('手机目标卡片禁止净资产不足的兑现且无布局溢出', (tester) async {
    final repository = PlanningRepositoryFake();
    await pumpGoals(tester, repository, false, const Size(390, 844));
    expect(find.text('旅行'), findsOneWidget);
    expect(
      tester
          .widget<TextButton>(find.widgetWithText(TextButton, '实现目标'))
          .onPressed,
      isNull,
    );
    expect(tester.takeException(), isNull);
  });
  testWidgets('桌面采用可横向滚动表格', (tester) async {
    final repository = PlanningRepositoryFake();
    await pumpGoals(tester, repository, false, const Size(1280, 900));
    expect(find.byType(DataTable), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
  testWidgets('超支心愿必须二次确认，取消不写入', (tester) async {
    final repository = PlanningRepositoryFake();
    await pumpGoals(tester, repository, true, const Size(390, 844));
    await tester.tap(find.widgetWithText(TextButton, '兑现'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, '保存'));
    // The underlying form deliberately remains busy while the confirmation is
    // open, so its indeterminate progress indicator never settles.
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('确认超支兑现'), findsOneWidget);
    expect(repository.realizationCount, 0);
    await tester.tap(find.widgetWithText(TextButton, '取消').last);
    await tester.pumpAndSettle();
    expect(repository.realizationCount, 0);
    await tester.tap(find.widgetWithText(FilledButton, '保存'));
    await tester.pump(const Duration(milliseconds: 500));
    await tester.tap(find.widgetWithText(FilledButton, '确认'));
    await tester.pumpAndSettle();
    expect(repository.realizationCount, 1);
  });
  testWidgets('多期提前还款允许金额校准，只提交一次', (tester) async {
    final repository = PlanningRepositoryFake()
      ..liabilityRecords = [
        const Liability(
          id: 1,
          name: '手机分期',
          principal: 1200,
          totalPeriods: 12,
          currentPeriod: 3,
          remainingPeriods: 9,
          remainingAmount: 900,
          periodAmount: 100,
          defaultAccountId: 1,
        ),
      ];
    await tester.pumpWidget(
      ChangeNotifierProvider<MoneydayRepository>.value(
        value: repository,
        child: const MaterialApp(home: Scaffold(body: LiabilitiesPage())),
      ),
    );
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.widgetWithText(TextButton, '还款'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(TextButton, '还款'));
    await tester.pumpAndSettle();
    await tester.enterText(find.widgetWithText(TextFormField, '本次归还期数'), '3');
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextFormField, '还款金额（可校准）'),
      '299.99',
    );
    await tester.tap(find.widgetWithText(FilledButton, '保存'));
    await tester.pumpAndSettle();
    expect(repository.repaidPeriods, 3);
    expect(repository.repaidAmount, 299.99);
    expect(repository.repayCount, 1);
    expect(tester.takeException(), isNull);
  });
  testWidgets('提前结清可以调整减免后的金额', (tester) async {
    final repository = PlanningRepositoryFake()
      ..liabilityRecords = [
        const Liability(
          id: 1,
          name: '手机分期',
          totalPeriods: 12,
          currentPeriod: 3,
          remainingPeriods: 9,
          remainingAmount: 900,
          periodAmount: 100,
          defaultAccountId: 1,
        ),
      ];
    await tester.pumpWidget(
      ChangeNotifierProvider<MoneydayRepository>.value(
        value: repository,
        child: const MaterialApp(home: Scaffold(body: LiabilitiesPage())),
      ),
    );
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.widgetWithText(TextButton, '还款'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(TextButton, '还款'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('提前结清'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextFormField, '结清金额（可调整手续费）'),
      '850',
    );
    await tester.tap(find.widgetWithText(FilledButton, '保存'));
    await tester.pumpAndSettle();
    expect(repository.settledAmount, 850);
    expect(repository.repayCount, 0);
    expect(tester.takeException(), isNull);
  });
}
