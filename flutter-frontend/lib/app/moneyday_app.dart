import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../data/repositories/moneyday_repository.dart';
import '../data/services/auth_controller.dart';
import '../ui/features/auth/login_page.dart';
import '../ui/features/auth/change_password_page.dart';
import '../ui/features/finance/dashboard_page.dart';
import '../ui/features/finance/accounts_page.dart';
import '../ui/features/finance/categories_page.dart';
import '../ui/features/finance/transactions_page.dart';
import '../ui/features/finance/budget_page.dart';
import '../ui/features/finance/settings_page.dart';
import '../ui/features/planning/goals_page.dart';
import '../ui/features/planning/liabilities_page.dart';
import '../ui/features/planning/todos_page.dart';
import '../ui/features/admin/users_page.dart';
import 'app_shell.dart';

// Accept only internal business routes when restoring a cold-start deep link.
String _returnTo(Uri uri) {
  final target = Uri.tryParse(uri.queryParameters['returnTo'] ?? '/');
  const paths = {
    '/',
    '/transactions',
    '/accounts',
    '/categories',
    '/budget',
    '/settings',
    '/plan/targets',
    '/plan/wishlist',
    '/plan/liabilities',
    '/todos',
    '/admin/users',
    '/budgets',
    '/wishlist',
    '/plan',
    '/mine',
  };
  if (target == null ||
      target.hasScheme ||
      target.hasAuthority ||
      !paths.contains(target.path)) {
    return '/';
  }
  return target.toString();
}

String _sessionGate(String gate, Uri uri) => Uri(
  path: gate,
  queryParameters: {
    'returnTo': uri.path == '/session' || uri.path == '/login'
        ? _returnTo(uri)
        : uri.toString(),
  },
).toString();

class MoneydayApp extends StatefulWidget {
  const MoneydayApp({super.key, required this.auth, required this.repository});
  final AuthController auth;
  final MoneydayRepository repository;
  @override
  State<MoneydayApp> createState() => _MoneydayAppState();
}

class _MoneydayAppState extends State<MoneydayApp> {
  late final GoRouter _router;
  @override
  void initState() {
    super.initState();
    final auth = widget.auth;
    _router = GoRouter(
      refreshListenable: auth,
      redirect: (context, state) {
        final path = state.uri.path;
        if (!auth.signedIn) {
          return path == '/login' ? null : _sessionGate('/login', state.uri);
        }
        if (!auth.validated) {
          return path == '/session'
              ? null
              : _sessionGate('/session', state.uri);
        }
        if (auth.user!.mustChangePassword) {
          return path == '/change-password' ? null : '/change-password';
        }
        if (path == '/login' || path == '/session') return _returnTo(state.uri);
        if (path.startsWith('/admin') && !auth.isAdmin) return '/settings';
        return null;
      },
      routes: [
        GoRoute(path: '/login', builder: (_, _) => const LoginPage()),
        GoRoute(
          path: '/change-password',
          builder: (_, _) => const ChangePasswordPage(),
        ),
        GoRoute(path: '/session', builder: (_, _) => const SessionCheckPage()),
        GoRoute(
          path: '/budgets',
          redirect: (_, state) => state.uri.replace(path: '/budget').toString(),
        ),
        GoRoute(
          path: '/wishlist',
          redirect: (_, state) =>
              state.uri.replace(path: '/plan/wishlist').toString(),
        ),
        GoRoute(
          path: '/plan',
          redirect: (_, state) =>
              state.uri.replace(path: '/plan/targets').toString(),
        ),
        GoRoute(
          path: '/mine',
          redirect: (_, state) =>
              state.uri.replace(path: '/settings').toString(),
        ),
        ShellRoute(
          builder: (context, state, child) => AppShell(
            key: ValueKey(auth.session.generation),
            location: state.uri.path,
            child: child,
          ),
          routes: [
            GoRoute(path: '/', builder: (_, _) => const DashboardPage()),
            GoRoute(
              path: '/transactions',
              builder: (_, _) => const TransactionsPage(),
            ),
            GoRoute(path: '/accounts', builder: (_, _) => const AccountsPage()),
            GoRoute(
              path: '/categories',
              builder: (_, _) => const CategoriesPage(),
            ),
            GoRoute(path: '/budget', builder: (_, _) => const BudgetPage()),
            GoRoute(path: '/settings', builder: (_, _) => const SettingsPage()),
            GoRoute(
              path: '/plan/targets',
              builder: (_, _) => const GoalsPage(wishlist: false),
            ),
            GoRoute(
              path: '/plan/wishlist',
              builder: (_, _) => const GoalsPage(wishlist: true),
            ),
            GoRoute(
              path: '/plan/liabilities',
              builder: (_, _) => const LiabilitiesPage(),
            ),
            GoRoute(path: '/todos', builder: (_, _) => const TodosPage()),
            GoRoute(path: '/admin/users', builder: (_, _) => const UsersPage()),
          ],
        ),
      ],
      errorBuilder: (context, state) => Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('页面不存在'),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => context.go('/'),
                child: const Text('返回首页'),
              ),
            ],
          ),
        ),
      ),
    );
    unawaited(auth.initialize());
  }

  @override
  void dispose() {
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => MultiProvider(
    providers: [
      ChangeNotifierProvider<AuthController>.value(value: widget.auth),
      ChangeNotifierProvider<MoneydayRepository>.value(
        value: widget.repository,
      ),
    ],
    child: MaterialApp.router(
      title: 'MoneyDay',
      debugShowCheckedModeBanner: false,
      locale: const Locale('zh', 'CN'),
      supportedLocales: const [Locale('zh', 'CN')],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xff287564)),
        scaffoldBackgroundColor: const Color(0xfff7faf8),
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
          filled: true,
        ),
        appBarTheme: const AppBarTheme(centerTitle: false),
      ),
      routerConfig: _router,
    ),
  );
}
