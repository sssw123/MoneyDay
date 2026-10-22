import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:moneyday/data/models/models.dart';
import 'package:moneyday/ui/core/widgets.dart';

class PlanningNavigation extends StatelessWidget {
  const PlanningNavigation({super.key, required this.selected});
  final String selected;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final entry in const {
          '/plan/targets': '长期目标',
          '/plan/wishlist': '心愿单',
          '/plan/liabilities': '分期负债',
        }.entries)
          ChoiceChip(
            label: Text(entry.value),
            selected: selected == entry.key,
            onSelected: (_) => context.go(entry.key),
          ),
      ],
    ),
  );
}

class PlanningDateField extends StatelessWidget {
  const PlanningDateField({
    super.key,
    required this.controller,
    required this.label,
    this.required = true,
  });
  final TextEditingController controller;
  final String label;
  final bool required;
  @override
  Widget build(BuildContext context) => TextFormField(
    controller: controller,
    decoration: InputDecoration(
      labelText: label,
      suffixIcon: IconButton(
        tooltip: '选择日期',
        icon: const Icon(Icons.calendar_month_outlined),
        onPressed: () async {
          final first = DateTime(1900);
          final last = DateTime(2200, 12, 31);
          var initial = DateTime.tryParse(controller.text) ?? DateTime.now();
          if (initial.isBefore(first)) initial = first;
          if (initial.isAfter(last)) initial = last;
          final date = await showDatePicker(
            context: context,
            initialDate: initial,
            firstDate: first,
            lastDate: last,
          );
          if (date != null && context.mounted) controller.text = dateOnly(date);
        },
      ),
    ),
    validator: (value) {
      if (!required && (value == null || value.isEmpty)) return null;
      final parsed = DateTime.tryParse(value ?? '');
      return parsed == null || dateOnly(parsed) != value
          ? '请输入有效日期 YYYY-MM-DD'
          : null;
    },
  );
}

class PlanningAccountField extends StatelessWidget {
  const PlanningAccountField({
    super.key,
    required this.accounts,
    required this.value,
    required this.onChanged,
  });
  final List<Account> accounts;
  final int? value;
  final ValueChanged<int?> onChanged;
  @override
  Widget build(BuildContext context) => DropdownButtonFormField<int>(
    initialValue: accounts.any((a) => a.id == value) ? value : null,
    isExpanded: true,
    decoration: const InputDecoration(labelText: '扣款账户'),
    items: accounts
        .map(
          (a) => DropdownMenuItem(
            value: a.id,
            child: Text(
              '${a.name} · ${money(a.currentBalance)}',
              overflow: TextOverflow.ellipsis,
            ),
          ),
        )
        .toList(),
    onChanged: onChanged,
    validator: (v) => v == null ? '请选择扣款账户' : null,
  );
}

class PlanningFields extends StatelessWidget {
  const PlanningFields({super.key, required this.children});
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

class PlanningRecords extends StatelessWidget {
  const PlanningRecords({
    super.key,
    required this.cards,
    required this.columns,
    required this.rows,
  });
  final List<Widget> cards;
  final List<DataColumn> columns;
  final List<DataRow> rows;
  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      if (rows.isEmpty) return const EmptyState();
      if (constraints.maxWidth < 600) return Column(children: cards);
      return Card(
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(columns: columns, rows: rows),
        ),
      );
    },
  );
}
