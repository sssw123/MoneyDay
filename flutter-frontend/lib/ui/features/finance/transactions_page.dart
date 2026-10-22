import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:moneyday/data/models/models.dart';
import 'package:moneyday/data/repositories/moneyday_repository.dart';
import 'package:moneyday/ui/core/widgets.dart';

import 'finance_view_models.dart';
import 'finance_widgets.dart';

String? transferAccountError(int? accountId, int? toAccountId) =>
    accountId == null || toAccountId == null
    ? '请选择转出和转入账户'
    : accountId == toAccountId
    ? '转入账户不能与转出账户相同'
    : null;

class TransactionsPage extends StatelessWidget {
  const TransactionsPage({super.key});
  @override
  Widget build(BuildContext context) => ChangeNotifierProvider(
    create: (context) =>
        TransactionsViewModel(context.read<MoneydayRepository>())..load(),
    child: const _TransactionsView(),
  );
}

class _TransactionsView extends StatelessWidget {
  const _TransactionsView();
  Future<void> edit(
    BuildContext context,
    TransactionsViewModel model, [
    TransactionEntry? entry,
  ]) async {
    final amount = TextEditingController(text: entry?.amount.toString() ?? '');
    final date = TextEditingController(
      text: entry?.transactionDate ?? dateOnly(DateTime.now()),
    );
    final remark = TextEditingController(text: entry?.remark ?? '');
    var type = entry?.type ?? 2;
    int? accountId = entry?.accountId ?? model.accounts.firstOrNull?.id;
    int? toAccountId = entry?.toAccountId;
    int? categoryId = entry?.categoryId;
    await showFormDialog(
      context,
      title: entry == null ? '记一笔' : '编辑流水',
      description: '保存后由服务器更新账户余额。转账只改变账户间资金，不计入收入或支出。',
      builder: (context, setState) {
        final categories = model.categories
            .where(
              (category) =>
                  category.type == type &&
                  (category.isActive == 1 || category.id == entry?.categoryId),
            )
            .toList();
        return FinanceFields(
          children: [
            SegmentedButton<int>(
              segments: const [
                ButtonSegment(value: 2, label: Text('支出')),
                ButtonSegment(value: 1, label: Text('收入')),
                ButtonSegment(value: 3, label: Text('转账')),
              ],
              selected: {type},
              onSelectionChanged: (value) => setState(() {
                type = value.first;
                categoryId = null;
                toAccountId = null;
              }),
            ),
            TextFormField(
              controller: amount,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: '金额',
                prefixText: '¥ ',
              ),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              validator: financeAmountError,
            ),
            FinanceDateField(controller: date),
            FinanceAccountField(
              accounts: model.accounts,
              value: accountId,
              label: type == 3 ? '转出账户' : '账户',
              onChanged: (value) => setState(() {
                accountId = value;
                if (toAccountId == value) toAccountId = null;
              }),
            ),
            if (type == 3)
              FinanceAccountField(
                accounts: model.accounts,
                value: toAccountId,
                label: '转入账户',
                excludedId: accountId,
                onChanged: (value) => setState(() => toAccountId = value),
              )
            else
              DropdownButtonFormField<int>(
                key: ValueKey('category:$type:$categoryId'),
                initialValue:
                    categories.any((category) => category.id == categoryId)
                    ? categoryId
                    : null,
                isExpanded: true,
                decoration: const InputDecoration(labelText: '分类'),
                items: categories
                    .map(
                      (category) => DropdownMenuItem(
                        value: category.id,
                        child: Text(
                          '${category.name}${category.isActive == 1 ? '' : '（已停用）'}',
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (value) => setState(() => categoryId = value),
                validator: (value) => value == null ? '请选择分类' : null,
              ),
            if (type != 3 && categories.isEmpty)
              const Text('请先在「设置 → 收支分类」添加并启用相应分类。'),
            TextFormField(
              controller: remark,
              decoration: const InputDecoration(labelText: '备注（可选）'),
              maxLines: 2,
            ),
          ],
        );
      },
      onSubmit: () async {
        if (type == 3) {
          final error = transferAccountError(accountId, toAccountId);
          if (error != null) throw Exception(error);
        }
        await model.save({
          'type': type,
          'amount': parseAmount(amount.text),
          'transactionDate': date.text,
          'accountId': accountId, 'toAccountId': type == 3 ? toAccountId : null,
          'categoryId': type == 3 ? null : categoryId,
          'remark': remark.text.trim(),
          // A liability-linked payment must keep its business association when edited.
          if (entry?.liabilityId != null) 'liabilityId': entry!.liabilityId,
        }, id: entry?.id);
      },
    );
    amount.dispose();
    date.dispose();
    remark.dispose();
  }

  Widget actions(
    BuildContext context,
    TransactionsViewModel model,
    TransactionEntry entry,
  ) => Wrap(
    children: [
      TextButton(
        onPressed: model.saving ? null : () => edit(context, model, entry),
        child: const Text('编辑'),
      ),
      TextButton(
        onPressed: model.saving
            ? null
            : () async {
                if (await confirmAction(
                  context,
                  '删除流水',
                  '删除 ${entry.transactionDate} 的${transactionTypeName(entry.type)} ${money(entry.amount)}？服务器将恢复账户余额。',
                  destructive: true,
                )) {
                  await model.remove(entry);
                }
              },
        child: const Text('删除'),
      ),
    ],
  );
  String accountLabel(TransactionsViewModel model, TransactionEntry entry) =>
      entry.type == 3
      ? '${model.accountName(entry.accountId)} → ${model.accountName(entry.toAccountId)}'
      : model.accountName(entry.accountId);
  Widget amountText(BuildContext context, TransactionEntry entry) => Text(
    '${entry.type == 1
        ? '+'
        : entry.type == 2
        ? '−'
        : ''}${money(entry.amount)}',
    style: TextStyle(
      color: transactionColor(context, entry.type),
      fontWeight: FontWeight.w600,
    ),
  );
  @override
  Widget build(BuildContext context) {
    final model = context.watch<TransactionsViewModel>();
    return AsyncPage(
      model: model,
      child: FinanceBody(
        children: [
          PageHeader(
            title: '收支流水',
            subtitle: '每一笔小记录，都在描绘你的生活。',
            actions: [
              FilledButton.icon(
                onPressed: model.saving || model.accounts.isEmpty
                    ? null
                    : () => edit(context, model),
                icon: const Icon(Icons.add),
                label: const Text('记一笔'),
              ),
            ],
          ),
          if (model.accounts.isEmpty && !model.loading)
            Card(
              child: ListTile(
                leading: const Icon(Icons.account_balance_wallet_outlined),
                title: const Text('记账前，请先创建账户'),
                trailing: TextButton(
                  onPressed: () => context.go('/accounts'),
                  child: const Text('添加账户'),
                ),
              ),
            ),
          Wrap(
            spacing: 8,
            runSpacing: 12,
            children: [
              ChoiceChip(
                label: const Text('全部'),
                selected: model.typeFilter == null,
                onSelected: (_) => model.filter(null),
              ),
              for (final type in [2, 1, 3])
                ChoiceChip(
                  label: Text(transactionTypeName(type)),
                  selected: model.typeFilter == type,
                  onSelected: (_) => model.filter(type),
                ),
              SizedBox(
                width: 260,
                child: TextField(
                  decoration: const InputDecoration(
                    isDense: true,
                    prefixIcon: Icon(Icons.search),
                    hintText: '搜索备注、账户或日期',
                  ),
                  onChanged: model.searchFor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          FinanceTable<TransactionEntry>(
            items: model.filtered,
            emptyMessage: model.transactions.isEmpty
                ? '还没有流水，记下今天的第一笔。'
                : '没有符合筛选条件的流水。',
            columns: const [
              DataColumn(label: Text('日期')),
              DataColumn(label: Text('类型 / 分类')),
              DataColumn(label: Text('账户')),
              DataColumn(label: Text('金额'), numeric: true),
              DataColumn(label: Text('备注')),
              DataColumn(label: Text('操作')),
            ],
            row: (entry) => DataRow(
              cells: [
                DataCell(Text(entry.transactionDate)),
                DataCell(
                  Text(
                    '${transactionTypeName(entry.type)}${entry.type == 3 ? '' : ' · ${model.categoryName(entry.categoryId)}'}',
                  ),
                ),
                DataCell(Text(accountLabel(model, entry))),
                DataCell(amountText(context, entry)),
                DataCell(
                  SizedBox(
                    width: 180,
                    child: Text(
                      entry.remark ?? '—',
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                DataCell(actions(context, model, entry)),
              ],
            ),
            card: (entry) => Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            transactionTypeName(entry.type),
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ),
                        amountText(context, entry),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '${entry.transactionDate} · ${model.categoryName(entry.categoryId)}',
                    ),
                    const SizedBox(height: 6),
                    Text(accountLabel(model, entry)),
                    if (entry.remark?.isNotEmpty == true) ...[
                      const SizedBox(height: 8),
                      Text(entry.remark!),
                    ],
                    Align(
                      alignment: Alignment.centerRight,
                      child: actions(context, model, entry),
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
