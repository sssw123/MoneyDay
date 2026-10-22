import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:moneyday/data/models/models.dart';
import 'package:moneyday/data/repositories/moneyday_repository.dart';
import 'package:moneyday/data/services/auth_controller.dart';
import 'package:moneyday/ui/core/widgets.dart';

import 'finance_view_models.dart';
import 'finance_widgets.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});
  @override
  Widget build(BuildContext context) => ChangeNotifierProvider(
    create: (context) =>
        SettingsViewModel(context.read<MoneydayRepository>())..load(),
    child: const _SettingsView(),
  );
}

class _FixedItemDraft {
  _FixedItemDraft([FixedItem? item])
    : id = item?.id,
      name = TextEditingController(text: item?.name ?? ''),
      amount = TextEditingController(text: (item?.amount ?? 0).toString()),
      type = item?.type ?? 'EXPENSE',
      categoryId = item?.categoryId;
  final String? id;
  final TextEditingController name;
  final TextEditingController amount;
  String type;
  int? categoryId;
  void dispose() {
    name.dispose();
    amount.dispose();
  }

  Map<String, Object?> toBody(List<Category> categories) => {
    if (id != null && id!.isNotEmpty) 'id': id,
    'name': name.text.trim(),
    'type': type,
    'amount': parseAmount(amount.text),
    'categoryId': type == 'DEPOSIT' ? null : categoryId,
    'categoryName': type == 'DEPOSIT'
        ? ''
        : categories
                  .where((category) => category.id == categoryId)
                  .firstOrNull
                  ?.name ??
              '',
  };
}

class _SettingsView extends StatelessWidget {
  const _SettingsView();
  Future<void> edit(
    BuildContext context,
    SettingsViewModel model, [
    CycleTemplate? template,
  ]) async {
    final name = TextEditingController(text: template?.name ?? '');
    final startDay = TextEditingController(
      text: (template?.startDay ?? 1).toString(),
    );
    final items =
        template?.fixedItems.map(_FixedItemDraft.new).toList() ??
        <_FixedItemDraft>[];
    // Removed drafts remain alive until the dialog closes, so focused fields can detach safely.
    final allDrafts = [...items];
    var isDefault = template?.isDefault == 1;
    await showFormDialog(
      context,
      title: template == null ? '新增周期模板' : '编辑周期模板',
      description: '默认模板的改动会影响当前及未来周期；已确认项目保留原入账金额，历史快照不变。',
      builder: (context, setState) => FinanceFields(
        children: [
          TextFormField(
            controller: name,
            autofocus: true,
            decoration: const InputDecoration(
              labelText: '模板名称',
              hintText: '例如：发薪日周期',
            ),
            validator: requiredText,
          ),
          TextFormField(
            controller: startDay,
            decoration: const InputDecoration(
              labelText: '每月起算日',
              helperText: '1–31；31 表示月末，短月自动取最后一天。',
            ),
            keyboardType: TextInputType.number,
            validator: (value) {
              final day = int.tryParse(value ?? '');
              return day == null || day < 1 || day > 31 ? '请输入 1–31 的整数' : null;
            },
          ),
          Text('固定项目', style: Theme.of(context).textTheme.titleMedium),
          for (final item in items)
            Card(
              key: ObjectKey(item),
              color: Theme.of(context).colorScheme.surfaceContainerLow,
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: FinanceFields(
                  children: [
                    Row(
                      children: [
                        Expanded(child: Text('项目 ${items.indexOf(item) + 1}')),
                        IconButton(
                          tooltip: '删除固定项目',
                          onPressed: () => setState(() => items.remove(item)),
                          icon: const Icon(Icons.close),
                        ),
                      ],
                    ),
                    DropdownButtonFormField<String>(
                      initialValue: item.type,
                      decoration: const InputDecoration(labelText: '项目类型'),
                      items: ['INCOME', 'EXPENSE', 'DEPOSIT']
                          .map(
                            (type) => DropdownMenuItem(
                              value: type,
                              child: Text(fixedTypeName(type)),
                            ),
                          )
                          .toList(),
                      onChanged: (value) => setState(() {
                        item.type = value ?? item.type;
                        item.categoryId = null;
                      }),
                    ),
                    TextFormField(
                      controller: item.name,
                      decoration: const InputDecoration(labelText: '项目名称'),
                      validator: requiredText,
                    ),
                    TextFormField(
                      controller: item.amount,
                      decoration: const InputDecoration(
                        labelText: '计划金额',
                        prefixText: '¥ ',
                      ),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      validator: (value) =>
                          financeAmountError(value, allowZero: true),
                    ),
                    if (item.type != 'DEPOSIT')
                      DropdownButtonFormField<int>(
                        key: ValueKey(
                          'item-category:${identityHashCode(item)}:${item.type}:${item.categoryId}',
                        ),
                        initialValue:
                            model.categories.any(
                              (category) =>
                                  category.id == item.categoryId &&
                                  category.type ==
                                      (item.type == 'INCOME' ? 1 : 2),
                            )
                            ? item.categoryId
                            : null,
                        isExpanded: true,
                        decoration: const InputDecoration(
                          labelText: '所属分类（可选）',
                        ),
                        items: [
                          const DropdownMenuItem<int>(child: Text('不指定分类')),
                          ...model.categories
                              .where(
                                (category) =>
                                    category.type ==
                                        (item.type == 'INCOME' ? 1 : 2) &&
                                    (category.isActive == 1 ||
                                        category.id == item.categoryId),
                              )
                              .map(
                                (category) => DropdownMenuItem(
                                  value: category.id,
                                  child: Text(category.name),
                                ),
                              ),
                        ],
                        onChanged: (value) =>
                            setState(() => item.categoryId = value),
                      )
                    else
                      const Text('固存作为储蓄计划，无需分类或额外扣款。'),
                  ],
                ),
              ),
            ),
          OutlinedButton.icon(
            onPressed: () => setState(() {
              final item = _FixedItemDraft();
              items.add(item);
              allDrafts.add(item);
            }),
            icon: const Icon(Icons.add),
            label: const Text('添加固定项目'),
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('设为默认模板'),
            value: isDefault,
            onChanged: (value) => setState(() => isDefault = value),
          ),
        ],
      ),
      onSubmit: () => model.save({
        'name': name.text.trim(),
        'startDay': int.parse(startDay.text),
        'isDefault': isDefault ? 1 : 0,
        'fixedItems': items
            .map((item) => item.toBody(model.categories))
            .toList(),
      }, id: template?.id),
    );
    name.dispose();
    startDay.dispose();
    for (final item in allDrafts) {
      item.dispose();
    }
  }

  Widget actions(
    BuildContext context,
    SettingsViewModel model,
    CycleTemplate template,
  ) => Wrap(
    children: [
      if (template.isDefault != 1)
        TextButton(
          onPressed: model.saving
              ? null
              : () async {
                  if (await confirmAction(
                    context,
                    '更换默认模板',
                    '将「${template.name}」设为默认？周期起算日和当前、未来周期固定项目将更新。',
                  )) {
                    await model.makeDefault(template);
                  }
                },
          child: const Text('设为默认'),
        ),
      TextButton(
        onPressed: model.saving ? null : () => edit(context, model, template),
        child: const Text('编辑'),
      ),
      TextButton(
        onPressed: model.saving
            ? null
            : () async {
                if (await confirmAction(
                  context,
                  '删除周期模板',
                  '删除「${template.name}」？已保存的历史周期快照将保留。',
                  destructive: true,
                )) {
                  await model.remove(template);
                }
              },
        child: const Text('删除'),
      ),
    ],
  );
  Widget templateItems(CycleTemplate template) => Wrap(
    spacing: 6,
    runSpacing: 6,
    children: template.fixedItems
        .map(
          (item) => Chip(
            label: Text(
              '${fixedTypeName(item.type)} · ${item.name} ${money(item.amount)}',
            ),
          ),
        )
        .toList(),
  );
  @override
  Widget build(BuildContext context) {
    final model = context.watch<SettingsViewModel>();
    final auth = context.watch<AuthController>();
    return AsyncPage(
      model: model,
      child: FinanceBody(
        children: [
          const PageHeader(title: '设置', subtitle: '用适合自己的节奏，管理账户与生活。'),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Wrap(
                spacing: 16,
                runSpacing: 12,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  const CircleAvatar(child: Icon(Icons.person_outline)),
                  Text(
                    auth.user?.username ?? '',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Chip(label: Text(auth.isAdmin ? '管理员' : '记账用户')),
                  TextButton.icon(
                    onPressed: () => context.go('/change-password'),
                    icon: const Icon(Icons.lock_outline),
                    label: const Text('修改密码'),
                  ),
                  TextButton.icon(
                    onPressed: () async {
                      if (await confirmAction(
                        context,
                        '退出登录',
                        '退出当前账户？未保存的表单内容将丢弃。',
                      )) {
                        await auth.logout();
                      }
                    },
                    icon: const Icon(Icons.logout),
                    label: const Text('退出登录'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              OutlinedButton.icon(
                onPressed: () => context.go('/accounts'),
                icon: const Icon(Icons.account_balance_wallet_outlined),
                label: const Text('账户管理'),
              ),
              OutlinedButton.icon(
                onPressed: () => context.go('/categories'),
                icon: const Icon(Icons.category_outlined),
                label: const Text('收支分类'),
              ),
              OutlinedButton.icon(
                onPressed: () => context.go('/budget'),
                icon: const Icon(Icons.calendar_view_month_outlined),
                label: const Text('周期预算'),
              ),
              if (auth.isAdmin)
                OutlinedButton.icon(
                  onPressed: () => context.go('/admin/users'),
                  icon: const Icon(Icons.manage_accounts_outlined),
                  label: const Text('用户管理'),
                ),
            ],
          ),
          const SizedBox(height: 32),
          PageHeader(
            title: '账单周期模板',
            subtitle: '设置固收、固支和固存，自动形成周期预算。',
            actions: [
              FilledButton.icon(
                onPressed: model.saving ? null : () => edit(context, model),
                icon: const Icon(Icons.add),
                label: const Text('新增模板'),
              ),
            ],
          ),
          FinanceTable<CycleTemplate>(
            items: model.templates,
            emptyMessage: '还没有周期模板，添加一个符合发薪节奏的模板。',
            columns: const [
              DataColumn(label: Text('模板')),
              DataColumn(label: Text('起算日')),
              DataColumn(label: Text('固定项目')),
              DataColumn(label: Text('操作')),
            ],
            row: (template) => DataRow(
              cells: [
                DataCell(
                  Text(
                    '${template.name}${template.isDefault == 1 ? ' · 当前默认' : ''}',
                  ),
                ),
                DataCell(
                  Text(
                    template.startDay == 31
                        ? '每月末'
                        : '每月 ${template.startDay} 号',
                  ),
                ),
                DataCell(
                  SizedBox(
                    width: 380,
                    child: SingleChildScrollView(
                      child: templateItems(template),
                    ),
                  ),
                ),
                DataCell(actions(context, model, template)),
              ],
            ),
            card: (template) => Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      template.name,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${template.startDay == 31 ? '每月末' : '每月 ${template.startDay} 号'}开始${template.isDefault == 1 ? ' · 当前默认' : ''}',
                    ),
                    const SizedBox(height: 12),
                    templateItems(template),
                    const SizedBox(height: 10),
                    actions(context, model, template),
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
