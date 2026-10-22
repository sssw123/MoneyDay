import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:moneyday/app/app_shell.dart';
import 'package:moneyday/app/moneyday_app.dart';
import 'package:moneyday/data/services/auth_controller.dart';
import 'package:moneyday/ui/features/auth/change_password_page.dart';
import 'package:moneyday/ui/features/auth/login_page.dart';
import 'package:moneyday/ui/features/finance/dashboard_page.dart';
import 'api_contract_test.dart' show TestHarness, responseBody, sessionValue;

class _AppFixture {
  _AppFixture({
    bool signedIn = true,
    this.forced = false,
    this.profileOffline = false,
  }) {
    if (signedIn) {
      h.session.setSession(sessionValue(mustChangePassword: forced));
    }
    auth = AuthController(api: h.api, session: h.session);
    h.adapter.handler = (request) {
      final path = request.uri.path;
      if (path == '/api/user/profile') {
        if (profileOffline) {
          throw DioException(
            requestOptions: request,
            type: DioExceptionType.connectionError,
          );
        }
        return responseBody(h.session.user!.toJson());
      }
      if (path == '/api/user/login') {
        return responseBody(sessionValue(mustChangePassword: forced).toJson());
      }
      if (request.method != 'GET') return responseBody(null);
      return responseBody(switch (path) {
        '/api/stats' => <String, Object?>{},
        '/api/admin/users' => <String, Object?>{'records': [], 'total': 0},
        '/api/todos/pending-count' => <String, Object?>{'count': 0},
        '/api/accounts' => [
          <String, Object?>{
            'id': 1,
            'name': request.headers['Authorization'] == 'Bearer token-b'
                ? '新用户账户'
                : '旧用户账户',
            'type': 'CASH',
            'initialBalance': 1000,
            'currentBalance': 1000,
          },
        ],
        _ => <Object?>[],
      });
    };
  }
  final TestHarness h = TestHarness();
  late final AuthController auth;
  bool forced;
  bool profileOffline;
  void dispose() {
    auth.dispose();
    h.dispose();
  }
}

GoRouter _router(WidgetTester tester) =>
    tester.widget<MaterialApp>(find.byType(MaterialApp)).routerConfig!
        as GoRouter;
String _location(WidgetTester tester) =>
    _router(tester).routeInformationProvider.value.uri.path;

Future<void> _withApp(
  WidgetTester tester,
  Future<void> Function(_AppFixture) body, {
  Size size = const Size(1440, 900),
  bool signedIn = true,
  bool forced = false,
  bool profileOffline = false,
  String initialLocation = '/',
}) async {
  final fixture = _AppFixture(
    signedIn: signedIn,
    forced: forced,
    profileOffline: profileOffline,
  );
  try {
    tester.binding.platformDispatcher.defaultRouteNameTestValue =
        initialLocation;
    await tester.binding.setSurfaceSize(size);
    await tester.pumpWidget(
      MoneydayApp(auth: fixture.auth, repository: fixture.h.repository),
    );
    await tester.pumpAndSettle();
    await body(fixture);
  } finally {
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
    fixture.dispose();
    await tester.binding.setSurfaceSize(null);
    tester.binding.platformDispatcher.clearDefaultRouteNameTestValue();
  }
}

void main() {
  for (final entry in const {
    '/accounts?source=bookmark': '/accounts?source=bookmark',
    '/wishlist?source=bookmark': '/plan/wishlist?source=bookmark',
    '/admin/users': '/settings',
  }.entries) {
    testWidgets('冷启动恢复深链接 ${entry.key}，继续执行权限守卫', (tester) async {
      await _withApp(tester, (f) async {
        expect(
          _router(tester).routeInformationProvider.value.uri.toString(),
          entry.value,
        );
        expect(tester.takeException(), isNull);
      }, initialLocation: entry.key);
    });
  }

  testWidgets('深链接离线验证重试后恢复原页面与查询参数', (tester) async {
    await _withApp(
      tester,
      (f) async {
        expect(_location(tester), '/session');
        f.profileOffline = false;
        await tester.tap(find.widgetWithText(FilledButton, '重新验证'));
        await tester.pumpAndSettle();
        expect(
          _router(tester).routeInformationProvider.value.uri.toString(),
          '/accounts?source=bookmark',
        );
      },
      profileOffline: true,
      initialLocation: '/accounts?source=bookmark',
    );
  });

  testWidgets('冷启动深链接优先强制改密，不读取账本', (tester) async {
    await _withApp(
      tester,
      (f) async {
        expect(_location(tester), '/change-password');
        expect(
          f.h.adapter.calls.every((r) => r.uri.path == '/api/user/profile'),
          isTrue,
        );
      },
      forced: true,
      initialLocation: '/accounts?source=bookmark',
    );
  });

  testWidgets('未登录深链接在登录后恢复，拒绝外部与循环返回地址', (tester) async {
    await _withApp(
      tester,
      (f) async {
        expect(_location(tester), '/login');
        await tester.enterText(find.byType(TextFormField).at(0), 'demo');
        await tester.enterText(find.byType(TextFormField).at(1), 'Password123');
        await tester.tap(find.widgetWithText(FilledButton, '登录'));
        await tester.pumpAndSettle();
        expect(
          _router(tester).routeInformationProvider.value.uri.toString(),
          '/accounts?source=bookmark',
        );
        for (final target in [
          'https://example.com',
          '//example.com/accounts',
          '/login',
          '/session',
          '/change-password',
        ]) {
          _router(tester).go(
            Uri(
              path: '/session',
              queryParameters: {'returnTo': target},
            ).toString(),
          );
          await tester.pumpAndSettle();
          expect(_location(tester), '/');
        }
      },
      signedIn: false,
      initialLocation: '/accounts?source=bookmark',
    );
  });

  testWidgets('未登录访问业务页及旧别名均跳转登录，不发送账本查询', (tester) async {
    await _withApp(tester, (f) async {
      expect(find.byType(LoginPage), findsOneWidget);
      for (final path in [
        '/',
        '/transactions',
        '/accounts',
        '/admin/users',
        '/wishlist',
        '/budgets',
        '/mine',
      ]) {
        _router(tester).go(path);
        await tester.pumpAndSettle();
        expect(_location(tester), '/login');
        expect(find.byType(AppShell), findsNothing);
      }
      expect(f.h.adapter.calls, isEmpty);
    }, signedIn: false);
  });

  testWidgets('真实登录表单进入首页，退出立即返回登录', (tester) async {
    await _withApp(tester, (f) async {
      await tester.enterText(find.byType(TextFormField).at(0), '  demo  ');
      await tester.enterText(find.byType(TextFormField).at(1), 'Password123');
      await tester.tap(find.widgetWithText(FilledButton, '登录'));
      await tester.pumpAndSettle();
      expect(_location(tester), '/');
      expect(find.byType(DashboardPage), findsOneWidget);
      final loginIndex = f.h.adapter.calls.indexWhere(
        (r) => r.uri.path == '/api/user/login',
      );
      expect(loginIndex, 0);
      expect(
        f.h.adapter.calls[loginIndex].headers.containsKey('Authorization'),
        isFalse,
      );
      expect(f.h.adapter.bodies[loginIndex], {
        'username': 'demo',
        'password': 'Password123',
      });
      await tester.tap(find.byTooltip('退出登录'));
      await tester.pumpAndSettle();
      expect(_location(tester), '/login');
      expect(f.auth.user, isNull);
    }, signedIn: false);
  });

  testWidgets('强制改密拦截全部业务路由及别名，不读取账本', (tester) async {
    await _withApp(tester, (f) async {
      for (final path in [
        '/',
        '/transactions',
        '/accounts',
        '/categories',
        '/budget',
        '/plan/targets',
        '/plan/wishlist',
        '/plan/liabilities',
        '/todos',
        '/settings',
        '/admin/users',
        '/budgets',
        '/wishlist',
        '/plan',
        '/mine',
      ]) {
        _router(tester).go(path);
        await tester.pumpAndSettle();
        expect(_location(tester), '/change-password', reason: path);
        expect(find.byType(ChangePasswordPage), findsOneWidget);
        expect(find.byType(AppShell), findsNothing);
      }
      expect(
        f.h.adapter.calls.every((r) => r.uri.path == '/api/user/profile'),
        isTrue,
      );
    }, forced: true);
  });

  testWidgets('初次登录改密完整 UI 流程成功后重新登录', (tester) async {
    await _withApp(
      tester,
      (f) async {
        await tester.enterText(find.byType(TextFormField).at(0), 'demo');
        await tester.enterText(find.byType(TextFormField).at(1), 'OldPassword');
        await tester.tap(find.widgetWithText(FilledButton, '登录'));
        await tester.pumpAndSettle();
        expect(_location(tester), '/change-password');
        await tester.enterText(find.byType(TextFormField).at(0), 'OldPassword');
        await tester.enterText(
          find.byType(TextFormField).at(1),
          'NewPassword123',
        );
        await tester.enterText(
          find.byType(TextFormField).at(2),
          'NewPassword123',
        );
        await tester.tap(find.widgetWithText(FilledButton, '修改密码并重新登录'));
        await tester.pumpAndSettle();
        expect(_location(tester), '/login');
        expect(find.text('密码已修改，请重新登录'), findsOneWidget);
        final passwordIndex = f.h.adapter.calls.indexWhere(
          (r) => r.uri.path == '/api/user/password',
        );
        expect(f.h.adapter.calls[passwordIndex].method, 'PUT');
        expect(f.h.adapter.bodies[passwordIndex], {
          'oldPassword': 'OldPassword',
          'newPassword': 'NewPassword123',
        });
        expect(f.auth.signedIn, isFalse);
      },
      signedIn: false,
      forced: true,
    );
  });

  testWidgets('普通用户没有管理入口，直接访问管理页也拒绝', (tester) async {
    await _withApp(tester, (f) async {
      expect(find.text('用户管理'), findsNothing);
      _router(tester).go('/admin/users');
      await tester.pumpAndSettle();
      expect(_location(tester), '/settings');
      expect(
        f.h.adapter.calls.any((r) => r.uri.path == '/api/admin/users'),
        isFalse,
      );
    });
  });

  testWidgets('全部旧别名落到对应业务路径', (tester) async {
    await _withApp(tester, (f) async {
      for (final alias in const {
        '/budgets': '/budget',
        '/wishlist': '/plan/wishlist',
        '/plan': '/plan/targets',
        '/mine': '/settings',
      }.entries) {
        _router(tester).go(alias.key);
        await tester.pumpAndSettle();
        expect(_location(tester), alias.value);
        expect(find.byType(AppShell), findsOneWidget);
        expect(tester.takeException(), isNull);
      }
    });
  });

  testWidgets('恢复会话 profile 断网停留重试页，恢复网络后进入账本', (tester) async {
    await _withApp(tester, (f) async {
      expect(_location(tester), '/session');
      expect(find.byType(SessionCheckPage), findsOneWidget);
      expect(find.text('重新验证'), findsOneWidget);
      expect(f.h.session.token, 'token-a');
      expect(
        f.h.adapter.calls.every((r) => r.uri.path == '/api/user/profile'),
        isTrue,
      );
      f.profileOffline = false;
      await tester.tap(find.widgetWithText(FilledButton, '重新验证'));
      await tester.pumpAndSettle();
      expect(_location(tester), '/');
      expect(find.byType(DashboardPage), findsOneWidget);
      expect(f.auth.validated, isTrue);
    }, profileOffline: true);
  });

  testWidgets('换用户销毁业务页面和旧表单，旧账户不可见且没有写入', (tester) async {
    await _withApp(tester, (f) async {
      _router(tester).go('/accounts');
      await tester.pumpAndSettle();
      expect(find.text('旧用户账户'), findsOneWidget);
      await tester.tap(find.widgetWithText(FilledButton, '新增账户'));
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsOneWidget);
      await tester.enterText(find.byType(TextFormField).at(0), '不应保存的旧表单');
      f.h.session.setSession(sessionValue(id: 2, token: 'token-b'));
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsNothing);
      expect(find.text('旧用户账户'), findsNothing);
      expect(find.text('新用户账户'), findsOneWidget);
      expect(f.h.adapter.calls.where((r) => r.method != 'GET'), isEmpty);
      expect(tester.takeException(), isNull);
    });
  });

  testWidgets('连续缩放跨越 599/600/1199/1200 断点保留当前账本页面', (tester) async {
    await _withApp(tester, (f) async {
      _router(tester).go('/accounts');
      await tester.pumpAndSettle();
      for (final width in [599.0, 600.0, 1199.0, 1200.0, 390.0]) {
        await tester.binding.setSurfaceSize(Size(width, 844));
        await tester.pumpAndSettle();
        expect(_location(tester), '/accounts');
        expect(find.text('旧用户账户'), findsOneWidget);
        expect(
          find.byType(NavigationBar),
          width < 600 ? findsOneWidget : findsNothing,
        );
        expect(
          find.byType(NavigationRail),
          width >= 600 && width < 1200 ? findsOneWidget : findsNothing,
        );
        expect(
          find.text('每一天，都心中有数'),
          width >= 1200 ? findsOneWidget : findsNothing,
        );
        expect(tester.takeException(), isNull, reason: '$width');
      }
    });
  });

  for (final width in [390.0, 768.0, 1440.0]) {
    testWidgets('${width.toInt()} 宽度使用指定导航且无布局溢出', (tester) async {
      await _withApp(tester, (f) async {
        expect(
          find.byType(NavigationBar),
          width < 600 ? findsOneWidget : findsNothing,
        );
        expect(
          find.byType(NavigationRail),
          width >= 600 && width < 1200 ? findsOneWidget : findsNothing,
        );
        expect(
          find.text('每一天，都心中有数'),
          width >= 1200 ? findsOneWidget : findsNothing,
        );
        expect(tester.takeException(), isNull);
      }, size: Size(width, 844));
    });
  }

  testWidgets('较短平板窗口 NavigationRail 可滚动到设置且不溢出', (tester) async {
    await _withApp(tester, (f) async {
      final railScroll = find
          .ancestor(
            of: find.byType(NavigationRail),
            matching: find.byType(SingleChildScrollView),
          )
          .first;
      await tester.drag(railScroll, const Offset(0, -1000));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('设置'));
      await tester.tap(find.text('设置'));
      await tester.pumpAndSettle();
      expect(_location(tester), '/settings');
      expect(tester.takeException(), isNull);
    }, size: const Size(768, 320));
  });
}
