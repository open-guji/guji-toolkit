import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:guji_toolkit/features/collation/providers/collation_provider.dart';
import 'package:guji_toolkit/features/collation/widgets/collation_options_panel.dart';

void main() {
  group('CollationOptionsPanel Widget Tests', () {
    testWidgets('应该显示对校选项标题', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: CollationOptionsPanel(),
            ),
          ),
        ),
      );

      expect(find.text('对校选项'), findsOneWidget);
    });

    testWidgets('应该显示两个复选框选项', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: CollationOptionsPanel(),
            ),
          ),
        ),
      );

      expect(find.text('忽略标点符号'), findsOneWidget);
      expect(find.text('繁简兼容'), findsOneWidget);
      expect(find.byType(CheckboxListTile), findsNWidgets(2));
    });

    testWidgets('应该显示选项说明文本', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: CollationOptionsPanel(),
            ),
          ),
        ),
      );

      expect(find.text('对比时不考虑标点差异'), findsOneWidget);
      expect(find.text('自动识别繁简体对应关系'), findsOneWidget);
    });

    testWidgets('初始状态应该显示默认选中状态', (WidgetTester tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: Scaffold(
              body: CollationOptionsPanel(),
            ),
          ),
        ),
      );

      final state = container.read(collationProvider);
      expect(state.ignorePunctuation, true);
      expect(state.ignoreTraditional, true);

      // 验证复选框显示为选中状态
      final checkboxes = tester.widgetList<CheckboxListTile>(
        find.byType(CheckboxListTile),
      );
      for (final checkbox in checkboxes) {
        expect(checkbox.value, true);
      }
    });

    testWidgets('点击忽略标点复选框应该切换状态', (WidgetTester tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: Scaffold(
              body: CollationOptionsPanel(),
            ),
          ),
        ),
      );

      // 找到忽略标点选项
      final punctuationCheckbox = find.ancestor(
        of: find.text('忽略标点符号'),
        matching: find.byType(CheckboxListTile),
      );

      // 点击取消选中
      await tester.tap(punctuationCheckbox);
      await tester.pump();

      expect(container.read(collationProvider).ignorePunctuation, false);

      // 再次点击恢复选中
      await tester.tap(punctuationCheckbox);
      await tester.pump();

      expect(container.read(collationProvider).ignorePunctuation, true);
    });

    testWidgets('点击繁简兼容复选框应该切换状态', (WidgetTester tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: Scaffold(
              body: CollationOptionsPanel(),
            ),
          ),
        ),
      );

      // 找到繁简兼容选项
      final traditionalCheckbox = find.ancestor(
        of: find.text('繁简兼容'),
        matching: find.byType(CheckboxListTile),
      );

      // 点击取消选中
      await tester.tap(traditionalCheckbox);
      await tester.pump();

      expect(container.read(collationProvider).ignoreTraditional, false);

      // 再次点击恢复选中
      await tester.tap(traditionalCheckbox);
      await tester.pump();

      expect(container.read(collationProvider).ignoreTraditional, true);
    });

    testWidgets('两个选项应该独立工作', (WidgetTester tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: Scaffold(
              body: CollationOptionsPanel(),
            ),
          ),
        ),
      );

      // 取消选中忽略标点
      final punctuationCheckbox = find.ancestor(
        of: find.text('忽略标点符号'),
        matching: find.byType(CheckboxListTile),
      );
      await tester.tap(punctuationCheckbox);
      await tester.pump();

      // 验证只有标点选项变化
      expect(container.read(collationProvider).ignorePunctuation, false);
      expect(container.read(collationProvider).ignoreTraditional, true);

      // 取消选中繁简兼容
      final traditionalCheckbox = find.ancestor(
        of: find.text('繁简兼容'),
        matching: find.byType(CheckboxListTile),
      );
      await tester.tap(traditionalCheckbox);
      await tester.pump();

      // 验证两个选项都为false
      expect(container.read(collationProvider).ignorePunctuation, false);
      expect(container.read(collationProvider).ignoreTraditional, false);
    });
  });
}
