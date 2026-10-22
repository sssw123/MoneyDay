import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:moneyday/data/models/models.dart';
import 'package:moneyday/data/repositories/moneyday_repository.dart';
import 'package:moneyday/ui/core/widgets.dart';
import 'package:moneyday/ui/features/planning/goals_page.dart'
    show goalRealizationBlock;

import 'finance_view_models.dart';
import 'finance_widgets.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});
  @override
  Widget build(BuildContext context) => ChangeNotifierProvider(
    create: (context) =>
        DashboardViewModel(context.read<MoneydayRepository>())..load(),
    child: const _DashboardView(),
  );
}

class _DashboardView extends StatelessWidget {
  const _DashboardView();
  String amount(DashboardViewModel model, num value) =>
      model.amountsVisible ? money(value) : '••••';
  // Presentation of existing snapshots only; the server remains the ledger owner.
  num cycleDeposit(CycleRecord cycle) => cycle.fixedItems
      .where((item) => item.type == 'DEPOSIT')
      .fold<num>(0, (total, item) => total + item.amount);
  Future<void> realize(
    BuildContext context,
    DashboardViewModel model,
    Goal goal,
    bool wishlist,
  ) async {
    int? accountId = model.accounts.firstOrNull?.id;
    final stats = model.stats;
    if (stats == null) return;
    await showFormDialog(
      context,
      title: wishlist ? '兑现心愿' : '实现目标',
      description: '服务器将生成真实支出并扣减账户余额。',
      builder: (context, setState) => FinanceFields(
        children: [
          Text(
            '${goal.name} · ${amount(model, goal.targetAmount)}',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          if (wishlist && stats.cumulativeBalance < goal.targetAmount)
            Text(
              '累计结余 ${amount(model, stats.cumulativeBalance)} 不足，兑现会动用储蓄或造成超支。',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          FinanceAccountField(
            accounts: model.accounts,
            value: accountId,
            label: '扣款账户',
            maskAmounts: !model.amountsVisible,
            onChanged: (value) => setState(() => accountId = value),
          ),
        ],
      ),
      onSubmit: () async {
        final account = model.accounts
            .where((account) => account.id == accountId)
            .firstOrNull;
        if (account == null) throw Exception('请选择扣款账户');
        final blocked = goalRealizationBlock(
          wishlist: wishlist,
          availableAssets: stats.availableAssets,
          targetAmount: goal.targetAmount,
          accountBalance: account.currentBalance,
        );
        if (blocked != null) throw Exception(blocked);
        if (wishlist && stats.cumulativeBalance < goal.targetAmount) {
          if (!await confirmAction(
            context,
            '确认超支兑现',
            '累计结余不足，仍兑现「${goal.name}」并扣款 ${amount(model, goal.targetAmount)}？',
          )) {
            throw Exception('已取消兑现，未扣款');
          }
        }
        await model.realize(goal, account.id, wishlist: wishlist);
      },
    );
  }

  Widget goalActions(
    BuildContext context,
    DashboardViewModel model,
    Goal goal,
    bool wishlist,
  ) {
    if (goal.isRealized == 1) {
      return TextButton(
        onPressed: model.saving
            ? null
            : () async {
                if (await confirmAction(
                  context,
                  '撤销${wishlist ? '兑现' : '实现'}',
                  '对应扣款流水将被删除，资金退回原账户。',
                )) {
                  await model.unrealize(goal, wishlist: wishlist);
                }
              },
        child: const Text('已实现 · 撤销'),
      );
    }
    final blocked =
        !wishlist && (model.stats?.availableAssets ?? 0) < goal.targetAmount;
    return Tooltip(
      message: blocked ? '可用净资产不足，还差 ${amount(model, goal.gap)}' : '选择扣款账户后确认',
      child: FilledButton.tonal(
        onPressed: blocked || model.saving
            ? null
            : () => realize(context, model, goal, wishlist),
        child: Text(wishlist ? '兑现心愿' : '实现目标'),
      ),
    );
  }

  Widget goals(
    BuildContext context,
    DashboardViewModel model, {
    required bool wishlist,
  }) {
    final items = wishlist ? model.wishlists : model.targets;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PageHeader(
          title: wishlist ? '心愿单快捷兑现' : '目标快捷实现',
          actions: [
            TextButton(
              onPressed: () =>
                  context.go(wishlist ? '/plan/wishlist' : '/plan/targets'),
              child: const Text('查看全部'),
            ),
          ],
        ),
        FinanceTable<Goal>(
          items: items,
          emptyMessage: wishlist ? '写下一个心愿，让日常结余有所期待。' : '添加一个长期目标，让积累有方向。',
          columns: const [
            DataColumn(label: Text('名称')),
            DataColumn(label: Text('金额'), numeric: true),
            DataColumn(label: Text('进度 / 预计时间')),
            DataColumn(label: Text('操作')),
          ],
          row: (goal) => DataRow(
            cells: [
              DataCell(Text(goal.name)),
              DataCell(Text(amount(model, goal.targetAmount))),
              DataCell(
                SizedBox(width: 170, child: progress(context, model, goal)),
              ),
              DataCell(goalActions(context, model, goal, wishlist)),
            ],
          ),
          card: (goal) => Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    goal.name,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(amount(model, goal.targetAmount)),
                  const SizedBox(height: 16),
                  progress(context, model, goal),
                  const SizedBox(height: 16),
                  goalActions(context, model, goal, wishlist),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget progress(BuildContext context, DashboardViewModel model, Goal goal) =>
      Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: LinearProgressIndicator(
                  value: (goal.progress / 100).clamp(0.0, 1.0),
                ),
              ),
              const SizedBox(width: 10),
              Text('${goal.progress}%'),
            ],
          ),
          const SizedBox(height: 8),
          Tooltip(
            message: model.amountsVisible ? goal.estimatedReason ?? '' : '',
            child: Text(
              goal.isRealized == 1
                  ? '已实现'
                  : goal.estimatedCompletionDate ?? '无法预估',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ],
      );
  Widget chart(BuildContext context, DashboardViewModel model, Stats stats) {
    final expenses = stats.categoryExpenses
        .where((category) => category.value > 0)
        .toList();
    const palette = [
      Color(0xff477b55),
      Color(0xff93b881),
      Color(0xffbfa36e),
      Color(0xff759bb2),
      Color(0xffae8bab),
      Color(0xffbad0aa),
    ];
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('本周期 · 分类支出', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 20),
            if (expenses.isEmpty)
              const SizedBox(
                height: 260,
                child: EmptyState(message: '本周期还没有分类支出，记下第一笔后再来看看。'),
              )
            else ...[
              Semantics(
                label: '本周期分类支出环形图，具体金额见下方分类列表',
                child: SizedBox(
                  height: 240,
                  child: PieChart(
                    PieChartData(
                      centerSpaceRadius: 65,
                      sectionsSpace: 4,
                      sections: [
                        for (var index = 0; index < expenses.length; index++)
                          PieChartSectionData(
                            value: expenses[index].value.toDouble(),
                            color: palette[index % palette.length],
                            radius: 44,
                            showTitle: false,
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              for (var index = 0; index < expenses.length; index++)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: palette[index % palette.length],
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(child: Text(expenses[index].name)),
                      Text(amount(model, expenses[index].value)),
                    ],
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }

  Widget history(BuildContext context, DashboardViewModel model) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      PageHeader(
        title: '周期结余透视',
        actions: [
          TextButton(
            onPressed: () => context.go('/budget'),
            child: const Text('查看预算'),
          ),
        ],
      ),
      FinanceTable<CycleRecord>(
        items: model.cycles,
        emptyMessage: '暂无周期记录。',
        columns: const [
          DataColumn(label: Text('周期')),
          DataColumn(label: Text('收入'), numeric: true),
          DataColumn(label: Text('支出'), numeric: true),
          DataColumn(label: Text('固存'), numeric: true),
          DataColumn(label: Text('结余 / 超支'), numeric: true),
          DataColumn(label: Text('最终结余'), numeric: true),
        ],
        row: (cycle) => DataRow(
          cells: [
            DataCell(Text('${cycle.cycleStartDate}\n${cycle.cycleEndDate}')),
            DataCell(Text(amount(model, cycle.income))),
            DataCell(Text(amount(model, cycle.expense))),
            DataCell(Text(amount(model, cycleDeposit(cycle)))),
            DataCell(
              Text(
                amount(model, cycle.balance),
                style: TextStyle(
                  color: transactionColor(context, cycle.balance < 0 ? 2 : 1),
                ),
              ),
            ),
            DataCell(Text(amount(model, cycle.balance + cycleDeposit(cycle)))),
          ],
        ),
        card: (cycle) => Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${cycle.cycleStartDate} — ${cycle.cycleEndDate}'),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 20,
                  runSpacing: 8,
                  children: [
                    Text('收入 ${amount(model, cycle.income)}'),
                    Text('支出 ${amount(model, cycle.expense)}'),
                    Text('固存 ${amount(model, cycleDeposit(cycle))}'),
                    Text('结余 ${amount(model, cycle.balance)}'),
                    Text(
                      '最终结余 ${amount(model, cycle.balance + cycleDeposit(cycle))}',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    ],
  );
  Widget grid(List<Widget> children) => LayoutBuilder(
    builder: (context, constraints) {
      final columns = constraints.maxWidth >= 1200
          ? 3
          : constraints.maxWidth >= 600
          ? 2
          : 1;
      final width = (constraints.maxWidth - 16 * (columns - 1)) / columns;
      return Wrap(
        spacing: 16,
        runSpacing: 16,
        children: children
            .map((child) => SizedBox(width: width, child: child))
            .toList(),
      );
    },
  );
  Widget liabilities(BuildContext context, DashboardViewModel model) {
    final active = model.liabilities
        .where((liability) => liability.status == 'REPAYING')
        .toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PageHeader(
          title: '待还分期 · ${active.length} 笔',
          subtitle: '留意下一次还款安排，自动扣款由服务器执行。',
          actions: [
            TextButton(
              onPressed: () => context.go('/plan/liabilities'),
              child: const Text('查看全部分期'),
            ),
          ],
        ),
        if (active.isEmpty)
          const EmptyState(message: '暂无待还分期。')
        else
          grid(
            active
                .take(3)
                .map(
                  (liability) => Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            liability.name,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 12),
                          Text('${amount(model, liability.periodAmount)} / 期'),
                          const SizedBox(height: 16),
                          LinearProgressIndicator(
                            value:
                                liability.progressPercent.clamp(0, 100) / 100,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            '已还 ${liability.currentPeriod}/${liability.totalPeriods} 期',
                          ),
                          Text('下期 ${liability.nextRepaymentDate ?? '待排期'}'),
                        ],
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final model = context.watch<DashboardViewModel>();
    final stats = model.stats;
    return AsyncPage(
      model: model,
      child: FinanceBody(
        children: [
          PageHeader(
            title: '让积累发生。',
            subtitle: '${dateOnly(DateTime.now())} · 照顾好今天的每一笔，也离想要的生活近一点。',
            actions: [
              IconButton(
                tooltip: model.amountsVisible ? '隐藏金额' : '显示金额',
                onPressed: model.toggleAmounts,
                icon: Icon(
                  model.amountsVisible
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                ),
              ),
              FilledButton.icon(
                onPressed: () => context.go('/transactions'),
                icon: const Icon(Icons.add),
                label: const Text('记一笔'),
              ),
              IconButton(
                tooltip: '刷新看板',
                onPressed: model.loading ? null : model.load,
                icon: const Icon(Icons.refresh),
              ),
            ],
          ),
          if (stats != null) ...[
            grid([
              FinanceMetric(
                maskAmounts: !model.amountsVisible,
                label: '可用净资产',
                value: stats.availableAssets,
                icon: Icons.account_balance_wallet_outlined,
                emphasized: true,
                caption: '总资产 − 未还负债',
              ),
              FinanceMetric(
                maskAmounts: !model.amountsVisible,
                label: '总资产',
                value: stats.totalAssets,
                icon: Icons.account_balance_outlined,
                caption: '所有账户的真实余额',
              ),
              FinanceMetric(
                maskAmounts: !model.amountsVisible,
                label: '未还总负债',
                value: stats.totalLiabilities,
                icon: Icons.credit_card_outlined,
                caption: '未来需要偿还的金额',
              ),
              FinanceMetric(
                maskAmounts: !model.amountsVisible,
                label: '本期收入',
                value: stats.currentIncome,
                icon: Icons.south_west,
              ),
              FinanceMetric(
                maskAmounts: !model.amountsVisible,
                label: '本期支出',
                value: stats.currentExpense,
                icon: Icons.north_east,
              ),
              FinanceMetric(
                maskAmounts: !model.amountsVisible,
                label: '全局累计结余池',
                value: stats.cumulativeBalance,
                icon: Icons.trending_up,
                caption: '日常结余，让心愿慢慢靠近',
              ),
            ]),
            const SizedBox(height: 28),
            PageHeader(
              title: '本周期 · 财务透视',
              subtitle: '固存 + 日常结余 / 超支 = 最终结余',
              actions: [
                TextButton(
                  onPressed: () => context.go('/budget'),
                  child: const Text('查看预算'),
                ),
              ],
            ),
            grid([
              FinanceMetric(
                maskAmounts: !model.amountsVisible,
                label: '本期固存 · 计划必攒',
                value: stats.currentFixedDeposit,
                icon: Icons.savings_outlined,
              ),
              FinanceMetric(
                maskAmounts: !model.amountsVisible,
                label: '本期结余 / 超支',
                value: stats.currentBalance,
                icon: Icons.balance_outlined,
              ),
              FinanceMetric(
                maskAmounts: !model.amountsVisible,
                label: '最终结余 · 净沉淀',
                value: stats.currentFinalBalance,
                icon: Icons.task_alt,
              ),
            ]),
            if (stats.isOverdraft || stats.currentBalance < 0)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Card(
                  color: Theme.of(context).colorScheme.errorContainer,
                  child: const ListTile(
                    leading: Icon(Icons.info_outline),
                    title: Text('本期存在超支，请留意日常开销及计划资金。'),
                  ),
                ),
              ),
            const SizedBox(height: 28),
            LayoutBuilder(
              builder: (context, constraints) => constraints.maxWidth >= 1200
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(flex: 2, child: chart(context, model, stats)),
                        const SizedBox(width: 20),
                        Expanded(flex: 3, child: history(context, model)),
                      ],
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        chart(context, model, stats),
                        const SizedBox(height: 24),
                        history(context, model),
                      ],
                    ),
            ),
            const SizedBox(height: 32),
            liabilities(context, model),
            const SizedBox(height: 32),
            goals(context, model, wishlist: false),
            const SizedBox(height: 24),
            goals(context, model, wishlist: true),
          ] else if (!model.loading && model.error == null)
            const EmptyState(message: '暂无统计数据，请刷新看板。'),
        ],
      ),
    );
  }
}
