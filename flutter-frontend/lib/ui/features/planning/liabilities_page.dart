import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:moneyday/data/models/models.dart';
import 'package:moneyday/data/repositories/moneyday_repository.dart';
import 'package:moneyday/data/services/api_client.dart'
    show StaleSessionException;
import 'package:moneyday/ui/core/feature_view_model.dart';
import 'package:moneyday/ui/core/widgets.dart';
import 'planning_widgets.dart';

/// 表单试算，仅用于预填；不会更改账户或生成本地还款记录。
num installmentPreview(
  num principal,
  int periods,
  String rateType,
  num percent,
) {
  if (principal <= 0 || periods <= 0 || percent < 0) return 0;
  double monthly = principal / periods;
  if (rateType == 'FEE') monthly += principal * percent / 100;
  if (rateType == 'APR' && percent > 0) {
    final rate = percent / 1200;
    final power = math.pow(1 + rate, periods);
    monthly = principal * rate * power / (power - 1);
  }
  return (monthly * 100).round() / 100;
}

DateTime defaultRepaymentDate(DateTime today, int repaymentDay) {
  final month = today.day >= repaymentDay ? today.month + 1 : today.month;
  final first = DateTime(today.year, month);
  return DateTime(
    first.year,
    first.month,
    math.min(repaymentDay, DateTime(first.year, first.month + 1, 0).day),
  );
}

String? integerRange(String? value, int min, int max) {
  final parsed = int.tryParse(value ?? '');
  return parsed == null || parsed < min || parsed > max
      ? '请输入 $min–$max 之间的整数'
      : null;
}

class LiabilitiesViewModel extends FeatureViewModel {
  LiabilitiesViewModel(super.repository);
  List<Liability> liabilities = [];
  List<Account> accounts = [];
  List<Category> expenseCategories = [];
  @override
  Future<void> fetch() async {
    final generation = repository.sessionGeneration;
    final data = await Future.wait<Object>([
      repository.liabilities(),
      repository.accounts(),
      repository.categories(),
    ]);
    if (generation != repository.sessionGeneration) {
      throw const StaleSessionException();
    }
    liabilities = data[0] as List<Liability>;
    accounts = data[1] as List<Account>;
    expenseCategories = (data[2] as List<Category>)
        .where((c) => c.type == 2 && c.isActive == 1)
        .toList();
  }

  List<Liability> get active =>
      liabilities.where((l) => l.status != 'SETTLED').toList();
  num get remaining => active.fold<num>(0, (sum, l) => sum + l.remainingAmount);
  num get monthlyDue => active.fold<num>(0, (sum, l) => sum + l.periodAmount);
}

class LiabilitiesPage extends StatelessWidget {
  const LiabilitiesPage({super.key});
  @override
  Widget build(BuildContext context) => ChangeNotifierProvider(
    create: (context) =>
        LiabilitiesViewModel(context.read<MoneydayRepository>())..load(),
    child: const _LiabilitiesView(),
  );
}

class _LiabilitiesView extends StatelessWidget {
  const _LiabilitiesView();
  Future<void> edit(
    BuildContext context,
    LiabilitiesViewModel vm, [
    Liability? liability,
  ]) async {
    final name = TextEditingController(text: liability?.name ?? '');
    final principal = TextEditingController(
      text: liability?.principal.toString() ?? '',
    );
    final periods = TextEditingController(
      text: (liability?.totalPeriods ?? 12).toString(),
    );
    final current = TextEditingController(
      text: (liability?.currentPeriod ?? 0).toString(),
    );
    final interest = TextEditingController(
      text: (liability?.interestRate ?? 0).toString(),
    );
    final periodAmount = TextEditingController(
      text: liability?.periodAmount.toString() ?? '',
    );
    final total = TextEditingController(
      text: liability?.totalAmount.toString() ?? '',
    );
    final day = TextEditingController(
      text: (liability?.repaymentDay ?? 10).toString(),
    );
    final next = TextEditingController(
      text:
          liability?.nextRepaymentDate ??
          dateOnly(defaultRepaymentDate(DateTime.now(), 10)),
    );
    final start = TextEditingController(
      text: liability?.startDate ?? dateOnly(DateTime.now()),
    );
    var rateType = liability?.rateType ?? 'NONE';
    int? accountId = liability?.defaultAccountId ?? vm.accounts.firstOrNull?.id;
    int? categoryId =
        liability?.categoryId ??
        vm.expenseCategories.where((c) => c.name == '分期还款').firstOrNull?.id ??
        vm.expenseCategories.firstOrNull?.id;
    var autoFixed = (liability?.autoCycleFixedExpense ?? 1) == 1;
    void recalculate() {
      final p = num.tryParse(principal.text) ?? 0;
      final n = int.tryParse(periods.text) ?? 0;
      final monthly = installmentPreview(
        p,
        n,
        rateType,
        num.tryParse(interest.text) ?? 0,
      );
      periodAmount.text = monthly.toStringAsFixed(2);
      total.text = (rateType == 'NONE' ? p : monthly * n).toStringAsFixed(2);
    }

    await showFormDialog(
      context,
      title: liability == null ? '录入消费分期' : '编辑分期',
      description: '自动扣款由服务器执行。历史已还补录不会生成历史流水；试算金额可以按实际账单校准。',
      builder: (context, setState) => PlanningFields(
        children: [
          TextFormField(
            controller: name,
            decoration: const InputDecoration(labelText: '分期名称'),
            validator: requiredText,
          ),
          TextFormField(
            controller: principal,
            decoration: const InputDecoration(labelText: '本金'),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            validator: positiveAmount,
            onChanged: (_) => setState(recalculate),
          ),
          TextFormField(
            controller: periods,
            decoration: const InputDecoration(labelText: '总期数（1–360）'),
            keyboardType: TextInputType.number,
            validator: (v) => integerRange(v, 1, 360),
            onChanged: (_) => setState(recalculate),
          ),
          DropdownButtonFormField<String>(
            initialValue: rateType,
            isExpanded: true,
            decoration: const InputDecoration(labelText: '利率模式'),
            items: const [
              DropdownMenuItem(value: 'NONE', child: Text('免息分期')),
              DropdownMenuItem(value: 'FEE', child: Text('每期手续费率')),
              DropdownMenuItem(value: 'APR', child: Text('年化利率 · 等额本息')),
            ],
            onChanged: (v) => setState(() {
              rateType = v!;
              recalculate();
            }),
          ),
          if (rateType != 'NONE')
            TextFormField(
              controller: interest,
              decoration: InputDecoration(
                labelText: rateType == 'FEE' ? '每期费率（%）' : '年化利率（%）',
              ),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              validator: (v) {
                final n = num.tryParse(v ?? '');
                return n == null || !n.isFinite || n < 0 ? '请输入非负费率' : null;
              },
              onChanged: (_) => setState(recalculate),
            ),
          TextFormField(
            controller: periodAmount,
            decoration: const InputDecoration(labelText: '每期应还金额（可校准）'),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            validator: positiveAmount,
          ),
          TextFormField(
            controller: total,
            decoration: const InputDecoration(labelText: '分期总额（可校准）'),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            validator: positiveAmount,
          ),
          TextFormField(
            controller: day,
            decoration: const InputDecoration(labelText: '每月还款日（1–31）'),
            keyboardType: TextInputType.number,
            validator: (v) => integerRange(v, 1, 31),
          ),
          PlanningAccountField(
            accounts: vm.accounts,
            value: accountId,
            onChanged: (v) => setState(() => accountId = v),
          ),
          const Text('默认账户余额不足时，服务器尝试从余额最多的账户扣款。'),
          DropdownButtonFormField<int>(
            initialValue: vm.expenseCategories.any((c) => c.id == categoryId)
                ? categoryId
                : null,
            isExpanded: true,
            decoration: const InputDecoration(labelText: '支出记账分类'),
            items: vm.expenseCategories
                .map((c) => DropdownMenuItem(value: c.id, child: Text(c.name)))
                .toList(),
            validator: (v) => v == null ? '请选择支出分类' : null,
            onChanged: (v) => setState(() => categoryId = v),
          ),
          TextFormField(
            controller: current,
            decoration: const InputDecoration(labelText: '历史已还期数（不生成流水）'),
            keyboardType: TextInputType.number,
            validator: (v) =>
                integerRange(v, 0, int.tryParse(periods.text) ?? 0),
          ),
          PlanningDateField(controller: next, label: '下期还款日'),
          PlanningDateField(controller: start, label: '首期起算日期'),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('纳入周期固定支出'),
            value: autoFixed,
            onChanged: (v) => setState(() => autoFixed = v),
          ),
        ],
      ),
      onSubmit: () => vm.repository.saveLiability({
        'name': name.text.trim(),
        'principal': parseAmount(principal.text),
        'totalAmount': parseAmount(total.text),
        'totalPeriods': int.parse(periods.text),
        'currentPeriod': int.parse(current.text),
        'rateType': rateType,
        'interestRate': rateType == 'NONE' ? 0 : parseAmount(interest.text),
        'periodAmount': parseAmount(periodAmount.text),
        'repaymentDay': int.parse(day.text),
        'nextRepaymentDate': next.text,
        'startDate': start.text,
        'defaultAccountId': accountId,
        'categoryId': categoryId,
        'autoCycleFixedExpense': autoFixed ? 1 : 0,
      }, id: liability?.id),
    );
    for (final c in [
      name,
      principal,
      periods,
      current,
      interest,
      periodAmount,
      total,
      day,
      next,
      start,
    ]) {
      c.dispose();
    }
  }

  Future<void> repay(
    BuildContext context,
    LiabilitiesViewModel vm,
    Liability liability,
  ) async {
    var settle = false;
    int? accountId = vm.accounts.any((a) => a.id == liability.defaultAccountId)
        ? liability.defaultAccountId
        : vm.accounts.firstOrNull?.id;
    final periods = TextEditingController(text: '1');
    final amount = TextEditingController(
      text: liability.periodAmount.toStringAsFixed(2),
    );
    final settleAmount = TextEditingController(
      text: liability.remainingAmount.toStringAsFixed(2),
    );
    await showFormDialog(
      context,
      title: '分期还款 · ${liability.name}',
      builder: (context, setState) => PlanningFields(
        children: [
          Text(
            '已还 ${liability.currentPeriod}/${liability.totalPeriods} 期，剩余 ${liability.remainingPeriods} 期\n下期 ${liability.nextRepaymentDate ?? '待排期'}',
          ),
          SegmentedButton<bool>(
            segments: const [
              ButtonSegment(value: false, label: Text('提前还期')),
              ButtonSegment(value: true, label: Text('提前结清')),
            ],
            selected: {settle},
            onSelectionChanged: (v) => setState(() => settle = v.first),
          ),
          if (!settle)
            TextFormField(
              controller: periods,
              decoration: const InputDecoration(labelText: '本次归还期数'),
              keyboardType: TextInputType.number,
              validator: (v) => integerRange(v, 1, liability.remainingPeriods),
              onChanged: (v) => setState(
                () => amount.text =
                    ((int.tryParse(v) ?? 0) * liability.periodAmount)
                        .toStringAsFixed(2),
              ),
            ),
          TextFormField(
            key: ValueKey(settle),
            controller: settle ? settleAmount : amount,
            decoration: InputDecoration(
              labelText: settle ? '结清金额（可调整手续费）' : '还款金额（可校准）',
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            validator: positiveAmount,
          ),
          PlanningAccountField(
            accounts: vm.accounts,
            value: accountId,
            onChanged: (v) => setState(() => accountId = v),
          ),
          Text(
            settle
                ? '将一次性偿还剩余所有期数并立即结清，后续停止周期扣款。'
                : '提前还期后，服务器按归还期数顺延还款日，防止重复扣款。',
          ),
        ],
      ),
      onSubmit: () async {
        if (accountId == null) throw Exception('请选择扣款账户');
        if (settle) {
          await vm.repository.settle(
            liability.id,
            accountId: accountId!,
            amount: parseAmount(settleAmount.text),
          );
        } else {
          await vm.repository.repay(
            liability.id,
            accountId: accountId!,
            periods: int.parse(periods.text),
            amount: parseAmount(amount.text),
          );
        }
      },
    );
    periods.dispose();
    amount.dispose();
    settleAmount.dispose();
  }

  Widget actions(BuildContext context, LiabilitiesViewModel vm, Liability l) =>
      Wrap(
        children: [
          if (l.status != 'SETTLED') ...[
            TextButton(
              onPressed: vm.saving ? null : () => repay(context, vm, l),
              child: const Text('还款'),
            ),
            TextButton(
              onPressed: vm.saving ? null : () => edit(context, vm, l),
              child: const Text('编辑'),
            ),
          ],
          TextButton(
            onPressed: vm.saving
                ? null
                : () async {
                    if (await confirmAction(
                      context,
                      '删除分期',
                      '删除「${l.name}」？历史扣款流水继续保留。',
                      destructive: true,
                    )) {
                      await vm.run(() => vm.repository.deleteLiability(l.id));
                    }
                  },
            child: const Text('删除'),
          ),
        ],
      );

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<LiabilitiesViewModel>();
    return AsyncPage(
      model: vm,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const PlanningNavigation(selected: '/plan/liabilities'),
            PageHeader(
              title: '分期负债',
              subtitle:
                  '还款中 ${vm.active.length} 笔 · 待还 ${money(vm.remaining)} · 每月应还 ${money(vm.monthlyDue)}',
              actions: [
                FilledButton.icon(
                  onPressed: vm.saving ? null : () => edit(context, vm),
                  icon: const Icon(Icons.add),
                  label: const Text('录入分期'),
                ),
              ],
            ),
            PlanningRecords(
              columns: const [
                DataColumn(label: Text('名称 / 状态')),
                DataColumn(label: Text('本金 / 待还')),
                DataColumn(label: Text('进度')),
                DataColumn(label: Text('每期 / 还款日')),
                DataColumn(label: Text('下期还款')),
                DataColumn(label: Text('账户 / 分类')),
                DataColumn(label: Text('操作')),
              ],
              rows: vm.liabilities
                  .map(
                    (l) => DataRow(
                      cells: [
                        DataCell(
                          Text(
                            '${l.name}\n${l.status == 'SETTLED' ? '已结清' : '还款中'}',
                          ),
                        ),
                        DataCell(
                          Text(
                            '${money(l.principal)}\n待还 ${money(l.remainingAmount)}',
                          ),
                        ),
                        DataCell(
                          Text(
                            '${l.currentPeriod}/${l.totalPeriods} 期 · ${l.progressPercent}%\n剩余 ${l.remainingPeriods} 期',
                          ),
                        ),
                        DataCell(
                          Text(
                            '${money(l.periodAmount)}\n每月 ${l.repaymentDay} 日',
                          ),
                        ),
                        DataCell(
                          Text(
                            l.status == 'SETTLED'
                                ? '—'
                                : l.nextRepaymentDate ?? '待排期',
                          ),
                        ),
                        DataCell(
                          Text(
                            '${l.defaultAccountName ?? '未指定'}\n${l.categoryName ?? '分期还款'}',
                          ),
                        ),
                        DataCell(actions(context, vm, l)),
                      ],
                    ),
                  )
                  .toList(),
              cards: vm.liabilities
                  .map(
                    (l) => Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l.name,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            Text(
                              '${l.status == 'SETTLED' ? '已结清' : '还款中'} · 本金 ${money(l.principal)}',
                            ),
                            Text(
                              '待还 ${money(l.remainingAmount)} · 每期 ${money(l.periodAmount)}',
                            ),
                            const SizedBox(height: 8),
                            LinearProgressIndicator(
                              value: l.progressPercent.clamp(0, 100) / 100,
                            ),
                            Text(
                              '已还 ${l.currentPeriod}/${l.totalPeriods} 期 · 剩余 ${l.remainingPeriods} 期',
                            ),
                            Text(
                              '每月 ${l.repaymentDay} 日 · 下期 ${l.nextRepaymentDate ?? '—'}',
                            ),
                            Text(
                              '${l.defaultAccountName ?? '未指定账户'} · ${l.categoryName ?? '分期还款'}',
                            ),
                            actions(context, vm, l),
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
