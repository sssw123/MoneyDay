import 'dart:async';
import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dio/dio.dart';
import 'package:moneyday/data/services/api_client.dart';
import 'package:moneyday/data/services/auth_controller.dart';
import 'package:moneyday/data/services/session_controller.dart';
import 'package:moneyday/data/repositories/moneyday_repository.dart';
import 'package:moneyday/ui/core/widgets.dart';
import 'package:moneyday/ui/features/auth/login_page.dart';
import 'api_contract_test.dart' show TestHarness, responseBody, sessionValue;

TestHarness harness() {
  final value = TestHarness();
  addTearDown(value.dispose);
  return value;
}

AuthController authFor(TestHarness h) {
  final auth = AuthController(api: h.api, session: h.session);
  addTearDown(auth.dispose);
  return auth;
}

void main() {
  group('会话存储与到期', () {
    test('恢复未过期会话，更新资料不改变 generation，清空删除存储', () {
      final store = MemorySessionStore()
        ..write(jsonEncode(sessionValue().toJson()));
      final session = SessionController(store: store);
      addTearDown(session.dispose);
      expect(session.token, 'token-a');
      final generation = session.generation;
      session.updateProfile(session.user!.copyWith(username: '改名'));
      expect(session.generation, generation);
      expect((jsonDecode(store.read()!) as Map)['user']['username'], '改名');
      session.clear();
      expect(session.generation, generation + 1);
      expect(session.user, isNull);
      expect(session.token, isEmpty);
      expect(store.read(), isNull);
    });
    for (final raw in [
      'not json',
      '{}',
      jsonEncode(sessionValue(expiresAt: '2020-01-01T00:00:00Z').toJson()),
      jsonEncode(sessionValue(token: '').toJson()),
    ]) {
      test('拒绝损坏、缺字段或已过期存储：$raw', () {
        final store = MemorySessionStore()..write(raw);
        final session = SessionController(store: store);
        addTearDown(session.dispose);
        expect(session.signedIn, isFalse);
        expect(store.read(), isNull);
      });
    }
    test('默认原生会话不跨进程实例恢复', () {
      final first = SessionController()..setSession(sessionValue());
      final second = SessionController();
      addTearDown(first.dispose);
      addTearDown(second.dispose);
      expect(first.signedIn, isTrue);
      expect(second.signedIn, isFalse);
    });
    testWidgets('登录后在 expiresAt 到期自动清空；旧定时器不能清除新会话', (tester) async {
      var now = DateTime.utc(2026, 10, 22);
      final store = MemorySessionStore();
      final session = SessionController(store: store, now: () => now);
      session.setSession(
        sessionValue(
          expiresAt: now.add(const Duration(seconds: 1)).toIso8601String(),
        ),
      );
      session.setSession(
        sessionValue(
          id: 2,
          token: 'token-b',
          expiresAt: now.add(const Duration(seconds: 3)).toIso8601String(),
        ),
      );
      now = now.add(const Duration(seconds: 2));
      await tester.pump(const Duration(seconds: 2));
      expect(session.token, 'token-b');
      now = now.add(const Duration(seconds: 2));
      await tester.pump(const Duration(seconds: 2));
      expect(session.signedIn, isFalse);
      expect(store.read(), isNull);
      session.dispose();
    });
  });

  group('登录、强制改密与权限', () {
    test('登录发送密码但不发送旧 Bearer，保留强制改密资料', () async {
      final h = harness();
      h.session.setSession(sessionValue());
      final auth = authFor(h);
      h.adapter.handler = (_) => responseBody(
        sessionValue(
          id: 2,
          token: 'token-b',
          mustChangePassword: true,
        ).toJson(),
      );
      expect(await auth.login('  新用户  ', 'Password123'), isTrue);
      expect(h.adapter.calls.single.method, 'POST');
      expect(h.adapter.calls.single.uri.path, '/api/user/login');
      expect(
        h.adapter.calls.single.headers.containsKey('Authorization'),
        isFalse,
      );
      expect(h.adapter.bodies.single, {
        'username': '新用户',
        'password': 'Password123',
      });
      expect(auth.validated, isTrue);
      expect(auth.user!.mustChangePassword, isTrue);
      expect(h.session.token, 'token-b');
    });
    test('登录失败保留可读错误且不留下旧会话', () async {
      final h = harness();
      h.session.setSession(sessionValue());
      final auth = authFor(h);
      h.adapter.handler = (_) =>
          responseBody(null, status: 401, code: 401, message: '用户名或密码错误');
      expect(await auth.login('user', 'wrong'), isFalse);
      expect(auth.error, '用户名或密码错误');
      expect(h.session.signedIn, isFalse);
      expect(auth.busy, isFalse);
    });
    test('首次 profile 断网保留 session；重试成功才验证', () async {
      final h = harness();
      h.session.setSession(sessionValue());
      final auth = authFor(h);
      h.adapter.handler = (request) => throw DioException(
        requestOptions: request,
        type: DioExceptionType.connectionError,
      );
      await auth.initialize();
      expect(h.session.token, 'token-a');
      expect(auth.validated, isFalse);
      expect(auth.error, contains('刷新重试'));
      expect(auth.checking, isFalse);
      h.adapter.handler = (_) =>
          responseBody(sessionValue(role: 'ADMIN').user.toJson());
      await auth.validateProfile();
      expect(auth.validated, isTrue);
      expect(auth.isAdmin, isTrue);
      expect(auth.error, isNull);
    });
    test('profile 的 401 清空失效会话，停用账号也不可进入业务页', () async {
      final h = harness();
      h.session.setSession(sessionValue());
      final auth = authFor(h);
      h.adapter.handler = (_) => responseBody(null, status: 401, code: 401);
      await auth.validateProfile();
      expect(auth.signedIn, isFalse);
      expect(auth.validated, isFalse);
      h.session.setSession(sessionValue());
      h.adapter.handler = (_) => responseBody(
        sessionValue().user.copyWith(status: 'DISABLED').toJson(),
      );
      await auth.validateProfile();
      expect(auth.signedIn, isFalse);
      expect(auth.error, contains('停用'));
    });
    test('业务 401 立即清空会话，当前业务 future 按旧会话丢弃', () async {
      final h = harness();
      h.session.setSession(sessionValue());
      final auth = authFor(h)..validated = true;
      h.adapter.handler = (_) => responseBody(null, status: 401, code: 401);
      await expectLater(
        h.repository.accounts(),
        throwsA(isA<StaleSessionException>()),
      );
      expect(auth.signedIn, isFalse);
      expect(auth.validated, isFalse);
      expect(auth.error, contains('过期'));
    });
    test('403 在线重新读取 profile，强制改密和角色收回立即生效', () async {
      final h = harness();
      h.session.setSession(sessionValue(role: 'ADMIN'));
      final auth = authFor(h)..validated = true;
      h.adapter.handler = (request) => request.uri.path == '/api/user/profile'
          ? responseBody(sessionValue(mustChangePassword: true).user.toJson())
          : responseBody(null, status: 403, code: 403, message: '请先修改初始密码');
      await expectLater(
        h.repository.accounts(),
        throwsA(isA<ApiException>().having((e) => e.code, 'code', 403)),
      );
      expect(h.adapter.calls.map((r) => r.uri.path), [
        '/api/accounts',
        '/api/user/profile',
      ]);
      expect(auth.user!.mustChangePassword, isTrue);
      expect(auth.isAdmin, isFalse);
      expect(auth.signedIn, isTrue);
    });
    test('改密使用现有契约，成功后撤销本地会话并要求重新登录', () async {
      final h = harness();
      h.session.setSession(sessionValue(mustChangePassword: true));
      final auth = authFor(h)..validated = true;
      expect(
        await auth.changePassword('OldPassword', 'NewPassword123'),
        isTrue,
      );
      expect(h.adapter.calls.single.method, 'PUT');
      expect(h.adapter.calls.single.uri.path, '/api/user/password');
      expect(h.adapter.bodies.single, {
        'oldPassword': 'OldPassword',
        'newPassword': 'NewPassword123',
      });
      expect(auth.user, isNull);
      expect(auth.signedIn, isFalse);
      expect(auth.validated, isFalse);
      expect(auth.error, contains('重新登录'));
    });
    test('改密失败保留会话且不自动重新发送', () async {
      final h = harness();
      h.session.setSession(sessionValue());
      final auth = authFor(h);
      h.adapter.handler = (_) =>
          responseBody(null, code: 400, message: '原密码不正确');
      expect(await auth.changePassword('wrong', 'NewPassword123'), isFalse);
      expect(auth.signedIn, isTrue);
      expect(auth.error, '原密码不正确');
      expect(h.adapter.calls, hasLength(1));
    });
  });

  group('会话隔离与竞态', () {
    for (final status in [200, 401]) {
      test('旧请求的 $status 响应不能污染或清除新用户', () async {
        final h = harness();
        h.session.setSession(sessionValue());
        final auth = authFor(h)..validated = true;
        final started = Completer<void>();
        final result = Completer<ResponseBody>();
        h.adapter.handler = (_) {
          started.complete();
          return result.future;
        };
        final request = h.repository.accounts();
        final assertion = expectLater(
          request,
          throwsA(isA<StaleSessionException>()),
        );
        await started.future;
        h.session.setSession(sessionValue(id: 2, token: 'token-b'));
        result.complete(responseBody([], status: status, code: status));
        await assertion;
        expect(auth.user!.id, 2);
        expect(h.session.token, 'token-b');
        expect(auth.error, isNull);
      });
    }
    test('旧表单异步确认后发写请求被 zone 在传输前拒绝', () async {
      final h = harness();
      h.session.setSession(sessionValue());
      final gate = Completer<void>();
      final operation = ApiClient.inSession(h.session.generation, () async {
        await gate.future;
        await h.repository.saveTransaction({
          'amount': 20,
          'type': 2,
          'accountId': 1,
        });
      });
      final assertion = expectLater(
        operation,
        throwsA(isA<StaleSessionException>()),
      );
      h.session.setSession(sessionValue(id: 2, token: 'token-b'));
      gate.complete();
      await assertion;
      expect(h.adapter.calls, isEmpty);
      expect(h.session.token, 'token-b');
    });
    test('logout 本地立即清空，后台只撤销捕获的旧 token，迟到 401 不清新会话', () async {
      final h = harness();
      h.session.setSession(sessionValue());
      final auth = authFor(h);
      final started = Completer<void>();
      final result = Completer<ResponseBody>();
      h.adapter.handler = (_) {
        started.complete();
        return result.future;
      };
      final logout = auth.logout();
      expect(h.session.signedIn, isFalse);
      await started.future;
      expect(h.adapter.calls.single.uri.path, '/api/user/logout');
      expect(h.adapter.calls.single.method, 'POST');
      expect(h.adapter.calls.single.headers['Authorization'], 'Bearer token-a');
      h.session.setSession(sessionValue(id: 2, token: 'token-b'));
      result.complete(responseBody(null, status: 401, code: 401));
      await logout;
      expect(h.session.token, 'token-b');
      expect(auth.user!.id, 2);
      expect(auth.error, isNull);
    });
    test('并发登录时迟到的旧登录不能覆盖新登录', () async {
      final h = harness();
      final auth = authFor(h);
      final firstStarted = Completer<void>();
      final oldResult = Completer<ResponseBody>();
      h.adapter.handler = (request) {
        if ((request.data as Map)['username'] == 'first') {
          firstStarted.complete();
          return oldResult.future;
        }
        return responseBody(sessionValue(id: 2, token: 'token-b').toJson());
      };
      final first = auth.login('first', 'Password123');
      await firstStarted.future;
      expect(await auth.login('second', 'Password123'), isTrue);
      oldResult.complete(responseBody(sessionValue().toJson()));
      expect(await first, isFalse);
      expect(h.session.token, 'token-b');
      expect(auth.busy, isFalse);
      expect(auth.error, isNull);
    });
    test('旧 profile 失败不能使新登录失效', () async {
      final h = harness();
      h.session.setSession(sessionValue());
      final auth = authFor(h);
      final started = Completer<void>();
      final oldProfile = Completer<ResponseBody>();
      h.adapter.handler = (request) {
        if (request.uri.path == '/api/user/profile') {
          started.complete();
          return oldProfile.future;
        }
        return responseBody(sessionValue(id: 2, token: 'token-b').toJson());
      };
      final profile = auth.validateProfile();
      await started.future;
      expect(await auth.login('second', 'Password123'), isTrue);
      oldProfile.complete(responseBody(null, status: 401, code: 401));
      await profile;
      expect(auth.user!.id, 2);
      expect(auth.validated, isTrue);
      expect(auth.error, isNull);
    });
  });

  group('认证布局与弹窗生命周期', () {
    testWidgets('窄屏、两倍文字及键盘下认证表单可滚动且不溢出', (tester) async {
      await tester.binding.setSurfaceSize(const Size(320, 480));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(
              size: Size(320, 480),
              viewInsets: EdgeInsets.only(bottom: 220),
              textScaler: TextScaler.linear(2),
            ),
            child: AuthFrame(
              title: '欢迎回到 MoneyDay',
              subtitle: '登录云端账本，在每一端管理你的收支与计划。',
              child: Column(
                children: [
                  const TextField(
                    decoration: InputDecoration(labelText: '用户名'),
                  ),
                  const SizedBox(height: 20),
                  const TextField(decoration: InputDecoration(labelText: '密码')),
                  const SizedBox(height: 24),
                  FilledButton(onPressed: () {}, child: const Text('登录')),
                ],
              ),
            ),
          ),
        ),
      );
      await tester.drag(
        find.byType(SingleChildScrollView),
        const Offset(0, -800),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.text('登录'), findsOneWidget);
    });
    testWidgets('表单成功关闭后才能释放调用方控制器，退出动画不再引用已释放对象', (tester) async {
      var finished = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                child: const Text('打开'),
                onPressed: () async {
                  final controller = TextEditingController(text: '测试账户');
                  final saved = await showFormDialog(
                    context,
                    title: '新增账户',
                    builder: (_, _) => TextFormField(
                      controller: controller,
                      validator: requiredText,
                    ),
                    onSubmit: () async {},
                  );
                  controller.dispose();
                  finished = saved;
                },
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('打开'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('保存'));
      await tester.pumpAndSettle();
      expect(finished, isTrue);
      expect(find.text('新增账户'), findsNothing);
      expect(tester.takeException(), isNull);
    });
    testWidgets('异步表单处理中切换会话会关闭旧弹窗且禁止迟到写入', (tester) async {
      final h = harness();
      h.session.setSession(sessionValue());
      final gate = Completer<void>();
      await tester.pumpWidget(
        ChangeNotifierProvider<MoneydayRepository>.value(
          value: h.repository,
          child: MaterialApp(
            home: Builder(
              builder: (context) => Scaffold(
                body: TextButton(
                  child: const Text('打开'),
                  onPressed: () {
                    showFormDialog(
                      context,
                      title: '旧用户转账',
                      builder: (_, _) => const Text('确认转账'),
                      onSubmit: () async {
                        await gate.future;
                        await h.repository.saveTransaction({
                          'amount': 10,
                          'type': 3,
                        });
                      },
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('打开'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('保存'));
      await tester.pump();
      h.session.setSession(sessionValue(id: 2, token: 'token-b'));
      await tester.pumpAndSettle();
      expect(find.text('旧用户转账'), findsNothing);
      gate.complete();
      await tester.pumpAndSettle();
      expect(h.adapter.calls, isEmpty);
      expect(h.session.token, 'token-b');
      expect(tester.takeException(), isNull);
      h.session.clear();
    });
    testWidgets('表单请求 401 清会话，关闭旧弹窗并保留重新登录提示', (tester) async {
      final h = harness();
      h.session.setSession(sessionValue());
      final auth = authFor(h);
      h.adapter.handler = (_) => responseBody(null, status: 401, code: 401);
      await tester.pumpWidget(
        ChangeNotifierProvider<MoneydayRepository>.value(
          value: h.repository,
          child: MaterialApp(
            home: Builder(
              builder: (context) => Scaffold(
                body: TextButton(
                  child: const Text('打开'),
                  onPressed: () {
                    showFormDialog(
                      context,
                      title: '修改账户',
                      builder: (_, _) => const Text('账户资料'),
                      onSubmit: () => h.repository.saveAccount({'name': '账户'}),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('打开'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('保存'));
      await tester.pumpAndSettle();
      expect(auth.signedIn, isFalse);
      expect(auth.error, contains('重新登录'));
      expect(find.text('修改账户'), findsNothing);
      expect(find.textContaining('StaleSessionException'), findsNothing);
      expect(tester.takeException(), isNull);
    });
  });
}
