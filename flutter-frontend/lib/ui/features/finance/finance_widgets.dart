import 'package:flutter/material.dart';
import 'package:moneyday/data/models/models.dart';
import 'package:moneyday/ui/core/widgets.dart';

const accountTypes = {'CASH': '现金', 'BANK': '银行卡', 'EWALLET': '电子钱包'};
String transactionTypeName(int value) => switch (value) {
  1 => '收入',
  2 => '支出',
  3 => '转账',
  _ => '未知',
};
String fixedTypeName(String value) => switch (value) {
  'INCOME' => '固收',
  'EXPENSE' => '固支',
  'DEPOSIT' => '固存',
  _ => value,
};
Color transactionColor(BuildContext context, int type) => switch (type) {
  1 => const Color(0xff387344),
  2 => Theme.of(context).colorScheme.error,
  _ => Theme.of(context).colorScheme.primary,
};

String? financeAmountError(
  String? value, {
  bool allowZero = false,
  bool allowNegative = false,
}) {
  final text = value?.trim() ?? '';
  final amount = num.tryParse(text);
  if (amount == null || !amount.isFinite) return '请输入有效金额';
  if (!allowNegative && (allowZero ? amount < 0 : amount <= 0)) {
    return allowZero ? '金额不能小于 0' : '金额必须大于 0';
  }
  if (!RegExp(r'^-?\d+(\.\d{1,2})?$').hasMatch(text)) return '金额最多保留两位小数';
  return null;
}

String? financeDateError(String? value) {
  final text = value ?? '';
  final date = DateTime.tryParse(text);
  if (!RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(text) ||
      date == null ||
      dateOnly(date) != text) {
    return '请选择有效日期';
  }
  return null;
}

class FinanceFields extends StatelessWidget {
  const FinanceFields({super.key, required this.children});
  final List<Widget> children;
  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      for (final child in children)
        Padding(padding: const EdgeInsets.only(bottom: 16), child: child),
    ],
  );
}

class FinanceDateField extends StatelessWidget {
  const FinanceDateField({
    super.key,
    required this.controller,
    this.label = '日期',
    this.firstDate,
    this.lastDate,
  });
  final TextEditingController controller;
  final String label;
  final DateTime? firstDate;
  final DateTime? lastDate;
  @override
  Widget build(BuildContext context) => TextFormField(
    controller: controller,
    readOnly: true,
    decoration: InputDecoration(
      labelText: label,
      suffixIcon: const Icon(Icons.calendar_today_outlined),
    ),
    validator: (value) {
      final error = financeDateError(value);
      if (error != null) return error;
      final date = DateTime.parse(value!);
      if ((firstDate != null && date.isBefore(firstDate!)) ||
          (lastDate != null && date.isAfter(lastDate!))) {
        return '日期必须在本周期内';
      }
      return null;
    },
    onTap: () async {
      final first = firstDate ?? DateTime(1900);
      final last = lastDate ?? DateTime(2200, 12, 31);
      var initial =
          DateTime.tryParse(controller.text) ??
          DateUtils.dateOnly(DateTime.now());
      if (initial.isBefore(first)) initial = first;
      if (initial.isAfter(last)) initial = last;
      final selected = await showDatePicker(
        context: context,
        initialDate: initial,
        firstDate: first,
        lastDate: last,
      );
      if (selected != null) controller.text = dateOnly(selected);
    },
  );
}

class FinanceAccountField extends StatelessWidget {
  const FinanceAccountField({
    super.key,
    required this.accounts,
    required this.value,
    required this.onChanged,
    this.label = '账户',
    this.excludedId,
    this.maskAmounts = false,
  });
  final List<Account> accounts;
  final int? value;
  final ValueChanged<int?> onChanged;
  final String label;
  final int? excludedId;
  final bool maskAmounts;
  @override
  Widget build(BuildContext context) => DropdownButtonFormField<int>(
    key: ValueKey('$label:$value:$excludedId'),
    initialValue:
        accounts.any(
          (account) => account.id == value && account.id != excludedId,
        )
        ? value
        : null,
    isExpanded: true,
    decoration: InputDecoration(labelText: label),
    items: accounts
        .where((account) => account.id != excludedId)
        .map(
          (account) => DropdownMenuItem(
            value: account.id,
            child: Text(
              '${account.name} · ${maskAmounts ? '••••' : money(account.currentBalance)}',
              overflow: TextOverflow.ellipsis,
            ),
          ),
        )
        .toList(),
    onChanged: onChanged,
    validator: (id) =>
        id == null ||
            !accounts.any((account) => account.id == id && id != excludedId)
        ? '请选择$label'
        : null,
  );
}

class FinanceBody extends StatelessWidget {
  const FinanceBody({super.key, required this.children});
  final List<Widget> children;
  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) => SingleChildScrollView(
      padding: EdgeInsets.all(constraints.maxWidth < 600 ? 16 : 28),
      child: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1600),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: children,
          ),
        ),
      ),
    ),
  );
}

class FinanceTable<T> extends StatelessWidget {
  const FinanceTable({
    super.key,
    required this.items,
    required this.columns,
    required this.row,
    required this.card,
    this.emptyMessage = '暂无数据',
  });
  final List<T> items;
  final List<DataColumn> columns;
  final DataRow Function(T) row;
  final Widget Function(T) card;
  final String emptyMessage;
  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return EmptyState(message: emptyMessage);
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 600) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (final item in items)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: card(item),
                ),
            ],
          );
        }
        return Card(
          clipBehavior: Clip.antiAlias,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: ConstrainedBox(
              constraints: BoxConstraints(minWidth: constraints.maxWidth - 8),
              child: DataTable(
                dataRowMinHeight: 64,
                dataRowMaxHeight: 180,
                columns: columns,
                rows: items.map(row).toList(),
              ),
            ),
          ),
        );
      },
    );
  }
}

class FinanceMetric extends StatelessWidget {
  const FinanceMetric({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    this.emphasized = false,
    this.caption,
    this.maskAmounts = false,
  });
  final String label;
  final num value;
  final IconData icon;
  final bool emphasized;
  final String? caption;
  final bool maskAmounts;
  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Card(
      color: emphasized ? colors.primaryContainer : null,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: Text(label)),
                Icon(
                  icon,
                  color: emphasized
                      ? colors.onPrimaryContainer
                      : colors.primary,
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              maskAmounts ? '••••' : money(value),
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: value < 0 ? colors.error : null,
              ),
            ),
            if (caption != null) ...[
              const SizedBox(height: 10),
              Text(caption!, style: Theme.of(context).textTheme.bodySmall),
            ],
          ],
        ),
      ),
    );
  }
}
