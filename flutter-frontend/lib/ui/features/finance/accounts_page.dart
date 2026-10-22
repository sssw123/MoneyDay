import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:moneyday/data/models/models.dart';
import 'package:moneyday/data/repositories/moneyday_repository.dart';
import 'package:moneyday/ui/core/widgets.dart';

import 'finance_view_models.dart';
import 'finance_widgets.dart';

class AccountsPage extends StatelessWidget {
  const AccountsPage({super.key});
  @override
  Widget build(BuildContext context) => ChangeNotifierProvider(
    create: (context) =>
        AccountsViewModel(context.read<MoneydayRepository>())..load(),
    child: const _AccountsView(),
  );
}

class _AccountsView extends StatelessWidget {
  const _AccountsView();
  Future<void> edit(
    BuildContext context,
    AccountsViewModel model, [
    Account? account,
  ]) async {
    final name = TextEditingController(text: account?.name ?? '');
    final balance = TextEditingController(
      text: (account?.currentBalance ?? 0).toString(),
    );
    var type = account?.type ?? 'CASH';
    await showFormDialog(
      context,
      title: account == null ? '新增账户' : '编辑账户',
      description: account == null
          ? '设置期初余额，后续记账自动更新账户余额。'
          : '直接调整当前余额；不会生成流水，请核对后保存。',
      builder: (context, setState) => FinanceFields(
        children: [
          TextFormField(
            controller: name,
            autofocus: true,
            decoration: const InputDecoration(labelText: '账户名称'),
            validator: requiredText,
          ),
          DropdownButtonFormField<String>(
            initialValue: type,
            decoration: const InputDecoration(labelText: '账户类型'),
            items: [
              ...accountTypes.entries.map(
                (entry) => DropdownMenuItem(
                  value: entry.key,
                  child: Text(entry.value),
                ),
              ),
              if (!accountTypes.containsKey(type))
                DropdownMenuItem(
                  value: type,
                  child: Text(type.isEmpty ? '其他' : type),
                ),
            ],
            onChanged: (value) => setState(() => type = value ?? type),
          ),
          TextFormField(
            controller: balance,
            decoration: InputDecoration(
              labelText: account == null ? '期初余额' : '当前余额',
              prefixText: '¥ ',
            ),
            keyboardType: const TextInputType.numberWithOptions(
              decimal: true,
              signed: true,
            ),
            validator: (value) => financeAmountError(
              value,
              allowZero: true,
              allowNegative: account != null,
            ),
          ),
        ],
      ),
      onSubmit: () => model.save({
        'name': name.text.trim(),
        'type': type,
        if (account == null) 'initialBalance': parseAmount(balance.text),
        if (account != null) 'currentBalance': parseAmount(balance.text),
      }, id: account?.id),
    );
    name.dispose();
    balance.dispose();
  }

  Widget actions(
    BuildContext context,
    AccountsViewModel model,
    Account account,
  ) => Wrap(
    children: [
      TextButton(
        onPressed: model.saving ? null : () => edit(context, model, account),
        child: const Text('编辑'),
      ),
      TextButton(
        onPressed: model.saving
            ? null
            : () async {
                if (await confirmAction(
                  context,
                  '删除账户',
                  '删除「${account.name}」？该账户将不再显示，历史流水不会自动撤销，请核对余额后确认。',
                  destructive: true,
                )) {
                  await model.remove(account);
                }
              },
        child: const Text('删除'),
      ),
    ],
  );
  @override
  Widget build(BuildContext context) {
    final model = context.watch<AccountsViewModel>();
    return AsyncPage(
      model: model,
      child: FinanceBody(
        children: [
          PageHeader(
            title: '我的账户',
            subtitle: '看清每一处余额，让资金各得其所。',
            actions: [
              FilledButton.icon(
                onPressed: model.saving ? null : () => edit(context, model),
                icon: const Icon(Icons.add),
                label: const Text('新增账户'),
              ),
            ],
          ),
          FinanceTable<Account>(
            items: model.accounts,
            emptyMessage: '还没有账户，先添加一个账户开始记账。',
            columns: const [
              DataColumn(label: Text('账户')),
              DataColumn(label: Text('类型')),
              DataColumn(label: Text('当前余额'), numeric: true),
              DataColumn(label: Text('操作')),
            ],
            row: (account) => DataRow(
              cells: [
                DataCell(Text(account.name)),
                DataCell(Text(accountTypes[account.type] ?? account.type)),
                DataCell(Text(money(account.currentBalance))),
                DataCell(actions(context, model, account)),
              ],
            ),
            card: (account) => Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          child: Icon(
                            account.type == 'CASH'
                                ? Icons.payments_outlined
                                : Icons.account_balance_wallet_outlined,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                account.name,
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              Text(accountTypes[account.type] ?? account.type),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Text(
                      money(account.currentBalance),
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerRight,
                      child: actions(context, model, account),
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
