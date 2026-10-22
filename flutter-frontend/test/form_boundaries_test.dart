import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moneyday/ui/core/widgets.dart';
import 'package:moneyday/ui/features/planning/planning_widgets.dart';

void main() {
  test('财务金额拒绝超过分精度和科学计数，避免数据库静默舍入', () {
    for (final value in [
      '0.001',
      '12.345',
      '1e3',
      'Infinity',
      'NaN',
      '0',
      '-1',
    ]) {
      expect(positiveAmount(value), isNotNull, reason: value);
    }
    for (final value in ['0.01', '12', '12.50', ' 12.50 ']) {
      expect(positiveAmount(value), isNull, reason: value);
    }
  });

  for (final date in ['1800-01-01', '2500-01-01']) {
    testWidgets('日期选择器夹取手工边界日期 $date，不修改原始文本', (tester) async {
      final controller = TextEditingController(text: date);
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PlanningDateField(controller: controller, label: '日期'),
          ),
        ),
      );
      await tester.tap(find.byTooltip('选择日期'));
      await tester.pumpAndSettle();
      expect(find.byType(DatePickerDialog), findsOneWidget);
      expect(controller.text, date);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
      controller.dispose();
    });
  }
}
