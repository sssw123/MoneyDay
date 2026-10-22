import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../data/services/auth_controller.dart';

class AppDestination {
  const AppDestination(this.path, this.label, this.icon);
  final String path;
  final String label;
  final IconData icon;
}

const _destinations = [
  AppDestination('/', '首页', Icons.dashboard_outlined),
  AppDestination('/transactions', '记账', Icons.receipt_long_outlined),
  AppDestination('/budget', '周期预算', Icons.calendar_month_outlined),
  AppDestination('/accounts', '账户', Icons.account_balance_wallet_outlined),
  AppDestination('/categories', '分类', Icons.category_outlined),
  AppDestination('/plan/targets', '长期目标', Icons.flag_outlined),
  AppDestination('/plan/wishlist', '心愿单', Icons.favorite_border),
  AppDestination('/plan/liabilities', '负债', Icons.credit_card_outlined),
  AppDestination('/todos', '待办', Icons.task_alt),
  AppDestination('/settings', '设置', Icons.settings_outlined),
  AppDestination('/admin/users', '用户管理', Icons.manage_accounts_outlined),
];
const _mobile = [
  AppDestination('/', '首页', Icons.dashboard_outlined),
  AppDestination('/transactions', '记账', Icons.receipt_long_outlined),
  AppDestination('/plan/targets', '计划', Icons.flag_outlined),
  AppDestination('/todos', '待办', Icons.task_alt),
  AppDestination('/settings', '设置', Icons.settings_outlined),
];

class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.child, required this.location});
  final Widget child;
  final String location;
  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    final destinations = _destinations
        .where((value) => value.path != '/admin/users' || auth.isAdmin)
        .toList();
    final selected = destinations.indexWhere((value) => value.path == location);
    final isPlan = location.startsWith('/plan/');
    return LayoutBuilder(
      builder: (context, constraints) {
        final mobile = constraints.maxWidth < 600;
        final wide = constraints.maxWidth >= 1200;
        final content = child;
        return Scaffold(
          appBar: AppBar(
            title: const Text('MoneyDay'),
            actions: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: mobile ? 100 : 240),
                    child: Text(
                      auth.user?.username ?? '',
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ),
              IconButton(
                tooltip: '退出登录',
                onPressed: auth.logout,
                icon: const Icon(Icons.logout),
              ),
            ],
          ),
          body: SafeArea(
            top: false,
            child: Row(
              children: [
                if (!mobile && wide)
                  SizedBox(
                    width: 232,
                    child: Material(
                      color: Theme.of(context).colorScheme.surfaceContainerLow,
                      child: ListView(
                        padding: const EdgeInsets.all(12),
                        children: [
                          const Padding(
                            padding: EdgeInsets.all(16),
                            child: Text('每一天，都心中有数'),
                          ),
                          for (final destination in destinations)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: ListTile(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                selected: location == destination.path,
                                selectedTileColor: Theme.of(
                                  context,
                                ).colorScheme.secondaryContainer,
                                leading: Icon(destination.icon),
                                title: Text(destination.label),
                                onTap: () => context.go(destination.path),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                if (!mobile && !wide)
                  LayoutBuilder(
                    builder: (context, railConstraints) =>
                        SingleChildScrollView(
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              minHeight: railConstraints.maxHeight,
                            ),
                            child: IntrinsicHeight(
                              child: NavigationRail(
                                selectedIndex: selected < 0 ? 0 : selected,
                                labelType: NavigationRailLabelType.all,
                                onDestinationSelected: (index) =>
                                    context.go(destinations[index].path),
                                destinations: destinations
                                    .map(
                                      (value) => NavigationRailDestination(
                                        icon: Icon(value.icon),
                                        label: Text(value.label),
                                      ),
                                    )
                                    .toList(),
                              ),
                            ),
                          ),
                        ),
                  ),
                if (!mobile) const VerticalDivider(width: 1),
                Expanded(child: content),
              ],
            ),
          ),
          bottomNavigationBar: mobile
              ? NavigationBar(
                  selectedIndex: isPlan
                      ? 2
                      : location == '/transactions'
                      ? 1
                      : location == '/todos'
                      ? 3
                      : location == '/'
                      ? 0
                      : 4,
                  onDestinationSelected: (index) =>
                      context.go(_mobile[index].path),
                  destinations: _mobile
                      .map(
                        (value) => NavigationDestination(
                          icon: Icon(value.icon),
                          label: value.label,
                        ),
                      )
                      .toList(),
                )
              : null,
        );
      },
    );
  }
}
