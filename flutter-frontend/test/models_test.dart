import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:moneyday/data/models/models.dart';
import 'package:moneyday/data/services/api_client.dart';
import 'package:moneyday/ui/core/widgets.dart';

void main() {
  group('账本 JSON 模型', () {
    test('金额接受整数和小数，空金额默认零；账户类型保留服务端值', () {
      final account = Account.fromJson({
        'id': 4,
        'name': '银行卡',
        'type': 'BANK',
        'initialBalance': 100,
        'currentBalance': 80.25,
      });
      expect(account.initialBalance, 100);
      expect(account.currentBalance, 80.25);
      expect(account.type, 'BANK');
      expect(Account.fromJson({'currentBalance': null}).currentBalance, 0);
      final transaction = TransactionEntry.fromJson({
        'id': 5,
        'type': 3,
        'accountId': 4,
        'toAccountId': 9,
        'amount': 12.35,
        'transactionDate': '2026-10-22',
        'categoryId': null,
        'remark': null,
        'liabilityId': null,
      });
      expect(transaction.toAccountId, 9);
      expect(transaction.categoryId, isNull);
      expect(transaction.remark, isNull);
      expect(transaction.liabilityId, isNull);
      expect(transaction.amount, 12.35);
      expect(transaction.transactionDate, '2026-10-22');
      expect(TransactionEntry.fromJson(transaction.toJson()), transaction);
    });
    test('历史周期允许空固定项目和可空到账标记，固定项目 ID 始终为字符串', () {
      final empty = CycleRecord.fromJson({
        'id': 1,
        'cycleStartDate': '2026-09-22',
        'cycleEndDate': '2026-10-21',
        'fixedItems': null,
        'income': null,
        'expense': null,
        'balance': null,
      });
      expect(empty.fixedItems, isEmpty);
      expect([empty.income, empty.expense, empty.balance], [0, 0, 0]);
      final item = FixedItem.fromJson({
        'id': 'income-legacy-42',
        'name': '工资',
        'type': 'INCOME',
        'amount': 5000.55,
        'isBooked': null,
        'transactionId': null,
        'categoryId': 2,
        'categoryName': '工资收入',
      });
      expect(item.id, 'income-legacy-42');
      expect(item.isBooked, isFalse);
      expect(item.transactionId, isNull);
      expect(item.categoryId, 2);
      expect(item.categoryName, '工资收入');
      expect(item.amount, 5000.55);
      expect(FixedItem.fromJson({}).amount, 0);
    });
    test('周期及模板嵌套 JSON 可以直接 round-trip', () {
      const item = FixedItem(
        id: 'fixed-a',
        name: '房租',
        type: 'EXPENSE',
        amount: 1500,
        categoryId: 3,
      );
      const cycle = CycleRecord(
        id: 4,
        cycleStartDate: '2026-10-22',
        cycleEndDate: '2026-11-21',
        fixedItems: [item],
        income: 6000,
        expense: 2000.5,
        balance: 3999.5,
      );
      const template = CycleTemplate(
        id: 2,
        name: '发薪周期',
        startDay: 22,
        isDefault: 1,
        fixedItems: [item],
      );
      expect(
        (cycle.toJson()['fixedItems'] as List).single,
        isA<Map<String, dynamic>>(),
      );
      expect(
        (template.toJson()['fixedItems'] as List).single,
        isA<Map<String, dynamic>>(),
      );
      expect(CycleRecord.fromJson(cycle.toJson()), cycle);
      expect(CycleTemplate.fromJson(template.toJson()), template);
      expect(
        CycleRecord.fromJson(
          jsonDecode(jsonEncode(cycle)) as Map<String, dynamic>,
        ),
        cycle,
      );
    });
    test('登录和管理员分页嵌套模型 round-trip，强制改密不丢失', () {
      const user = UserProfile(
        id: 1,
        username: '管理员',
        role: 'ADMIN',
        status: 'ACTIVE',
        mustChangePassword: true,
        createdAt: '2026-10-22T08:00:00',
      );
      const login = LoginResult(
        token: 'opaque-token',
        expiresAt: '2026-10-29T00:00:00Z',
        user: user,
      );
      const page = UserPage(records: [user], total: 1);
      expect(login.toJson()['user'], isA<Map<String, dynamic>>());
      expect(LoginResult.fromJson(login.toJson()), login);
      expect(UserPage.fromJson(page.toJson()), page);
      expect(
        LoginResult.fromJson(login.toJson()).user.mustChangePassword,
        isTrue,
      );
    });
    test('看板只解析服务端金额、超支标记及分类汇总', () {
      final stats = Stats.fromJson({
        'totalAssets': 1000.25,
        'totalLiabilities': 100,
        'availableAssets': 600,
        'totalTargets': 400,
        'targetAllocated': 400,
        'currentIncome': 1000,
        'currentExpense': 1050.5,
        'currentFixedDeposit': 50,
        'currentBalance': -100.5,
        'currentFinalBalance': -100.5,
        'cumulativeBalance': -200,
        'isOverdraft': true,
        'categoryExpenses': [
          {'name': '餐饮', 'value': 102.5},
        ],
      });
      expect(stats.isOverdraft, isTrue);
      expect(stats.currentFinalBalance, -100.5);
      expect(stats.categoryExpenses.single.name, '餐饮');
      expect(stats.categoryExpenses.single.value, 102.5);
      expect(Stats.fromJson(stats.toJson()), stats);
      expect(Stats.fromJson({}).categoryExpenses, isEmpty);
      expect(Stats.fromJson({}).totalAssets, 0);
    });
    test('目标及负债保留服务端估算、期数与全部金额字段', () {
      final goal = Goal.fromJson({
        'id': 4,
        'name': '旅行',
        'targetAmount': 3000,
        'isRealized': 0,
        'progress': 15,
        'availableFunds': 450,
        'gap': 2550,
        'startDate': '2026-10-22',
        'deadline': null,
        'estimatedCompletionDate': '无法预估',
        'estimatedReason': '当前结余为负',
        'isEstimatedFallback': true,
      });
      expect(goal.deadline, isNull);
      expect(goal.estimatedReason, '当前结余为负');
      expect(Goal.fromJson(goal.toJson()), goal);
      final liability = Liability.fromJson({
        'id': 8,
        'name': '设备分期',
        'principal': 6000,
        'totalAmount': 6300.25,
        'totalPeriods': 12,
        'currentPeriod': 2,
        'periodAmount': 525.02,
        'rateType': 'FEE',
        'interestRate': 5,
        'repaymentDay': 22,
        'nextRepaymentDate': '2026-11-22',
        'defaultAccountId': null,
        'categoryId': null,
        'autoCycleFixedExpense': 1,
        'status': 'REPAYING',
        'startDate': '2026-09-22',
        'remainingPeriods': 10,
        'remainingAmount': 5250.21,
        'progressPercent': 16,
        'defaultAccountName': null,
        'categoryName': null,
        'settledAt': null,
        'createdAt': '2026-09-22T08:00:00',
        'updatedAt': null,
      });
      expect(liability.remainingAmount, 5250.21);
      expect(liability.remainingPeriods, 10);
      expect(liability.autoCycleFixedExpense, 1);
      expect(liability.defaultAccountId, isNull);
      expect(Liability.fromJson(liability.toJson()), liability);
      expect(Liability.fromJson({}).principal, 0);
    });
    test('分类状态和待办业务字符串 ID 可序列化', () {
      final category = Category.fromJson({
        'id': 2,
        'name': '旧分类',
        'type': 2,
        'isActive': 0,
      });
      final todo = TodoItem.fromJson({
        'id': 3,
        'type': 'CYCLE_FIXED_ITEMS',
        'title': '周期到账',
        'content': '有待处理项目',
        'bizId': 'cycle-7:item-42',
        'status': 'PENDING',
        'createdAt': null,
      });
      expect(category.isActive, 0);
      expect(Category.fromJson(category.toJson()), category);
      expect(todo.bizId, 'cycle-7:item-42');
      expect(TodoItem.fromJson(todo.toJson()), todo);
    });
    test('Freezed 集合不可直接修改', () {
      const stats = Stats(
        categoryExpenses: [CategoryExpense(name: '餐饮', value: 12)],
      );
      expect(
        () => stats.categoryExpenses.add(const CategoryExpense()),
        throwsUnsupportedError,
      );
    });
  });

  group('输入与显示规则', () {
    test('金额必须有限且大于零，显示保留两位并带人民币符号', () {
      for (final value in ['', 'text', '0', '-1', 'NaN', 'Infinity']) {
        expect(positiveAmount(value), isNotNull);
      }
      expect(positiveAmount(' 12.25 '), isNull);
      expect(parseAmount(' 12.25 '), 12.25);
      expect(money(12.2), contains('12.20'));
      expect(money(12.2), startsWith('¥'));
      expect(money(null), contains('0.00'));
      expect(requiredText('   '), isNotNull);
      expect(requiredText('有效'), isNull);
    });
    test('密码按 Unicode 码点和 UTF-8 字节数验证', () {
      expect(passwordError('1234567'), isNotNull);
      expect(passwordError('12345678'), isNull);
      expect(passwordError(List.filled(7, '😀').join()), isNotNull);
      expect(passwordError(List.filled(8, '😀').join()), isNull);
      expect(passwordError(List.filled(72, 'a').join()), isNull);
      expect(passwordError(List.filled(73, 'a').join()), isNotNull);
      expect(passwordError(List.filled(24, '中').join()), isNull);
      expect(passwordError(List.filled(25, '中').join()), isNotNull);
    });
    test('服务端日期字符串原样保存，日期格式化不做 UTC 平移', () {
      expect(
        TransactionEntry.fromJson({
          'transactionDate': '2026-10-22',
        }).transactionDate,
        '2026-10-22',
      );
      expect(dateOnly(DateTime(2026, 1, 2, 23, 59)), '2026-01-02');
      expect(dateOnly(DateTime.utc(2026, 10, 22)), '2026-10-22');
    });
  });

  group('API 地址发布约束', () {
    test('Web 同源默认与显式 /api 均可使用', () {
      expect(ApiClient.resolveBaseUrl('', web: true, release: true), '/api');
      expect(
        ApiClient.resolveBaseUrl('/api', web: true, release: true),
        '/api',
      );
    });
    test('原生要求完整地址，统一 /api，调试可显式 HTTP', () {
      expect(
        ApiClient.resolveBaseUrl('https://ledger.example', web: false),
        'https://ledger.example/api',
      );
      expect(
        ApiClient.resolveBaseUrl('https://ledger.example/api///', web: false),
        'https://ledger.example/api',
      );
      expect(
        ApiClient.resolveBaseUrl(
          'http://localhost:8080/api',
          web: false,
          release: false,
        ),
        'http://localhost:8080/api',
      );
      for (final value in [
        '',
        '/api',
        'localhost:8080',
        'ftp://ledger.example',
        'https:///api',
      ]) {
        expect(
          () => ApiClient.resolveBaseUrl(value, web: false),
          throwsA(isA<ApiException>()),
        );
      }
    });
    test('正式原生和绝对 Web API 拒绝 HTTP，HTTPS 接受', () {
      expect(
        () => ApiClient.resolveBaseUrl(
          'http://localhost:8080/api',
          web: false,
          release: true,
        ),
        throwsA(isA<ApiException>()),
      );
      expect(
        () => ApiClient.resolveBaseUrl(
          'http://ledger.example/api',
          web: true,
          release: true,
        ),
        throwsA(isA<ApiException>()),
      );
      expect(
        ApiClient.resolveBaseUrl(
          'https://ledger.example/api',
          web: false,
          release: true,
        ),
        'https://ledger.example/api',
      );
    });
    test('拒绝 API 地址中的账号、查询参数与片段', () {
      for (final value in [
        'https://user:pass@ledger.example/api',
        'https://ledger.example/api?token=bad',
        'https://ledger.example/api#part',
      ]) {
        expect(
          () => ApiClient.resolveBaseUrl(value, web: false),
          throwsA(isA<ApiException>()),
        );
      }
    });
  });
}
