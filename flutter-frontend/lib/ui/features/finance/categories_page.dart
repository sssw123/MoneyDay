import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:moneyday/data/models/models.dart';
import 'package:moneyday/data/repositories/moneyday_repository.dart';
import 'package:moneyday/ui/core/widgets.dart';

import 'finance_view_models.dart';
import 'finance_widgets.dart';

class CategoriesPage extends StatelessWidget {
  const CategoriesPage({super.key});
  @override
  Widget build(BuildContext context) => ChangeNotifierProvider(
    create: (context) =>
        CategoriesViewModel(context.read<MoneydayRepository>())..load(),
    child: const _CategoriesView(),
  );
}

class _CategoriesView extends StatelessWidget {
  const _CategoriesView();
  Future<void> edit(
    BuildContext context,
    CategoriesViewModel model, [
    Category? category,
  ]) async {
    final name = TextEditingController(text: category?.name ?? '');
    var type = category?.type ?? 2;
    var active = category?.isActive == 1 || category == null;
    await showFormDialog(
      context,
      title: category == null ? '新增分类' : '编辑分类',
      builder: (context, setState) => FinanceFields(
        children: [
          TextFormField(
            controller: name,
            autofocus: true,
            decoration: const InputDecoration(labelText: '分类名称'),
            validator: requiredText,
          ),
          SegmentedButton<int>(
            segments: const [
              ButtonSegment(
                value: 2,
                label: Text('支出'),
                icon: Icon(Icons.north_east),
              ),
              ButtonSegment(
                value: 1,
                label: Text('收入'),
                icon: Icon(Icons.south_west),
              ),
            ],
            selected: {type},
            onSelectionChanged: (value) => setState(() => type = value.first),
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('启用分类'),
            subtitle: const Text('停用后，新记账不再显示该分类。'),
            value: active,
            onChanged: (value) => setState(() => active = value),
          ),
        ],
      ),
      onSubmit: () => model.save({
        'name': name.text.trim(),
        'type': type,
        'isActive': active ? 1 : 0,
      }, id: category?.id),
    );
    name.dispose();
  }

  Widget toggle(
    BuildContext context,
    CategoriesViewModel model,
    Category category,
  ) => Semantics(
    label: '启用分类：${category.name}',
    child: Switch.adaptive(
      value: category.isActive == 1,
      onChanged: model.saving ? null : (value) => model.toggle(category, value),
    ),
  );
  Widget actions(
    BuildContext context,
    CategoriesViewModel model,
    Category category,
  ) => Wrap(
    children: [
      TextButton(
        onPressed: model.saving ? null : () => edit(context, model, category),
        child: const Text('编辑'),
      ),
      TextButton(
        onPressed: model.saving
            ? null
            : () async {
                if (await confirmAction(
                  context,
                  '删除分类',
                  '删除「${category.name}」？若需保留历史使用记录，可改为停用。',
                  destructive: true,
                )) {
                  await model.remove(category);
                }
              },
        child: const Text('删除'),
      ),
    ],
  );
  @override
  Widget build(BuildContext context) {
    final model = context.watch<CategoriesViewModel>();
    return AsyncPage(
      model: model,
      child: FinanceBody(
        children: [
          PageHeader(
            title: '收支分类',
            subtitle: '给每笔收支一个清晰的归属。',
            actions: [
              FilledButton.icon(
                onPressed: model.saving ? null : () => edit(context, model),
                icon: const Icon(Icons.add),
                label: const Text('新增分类'),
              ),
            ],
          ),
          FinanceTable<Category>(
            items: model.categories,
            emptyMessage: '暂无分类，添加收入或支出分类后即可使用。',
            columns: const [
              DataColumn(label: Text('分类名称')),
              DataColumn(label: Text('类型')),
              DataColumn(label: Text('启用状态')),
              DataColumn(label: Text('操作')),
            ],
            row: (category) => DataRow(
              cells: [
                DataCell(Text(category.name)),
                DataCell(
                  Text(
                    transactionTypeName(category.type),
                    style: TextStyle(
                      color: transactionColor(context, category.type),
                    ),
                  ),
                ),
                DataCell(toggle(context, model, category)),
                DataCell(actions(context, model, category)),
              ],
            ),
            card: (category) => Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                category.name,
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              Text(
                                transactionTypeName(category.type),
                                style: TextStyle(
                                  color: transactionColor(
                                    context,
                                    category.type,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        toggle(context, model, category),
                      ],
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: actions(context, model, category),
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
