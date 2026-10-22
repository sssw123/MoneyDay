import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:moneyday/data/models/models.dart';
import 'package:moneyday/data/repositories/moneyday_repository.dart';
import 'package:moneyday/data/services/api_client.dart'
    show StaleSessionException;
import 'package:moneyday/ui/core/feature_view_model.dart';
import 'package:moneyday/ui/core/widgets.dart';
import '../planning/planning_widgets.dart';

String? usernameError(String? value) =>
    RegExp(r'^[A-Za-z0-9_.-]{3,50}$').hasMatch(value?.trim() ?? '')
    ? null
    : '用户名须为 3–50 位字母、数字、下划线、点或横线';

class UsersViewModel extends FeatureViewModel {
  UsersViewModel(super.repository);
  List<UserProfile> users = [];
  String keyword = '';
  String? status;
  int page = 1;
  int pageSize = 20;
  int total = 0;
  int _query = 0;
  @override
  Future<void> fetch() async {
    final generation = repository.sessionGeneration;
    final query = ++_query;
    final result = await repository.users(
      page: page,
      pageSize: pageSize,
      keyword: keyword.trim(),
      status: status,
    );
    if (generation != repository.sessionGeneration) {
      throw const StaleSessionException();
    }
    if (query != _query) return;
    users = result.records;
    total = result.total;
  }

  Future<void> search(String value, String? filter) async {
    keyword = value;
    status = filter;
    page = 1;
    await load();
  }

  Future<void> changePage(int value) async {
    page = value;
    await load();
  }

  Future<void> remove(UserProfile user) async {
    final previousPage = page;
    final succeeded = await run(() async {
      await repository.deleteUser(user.id);
      if (users.length == 1 && page > 1) page--;
    });
    if (!succeeded) page = previousPage;
    if (succeeded && page != previousPage) await load();
  }
}

class UsersPage extends StatelessWidget {
  const UsersPage({super.key});
  @override
  Widget build(BuildContext context) => ChangeNotifierProvider(
    create: (context) =>
        UsersViewModel(context.read<MoneydayRepository>())..load(),
    child: const _UsersView(),
  );
}

class _UsersView extends StatefulWidget {
  const _UsersView();
  @override
  State<_UsersView> createState() => _UsersViewState();
}

class _UsersViewState extends State<_UsersView> {
  final keyword = TextEditingController();
  @override
  void dispose() {
    keyword.dispose();
    super.dispose();
  }

  Future<void> passwordDialog(UsersViewModel vm, [UserProfile? user]) async {
    final username = TextEditingController();
    final password = TextEditingController();
    await showFormDialog(
      context,
      title: user == null ? '创建普通用户' : '重置密码 · ${user.username}',
      description: user == null
          ? '用户名不区分大小写，创建后不可修改。初次登录必须修改密码。'
          : '重置后该用户立即退出所有设备，下次登录必须修改密码。',
      builder: (context, setState) => PlanningFields(
        children: [
          if (user == null)
            TextFormField(
              controller: username,
              maxLength: 50,
              decoration: const InputDecoration(labelText: '用户名'),
              validator: usernameError,
              autofillHints: const [AutofillHints.newUsername],
              autocorrect: false,
            ),
          TextFormField(
            controller: password,
            obscureText: true,
            autocorrect: false,
            enableSuggestions: false,
            decoration: InputDecoration(
              labelText: user == null ? '初始密码' : '临时密码',
              helperText: '至少 8 个 Unicode 字符，UTF-8 不超过 72 字节',
            ),
            autofillHints: const [AutofillHints.newPassword],
            validator: (value) => passwordError(value ?? ''),
          ),
        ],
      ),
      onSubmit: () async {
        if (user == null) {
          await vm.repository.createUser(username.text.trim(), password.text);
        } else {
          await vm.repository.resetUserPassword(user.id, password.text);
        }
      },
    );
    username.dispose();
    password.dispose();
  }

  Widget actions(UsersViewModel vm, UserProfile user) => Wrap(
    children: [
      TextButton(
        onPressed: vm.saving
            ? null
            : () async {
                final active = user.status == 'ACTIVE';
                if (await confirmAction(
                  context,
                  active ? '停用用户' : '启用用户',
                  active
                      ? '停用后「${user.username}」将立即退出所有设备。'
                      : '重新启用「${user.username}」？',
                  destructive: active,
                )) {
                  await vm.run(
                    () => vm.repository.updateUserStatus(
                      user.id,
                      active ? 'DISABLED' : 'ACTIVE',
                    ),
                  );
                }
              },
        child: Text(user.status == 'ACTIVE' ? '停用' : '启用'),
      ),
      TextButton(
        onPressed: vm.saving ? null : () => passwordDialog(vm, user),
        child: const Text('重置密码'),
      ),
      TextButton(
        onPressed: vm.saving
            ? null
            : () async {
                if (await confirmAction(
                  context,
                  '删除用户',
                  '删除「${user.username}」后无法恢复，用户名继续占用，财务数据保留。',
                  destructive: true,
                )) {
                  await vm.remove(user);
                }
              },
        child: const Text('删除'),
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<UsersViewModel>();
    return AsyncPage(
      model: vm,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            PageHeader(
              title: '用户管理',
              subtitle: '管理员仅管理普通用户，无法查看其他用户账本。删除后财务数据保留，用户无法恢复。',
              actions: [
                FilledButton.icon(
                  onPressed: vm.saving ? null : () => passwordDialog(vm),
                  icon: const Icon(Icons.person_add_outlined),
                  label: const Text('创建用户'),
                ),
              ],
            ),
            LayoutBuilder(
              builder: (context, constraints) {
                final fields = [
                  TextField(
                    controller: keyword,
                    decoration: InputDecoration(
                      labelText: '搜索用户名',
                      suffixIcon: IconButton(
                        tooltip: '搜索',
                        onPressed: () => vm.search(keyword.text, vm.status),
                        icon: const Icon(Icons.search),
                      ),
                    ),
                    onSubmitted: (value) => vm.search(value, vm.status),
                  ),
                  DropdownButtonFormField<String>(
                    initialValue: vm.status ?? 'ALL',
                    decoration: const InputDecoration(labelText: '用户状态'),
                    items: const [
                      DropdownMenuItem(value: 'ALL', child: Text('全部状态')),
                      DropdownMenuItem(value: 'ACTIVE', child: Text('已启用')),
                      DropdownMenuItem(value: 'DISABLED', child: Text('已停用')),
                    ],
                    onChanged: (v) =>
                        vm.search(keyword.text, v == 'ALL' ? null : v),
                  ),
                ];
                return constraints.maxWidth < 600
                    ? PlanningFields(children: fields)
                    : Row(
                        children: [
                          Expanded(child: fields[0]),
                          const SizedBox(width: 16),
                          SizedBox(width: 180, child: fields[1]),
                        ],
                      );
              },
            ),
            const SizedBox(height: 16),
            PlanningRecords(
              columns: const [
                DataColumn(label: Text('用户名')),
                DataColumn(label: Text('状态')),
                DataColumn(label: Text('密码状态')),
                DataColumn(label: Text('创建时间')),
                DataColumn(label: Text('操作')),
              ],
              rows: vm.users
                  .map(
                    (user) => DataRow(
                      cells: [
                        DataCell(Text(user.username)),
                        DataCell(Text(user.status == 'ACTIVE' ? '已启用' : '已停用')),
                        DataCell(
                          Text(user.mustChangePassword ? '待修改密码' : '已设置'),
                        ),
                        DataCell(
                          Text(user.createdAt?.replaceFirst('T', ' ') ?? '—'),
                        ),
                        DataCell(actions(vm, user)),
                      ],
                    ),
                  )
                  .toList(),
              cards: vm.users
                  .map(
                    (user) => Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user.username,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            Text(
                              '${user.status == 'ACTIVE' ? '已启用' : '已停用'} · ${user.mustChangePassword ? '待修改密码' : '密码已设置'}',
                            ),
                            Text(user.createdAt?.replaceFirst('T', ' ') ?? '—'),
                            actions(vm, user),
                          ],
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
            Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 8,
              children: [
                Text('共 ${vm.total} 位用户 · 第 ${vm.page} 页'),
                IconButton(
                  tooltip: '上一页',
                  onPressed: vm.page <= 1 || vm.loading
                      ? null
                      : () => vm.changePage(vm.page - 1),
                  icon: const Icon(Icons.chevron_left),
                ),
                IconButton(
                  tooltip: '下一页',
                  onPressed: vm.page * vm.pageSize >= vm.total || vm.loading
                      ? null
                      : () => vm.changePage(vm.page + 1),
                  icon: const Icon(Icons.chevron_right),
                ),
                DropdownButton<int>(
                  value: vm.pageSize,
                  items: const [
                    DropdownMenuItem(value: 10, child: Text('10 / 页')),
                    DropdownMenuItem(value: 20, child: Text('20 / 页')),
                    DropdownMenuItem(value: 50, child: Text('50 / 页')),
                  ],
                  onChanged: vm.loading
                      ? null
                      : (value) {
                          vm.pageSize = value!;
                          vm.changePage(1);
                        },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
