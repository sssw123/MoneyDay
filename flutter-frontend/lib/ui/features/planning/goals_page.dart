import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:moneyday/data/models/models.dart';
import 'package:moneyday/data/repositories/moneyday_repository.dart';
import 'package:moneyday/data/services/api_client.dart'
    show StaleSessionException;
import 'package:moneyday/ui/core/feature_view_model.dart';
import 'package:moneyday/ui/core/widgets.dart';
import 'planning_widgets.dart';

String? goalRealizationBlock({
  required bool wishlist,
  required num availableAssets,
  required num targetAmount,
  required num accountBalance,
}) {
  if (!wishlist && availableAssets < targetAmount) return '可用净资产不足，无法实现此目标';
  if (accountBalance < targetAmount) return '扣款账户余额不足，请选择其他账户';
  return null;
}

class GoalsViewModel extends FeatureViewModel {
  GoalsViewModel(super.repository, {required this.wishlist});
  final bool wishlist;
  List<Goal> goals = [];
  List<Account> accounts = [];
  num availableAssets = 0;
  num cumulativeBalance = 0;
  @override
  Future<void> fetch() async {
    final generation = repository.sessionGeneration;
    final results = await Future.wait<Object>([
      repository.goals(wishlist: wishlist),
      repository.accounts(),
      repository.stats(),
    ]);
    if (generation != repository.sessionGeneration) {
      throw const StaleSessionException();
    }
    final stats = results[2] as Stats;
    goals = results[0] as List<Goal>;
    accounts = results[1] as List<Account>;
    availableAssets = stats.availableAssets;
    cumulativeBalance = stats.cumulativeBalance;
  }
}

class GoalsPage extends StatelessWidget {
  const GoalsPage({super.key, required this.wishlist});
  final bool wishlist;
  @override
  Widget build(BuildContext context) => ChangeNotifierProvider(
    key: ValueKey(wishlist),
    create: (context) =>
        GoalsViewModel(context.read<MoneydayRepository>(), wishlist: wishlist)
          ..load(),
    child: const _GoalsView(),
  );
}

class _GoalsView extends StatelessWidget {
  const _GoalsView();
  Future<void> edit(
    BuildContext context,
    GoalsViewModel vm, [
    Goal? goal,
  ]) async {
    final name = TextEditingController(text: goal?.name ?? '');
    final amount = TextEditingController(
      text: goal?.targetAmount.toString() ?? '',
    );
    final start = TextEditingController(
      text: goal?.startDate ?? dateOnly(DateTime.now()),
    );
    final deadline = TextEditingController(text: goal?.deadline ?? '');
    await showFormDialog(
      context,
      title: '${goal == null ? '新增' : '编辑'}${vm.wishlist ? '心愿' : '目标'}',
      builder: (context, setState) => PlanningFields(
        children: [
          TextFormField(
            controller: name,
            decoration: const InputDecoration(labelText: '名称'),
            validator: requiredText,
          ),
          TextFormField(
            controller: amount,
            decoration: const InputDecoration(labelText: '目标金额'),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            validator: positiveAmount,
          ),
          PlanningDateField(controller: start, label: '立项时间'),
          PlanningDateField(
            controller: deadline,
            label: '期望日期（可选）',
            required: false,
          ),
        ],
      ),
      onSubmit: () => vm.repository.saveGoal(
        {
          'name': name.text.trim(),
          'targetAmount': parseAmount(amount.text),
          'startDate': start.text,
          'deadline': deadline.text.isEmpty ? null : deadline.text,
          if (!vm.wishlist) 'type': 'LONG_TERM',
        },
        id: goal?.id,
        wishlist: vm.wishlist,
      ),
    );
    name.dispose();
    amount.dispose();
    start.dispose();
    deadline.dispose();
  }

  Future<void> realize(
    BuildContext context,
    GoalsViewModel vm,
    Goal goal,
  ) async {
    int? accountId = vm.accounts.firstOrNull?.id;
    await showFormDialog(
      context,
      title: vm.wishlist ? '兑现心愿' : '实现目标',
      description: '将生成真实支出流水，分类为「目标」。资金状态最终由服务器校验。',
      builder: (context, setState) => PlanningFields(
        children: [
          Text('${goal.name} · ${money(goal.targetAmount)}'),
          if (vm.wishlist && vm.cumulativeBalance < goal.targetAmount)
            Text(
              '累计结余 ${money(vm.cumulativeBalance)} 不足，兑现将动用储蓄或导致结余超支。',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          PlanningAccountField(
            accounts: vm.accounts,
            value: accountId,
            onChanged: (v) => setState(() => accountId = v),
          ),
        ],
      ),
      onSubmit: () async {
        final account = vm.accounts.where((a) => a.id == accountId).firstOrNull;
        if (account == null) throw Exception('请选择扣款账户');
        final blocked = goalRealizationBlock(
          wishlist: vm.wishlist,
          availableAssets: vm.availableAssets,
          targetAmount: goal.targetAmount,
          accountBalance: account.currentBalance,
        );
        if (blocked != null) throw Exception(blocked);
        if (vm.wishlist && vm.cumulativeBalance < goal.targetAmount) {
          final agreed = await confirmAction(
            context,
            '确认超支兑现',
            '累计结余不足，仍兑现「${goal.name}」并扣款 ${money(goal.targetAmount)}？',
          );
          if (!agreed) throw Exception('已取消超支兑现，未扣款');
        }
        await vm.repository.realizeGoal(
          goal.id,
          account.id,
          wishlist: vm.wishlist,
        );
      },
    );
  }

  Widget actions(BuildContext context, GoalsViewModel vm, Goal goal) => Wrap(
    spacing: 4,
    children: [
      if (goal.isRealized == 0)
        TextButton(
          onPressed:
              vm.saving ||
                  (!vm.wishlist && vm.availableAssets < goal.targetAmount)
              ? null
              : () => realize(context, vm, goal),
          child: Text(vm.wishlist ? '兑现' : '实现目标'),
        )
      else
        TextButton(
          onPressed: vm.saving
              ? null
              : () async {
                  if (await confirmAction(
                    context,
                    '撤销实现',
                    '对应扣款流水将被删除，资金退回原账户。',
                  )) {
                    await vm.run(
                      () => vm.repository.unrealizeGoal(
                        goal.id,
                        wishlist: vm.wishlist,
                      ),
                    );
                  }
                },
          child: const Text('撤销'),
        ),
      TextButton(
        onPressed: vm.saving ? null : () => edit(context, vm, goal),
        child: const Text('编辑'),
      ),
      TextButton(
        onPressed: vm.saving
            ? null
            : () async {
                if (await confirmAction(
                  context,
                  '删除${vm.wishlist ? '心愿' : '目标'}',
                  '删除「${goal.name}」？历史流水继续保留。如需退回资金，请先撤销实现。',
                  destructive: true,
                )) {
                  await vm.run(
                    () => vm.repository.deleteGoal(
                      goal.id,
                      wishlist: vm.wishlist,
                    ),
                  );
                }
              },
        child: const Text('删除'),
      ),
    ],
  );

  Widget estimate(Goal goal) => Tooltip(
    message: goal.estimatedReason ?? '暂无估算说明',
    child: Text(
      '${goal.estimatedCompletionDate ?? '无法预估'}${goal.isEstimatedFallback ? '（模板估算）' : ''}',
    ),
  );

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<GoalsViewModel>();
    return AsyncPage(
      model: vm,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            PlanningNavigation(
              selected: vm.wishlist ? '/plan/wishlist' : '/plan/targets',
            ),
            PageHeader(
              title: vm.wishlist ? '心愿单' : '长期目标',
              subtitle: vm.wishlist
                  ? '累计结余 ${money(vm.cumulativeBalance)} · 心愿不占预留资金'
                  : '可用净资产 ${money(vm.availableAssets)} · 总资产减待还负债',
              actions: [
                FilledButton.icon(
                  onPressed: vm.saving ? null : () => edit(context, vm),
                  icon: const Icon(Icons.add),
                  label: const Text('新增'),
                ),
              ],
            ),
            PlanningRecords(
              columns: const [
                DataColumn(label: Text('名称 / 状态')),
                DataColumn(label: Text('金额'), numeric: true),
                DataColumn(label: Text('进度')),
                DataColumn(label: Text('立项 / 期望日期')),
                DataColumn(label: Text('预计实现')),
                DataColumn(label: Text('操作')),
              ],
              rows: vm.goals
                  .map(
                    (goal) => DataRow(
                      cells: [
                        DataCell(
                          Text(
                            '${goal.name}\n${goal.isRealized == 1 ? '已实现' : '进行中'}',
                          ),
                        ),
                        DataCell(Text(money(goal.targetAmount))),
                        DataCell(
                          Text('${goal.progress}% · 缺口 ${money(goal.gap)}'),
                        ),
                        DataCell(
                          Text(
                            '${goal.startDate ?? '—'}\n${goal.deadline ?? '—'}',
                          ),
                        ),
                        DataCell(estimate(goal)),
                        DataCell(actions(context, vm, goal)),
                      ],
                    ),
                  )
                  .toList(),
              cards: vm.goals
                  .map(
                    (goal) => Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              goal.name,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            Text(
                              '${goal.isRealized == 1 ? '已实现' : '进行中'} · ${money(goal.targetAmount)}',
                            ),
                            const SizedBox(height: 8),
                            LinearProgressIndicator(
                              value: goal.progress.clamp(0, 100) / 100,
                            ),
                            Text(
                              '进度 ${goal.progress}% · 缺口 ${money(goal.gap)}',
                            ),
                            estimate(goal),
                            if (goal.estimatedReason != null)
                              Text(goal.estimatedReason!),
                            Text(
                              '立项 ${goal.startDate ?? '—'} · 期望 ${goal.deadline ?? '—'}',
                            ),
                            actions(context, vm, goal),
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
