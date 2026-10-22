import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:moneyday/data/models/models.dart';
import 'package:moneyday/data/repositories/moneyday_repository.dart';
import 'package:moneyday/data/services/api_client.dart'
    show StaleSessionException;
import 'package:moneyday/ui/core/feature_view_model.dart';
import 'package:moneyday/ui/core/widgets.dart';
import 'goals_page.dart';
import 'planning_widgets.dart';

String todoTypeLabel(String type) => switch (type) {
  'LIABILITY_OVERDUE' => '分期扣款失败',
  'CYCLE_FIXED_ITEMS' => '新周期账单提醒',
  'WISHLIST_REACHED' => '心愿达成',
  _ => '待办事项',
};

class TodosViewModel extends FeatureViewModel {
  TodosViewModel(super.repository);
  String status = 'PENDING';
  int pendingCount = 0;
  List<TodoItem> todos = [];
  List<Account> accounts = [];
  List<Goal> wishes = [];
  num cumulativeBalance = 0;
  int _query = 0;
  @override
  Future<void> fetch() async {
    final generation = repository.sessionGeneration;
    final query = ++_query;
    final data = await Future.wait<Object>([
      repository.todos(status: status),
      repository.pendingCount(),
      repository.accounts(),
      repository.goals(wishlist: true),
      repository.stats(),
    ]);
    if (generation != repository.sessionGeneration) {
      throw const StaleSessionException();
    }
    if (query != _query) return;
    todos = data[0] as List<TodoItem>;
    pendingCount = data[1] as int;
    accounts = data[2] as List<Account>;
    wishes = data[3] as List<Goal>;
    cumulativeBalance = (data[4] as Stats).cumulativeBalance;
  }

  Future<void> filter(String value) async {
    status = value;
    await load();
  }
}

class TodosPage extends StatelessWidget {
  const TodosPage({super.key});
  @override
  Widget build(BuildContext context) => ChangeNotifierProvider(
    create: (context) =>
        TodosViewModel(context.read<MoneydayRepository>())..load(),
    child: const _TodosView(),
  );
}

class _TodosView extends StatelessWidget {
  const _TodosView();
  Future<void> process(
    BuildContext context,
    TodosViewModel vm,
    TodoItem todo,
  ) async {
    final retry = todo.type == 'LIABILITY_OVERDUE';
    final goal = vm.wishes
        .where((g) => g.id == int.tryParse(todo.bizId))
        .firstOrNull;
    int? accountId = vm.accounts.firstOrNull?.id;
    await showFormDialog(
      context,
      title: retry ? '分期还款补扣' : '兑现心愿',
      description: '${todo.title}\n${todo.content}',
      builder: (context, setState) => PlanningFields(
        children: [
          if (!retry && goal != null) Text('心愿金额 ${money(goal.targetAmount)}'),
          if (!retry &&
              goal != null &&
              vm.cumulativeBalance < goal.targetAmount)
            Text(
              '累计结余不足，兑现可能动用储蓄。',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          PlanningAccountField(
            accounts: vm.accounts,
            value: accountId,
            onChanged: (v) => setState(() => accountId = v),
          ),
          Text(
            retry ? '指定有充足余额的账户补扣；服务器成功后自动核销待办。' : '将生成真实支出流水，服务器成功后自动核销待办。',
          ),
        ],
      ),
      onSubmit: () async {
        if (accountId == null) throw Exception('请选择扣款账户');
        if (retry) {
          await vm.repository.retryRepay(todo.id, accountId: accountId);
        } else {
          if (goal == null) throw Exception('心愿不存在或状态已更新，请关闭后刷新核对');
          final account = vm.accounts.firstWhere((a) => a.id == accountId);
          final blocked = goalRealizationBlock(
            wishlist: true,
            availableAssets: 0,
            targetAmount: goal.targetAmount,
            accountBalance: account.currentBalance,
          );
          if (blocked != null) throw Exception(blocked);
          if (vm.cumulativeBalance < goal.targetAmount) {
            if (!await confirmAction(
              context,
              '确认超支兑现',
              '累计结余不足，仍扣款 ${money(goal.targetAmount)} 兑现「${goal.name}」？',
            )) {
              throw Exception('已取消超支兑现，未扣款');
            }
          }
          await vm.repository.realizeGoal(goal.id, accountId!, wishlist: true);
        }
      },
    );
  }

  Widget actions(BuildContext context, TodosViewModel vm, TodoItem todo) {
    if (todo.status != 'PENDING') {
      return Text(todo.status == 'RESOLVED' ? '已完成' : '已忽略');
    }
    return Wrap(
      spacing: 4,
      children: [
        if (todo.type == 'CYCLE_FIXED_ITEMS') ...[
          TextButton(
            onPressed: vm.saving ? null : () => context.go('/budget'),
            child: const Text('前往预算核对'),
          ),
          TextButton(
            onPressed: vm.saving
                ? null
                : () => vm.run(() => vm.repository.resolveTodo(todo.id)),
            child: const Text('标记已核对'),
          ),
        ] else if (todo.type == 'LIABILITY_OVERDUE' ||
            todo.type == 'WISHLIST_REACHED')
          TextButton(
            onPressed: vm.saving ? null : () => process(context, vm, todo),
            child: Text(todo.type == 'LIABILITY_OVERDUE' ? '立即补扣' : '立即兑现'),
          )
        else
          TextButton(
            onPressed: vm.saving
                ? null
                : () => vm.run(() => vm.repository.resolveTodo(todo.id)),
            child: const Text('标记完成'),
          ),
        TextButton(
          onPressed: vm.saving
              ? null
              : () async {
                  if (await confirmAction(
                    context,
                    '忽略待办',
                    '忽略这条提醒？忽略不会执行扣款或兑现。',
                  )) {
                    await vm.run(() => vm.repository.dismissTodo(todo.id));
                  }
                },
          child: Text(todo.type == 'WISHLIST_REACHED' ? '暂不兑现' : '忽略'),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<TodosViewModel>();
    return AsyncPage(
      model: vm,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            PageHeader(title: '待办中心', subtitle: '待处理 ${vm.pendingCount} 项'),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final entry in const {
                  'PENDING': '待处理',
                  'RESOLVED': '已完成',
                  'DISMISSED': '已忽略',
                  'ALL': '全部',
                }.entries)
                  ChoiceChip(
                    label: Text(entry.value),
                    selected: vm.status == entry.key,
                    onSelected: (_) => vm.filter(entry.key),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            PlanningRecords(
              columns: const [
                DataColumn(label: Text('类型 / 状态')),
                DataColumn(label: Text('待办内容')),
                DataColumn(label: Text('发生时间')),
                DataColumn(label: Text('操作')),
              ],
              rows: vm.todos
                  .map(
                    (todo) => DataRow(
                      cells: [
                        DataCell(
                          Text(
                            '${todoTypeLabel(todo.type)}\n${todo.status == 'PENDING'
                                ? '待处理'
                                : todo.status == 'RESOLVED'
                                ? '已完成'
                                : '已忽略'}',
                          ),
                        ),
                        DataCell(
                          SizedBox(
                            width: 300,
                            child: Text(
                              '${todo.title}\n${todo.content}',
                              maxLines: 5,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                        DataCell(
                          Text(todo.createdAt?.replaceFirst('T', ' ') ?? '—'),
                        ),
                        DataCell(actions(context, vm, todo)),
                      ],
                    ),
                  )
                  .toList(),
              cards: vm.todos
                  .map(
                    (todo) => Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              todoTypeLabel(todo.type),
                              style: Theme.of(context).textTheme.labelLarge,
                            ),
                            Text(
                              todo.title,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            Text(todo.content),
                            Text(todo.createdAt?.replaceFirst('T', ' ') ?? '—'),
                            actions(context, vm, todo),
                          ],
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}
