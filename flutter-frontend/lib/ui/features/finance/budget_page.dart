import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:moneyday/data/models/models.dart';
import 'package:moneyday/data/repositories/moneyday_repository.dart';
import 'package:moneyday/ui/core/widgets.dart';

import 'finance_view_models.dart';
import 'finance_widgets.dart';

class BudgetPage extends StatelessWidget {
  const BudgetPage({super.key});
  @override
  Widget build(BuildContext context) => ChangeNotifierProvider(
    create: (context) =>
        BudgetViewModel(context.read<MoneydayRepository>())..load(),
    child: const _BudgetView(),
  );
}

class _BudgetView extends StatelessWidget {
  const _BudgetView();
  Future<void> book(
    BuildContext context,
    BudgetViewModel model,
    CycleRecord cycle,
    FixedItem item,
  ) async {
    if (item.type == 'DEPOSIT' || cycle.id <= 0 || model.saving) return;
    if (item.isBooked) {
      if (await confirmAction(
        context,
        '撤销已完成项目',
        '撤销「${item.name}」？对应记账流水会被删除，账户余额将恢复。',
        destructive: true,
      )) {
        await model.unbook(cycle, item);
      }
      return;
    }
    final today = dateOnly(DateTime.now());
    final initialDate =
        today.compareTo(cycle.cycleStartDate) >= 0 &&
            today.compareTo(cycle.cycleEndDate) <= 0
        ? today
        : cycle.cycleStartDate;
    final amount = TextEditingController(text: item.amount.toString());
    final date = TextEditingController(text: initialDate);
    int? accountId =
        model.accounts.any((account) => account.id == item.accountId)
        ? item.accountId
        : model.accounts.firstOrNull?.id;
    final income = item.type == 'INCOME';
    await showFormDialog(
      context,
      title: income ? '确认固收到账' : '确认固支扣款',
      description: '「${item.name}」将生成一笔真实${income ? '收入' : '支出'}流水，保存期间请勿重复操作。',
      builder: (context, setState) => FinanceFields(
        children: [
          TextFormField(
            controller: amount,
            decoration: InputDecoration(
              labelText: income ? '到账金额' : '支付金额',
              prefixText: '¥ ',
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            validator: financeAmountError,
          ),
          FinanceAccountField(
            accounts: model.accounts,
            value: accountId,
            label: income ? '入账账户' : '扣款账户',
            onChanged: (value) => setState(() => accountId = value),
          ),
          FinanceDateField(
            controller: date,
            label: income ? '入账日期' : '支付日期',
            firstDate: DateTime.tryParse(cycle.cycleStartDate),
            lastDate: DateTime.tryParse(cycle.cycleEndDate),
          ),
          if (model.accounts.isEmpty) const Text('请先在设置中添加账户。'),
        ],
      ),
      onSubmit: () async {
        if (accountId == null) throw Exception('请选择账户');
        await model.book(
          cycle,
          item,
          accountId: accountId!,
          amount: parseAmount(amount.text),
          date: date.text,
        );
      },
    );
    amount.dispose();
    date.dispose();
  }

  Widget fixedItems(
    BuildContext context,
    BudgetViewModel model,
    CycleRecord cycle,
  ) => cycle.fixedItems.isEmpty
      ? const Text('无固定项目')
      : Wrap(
          spacing: 8,
          runSpacing: 8,
          children: cycle.fixedItems.map((item) {
            final deposit = item.type == 'DEPOSIT';
            return ActionChip(
              avatar: Icon(
                deposit
                    ? Icons.savings_outlined
                    : item.isBooked
                    ? Icons.check_circle_outline
                    : Icons.radio_button_unchecked,
                size: 18,
              ),
              label: Text(
                '${fixedTypeName(item.type)} · ${item.name}${item.categoryName?.isNotEmpty == true ? ' · ${item.categoryName}' : ''}\n${money(item.amount)}${deposit
                    ? ' · 计划必攒'
                    : item.isBooked
                    ? ' · 已完成，点击撤销'
                    : ' · 点击${item.type == 'INCOME' ? '到账' : '支付'}'}',
              ),
              onPressed: deposit || cycle.id <= 0 || model.saving
                  ? null
                  : () => book(context, model, cycle, item),
            );
          }).toList(),
        );
  @override
  Widget build(BuildContext context) {
    final model = context.watch<BudgetViewModel>();
    return AsyncPage(
      model: model,
      child: FinanceBody(
        children: [
          PageHeader(
            title: '周期预算',
            subtitle: '按发薪节奏规划生活，为未来先存一笔。',
            actions: [
              OutlinedButton.icon(
                onPressed: () => context.go('/settings'),
                icon: const Icon(Icons.tune),
                label: const Text('编辑周期模板'),
              ),
              IconButton(
                tooltip: '刷新预算',
                onPressed: model.loading ? null : model.load,
                icon: const Icon(Icons.refresh),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.only(bottom: 20),
            child: Text('固存是周期储蓄计划，无需记账；固收和固支确认后计入真实流水。历史周期沿用当时快照。'),
          ),
          FinanceTable<CycleRecord>(
            items: model.cycles,
            emptyMessage: '暂无周期预算，请先设置默认周期模板。',
            columns: const [
              DataColumn(label: Text('周期区间')),
              DataColumn(label: Text('固定项目')),
              DataColumn(label: Text('收入'), numeric: true),
              DataColumn(label: Text('支出'), numeric: true),
              DataColumn(label: Text('结余 / 超支'), numeric: true),
            ],
            row: (cycle) => DataRow(
              cells: [
                DataCell(
                  Text('${cycle.cycleStartDate}\n至 ${cycle.cycleEndDate}'),
                ),
                DataCell(
                  SizedBox(
                    width: 440,
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: fixedItems(context, model, cycle),
                      ),
                    ),
                  ),
                ),
                DataCell(Text(money(cycle.income))),
                DataCell(Text(money(cycle.expense))),
                DataCell(
                  Text(
                    money(cycle.balance),
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: transactionColor(
                        context,
                        cycle.balance < 0 ? 2 : 1,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            card: (cycle) => Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${cycle.cycleStartDate} — ${cycle.cycleEndDate}',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    if (cycle.id <= 0)
                      const Padding(
                        padding: EdgeInsets.only(top: 8),
                        child: Text('历史周期，无固定项目快照'),
                      ),
                    const SizedBox(height: 20),
                    fixedItems(context, model, cycle),
                    const Divider(height: 32),
                    Wrap(
                      spacing: 24,
                      runSpacing: 12,
                      children: [
                        Text('收入 ${money(cycle.income)}'),
                        Text('支出 ${money(cycle.expense)}'),
                        Text(
                          '结余 ${money(cycle.balance)}',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: transactionColor(
                              context,
                              cycle.balance < 0 ? 2 : 1,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
