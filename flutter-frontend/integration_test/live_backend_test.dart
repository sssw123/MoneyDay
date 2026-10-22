import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:moneyday/app/moneyday_app.dart';
import 'package:moneyday/data/repositories/moneyday_repository.dart';
import 'package:moneyday/data/services/api_client.dart';
import 'package:moneyday/data/services/auth_controller.dart';
import 'package:moneyday/data/services/session_controller.dart';

/// Run explicitly against a dedicated test account, never a user's real ledger.
/// Missing configuration FAILS this opt-in suite instead of reporting a pass.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('真实服务：启动、登录、账本读取与记账后核对', (tester) async {
    const username = String.fromEnvironment('TEST_USERNAME');
    const password = String.fromEnvironment('TEST_PASSWORD');
    const baseUrl = String.fromEnvironment('API_BASE_URL');
    const writesAllowed = bool.fromEnvironment('ALLOW_TEST_WRITES');
    expect(username, isNotEmpty, reason: '请提供专用 TEST_USERNAME');
    expect(password, isNotEmpty, reason: '请提供专用 TEST_PASSWORD');
    expect(baseUrl, isNotEmpty, reason: '请配置可达的测试 API_BASE_URL');
    expect(writesAllowed, isTrue, reason: '专用测试账本需要 ALLOW_TEST_WRITES=true');

    final session = SessionController(store: MemorySessionStore());
    final api = ApiClient(session: session, baseUrl: baseUrl);
    final auth = AuthController(api: api, session: session);
    final repository = MoneydayRepository(api: api);
    int? accountId;
    int? transactionId;
    final fixture = 'Flutter验收-${DateTime.now().microsecondsSinceEpoch}';
    try {
      await tester.pumpWidget(MoneydayApp(auth: auth, repository: repository));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.widgetWithText(TextFormField, '用户名'),
        username,
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, '密码'),
        password,
      );
      await tester.tap(find.widgetWithText(FilledButton, '登录'));
      // Real HTTP does not advance with fake time on every native target.
      await tester.runAsync(() async {
        for (var attempt = 0; attempt < 150 && !auth.signedIn; attempt++) {
          await Future<void>.delayed(const Duration(milliseconds: 100));
        }
      });
      await tester.pumpAndSettle();
      expect(auth.signedIn, isTrue, reason: auth.error);
      expect(auth.user!.mustChangePassword, isFalse, reason: '请先完成专用账号初始密码修改');
      expect(find.text('MoneyDay'), findsWidgets);

      await tester.runAsync(() async {
        // Read APIs first; no writes if authentication or the cloud ledger fails.
        await repository.stats();
        final categories = await repository.categories();
        final incomeCategory = categories.firstWhere(
          (category) => category.type == 1 && category.isActive == 1,
        );
        await repository.saveAccount({
          'name': fixture,
          'type': 'BANK',
          'initialBalance': 0,
        });
        final created = (await repository.accounts()).singleWhere(
          (account) => account.name == fixture,
        );
        accountId = created.id;
        final today = DateTime.now();
        final date =
            '${today.year}-${today.month.toString().padLeft(2, '0')}-'
            '${today.day.toString().padLeft(2, '0')}';
        await repository.saveTransaction({
          'type': 1,
          'amount': 123.45,
          'accountId': accountId,
          'categoryId': incomeCategory.id,
          'transactionDate': date,
          'toAccountId': null,
          'remark': fixture,
        });
        final entry = (await repository.transactions()).singleWhere(
          (entry) => entry.accountId == accountId && entry.remark == fixture,
        );
        transactionId = entry.id;
        expect(entry.amount, 123.45);
        final updated = (await repository.accounts()).singleWhere(
          (account) => account.id == accountId,
        );
        expect(updated.currentBalance, closeTo(123.45, 0.001));
        expect(entry.transactionDate, date);
      });
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    } finally {
      await tester.runAsync(() async {
        // Only clean up fixtures whose exact identifiers were returned above.
        try {
          if (accountId != null && transactionId == null) {
            final matches = (await repository.transactions()).where(
              (entry) =>
                  entry.accountId == accountId && entry.remark == fixture,
            );
            for (final entry in matches) {
              await repository.deleteTransaction(entry.id);
            }
          }
          if (transactionId != null) {
            await repository.deleteTransaction(transactionId!);
          }
          if (accountId != null) await repository.deleteAccount(accountId!);
        } finally {
          await auth.logout();
        }
      });
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
      repository.dispose();
      auth.dispose();
      api.dispose();
      session.dispose();
    }
  });
}
