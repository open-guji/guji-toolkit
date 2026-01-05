import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:guji_toolkit/features/collation/providers/collation_provider.dart';
import 'package:guji_toolkit/features/collation/widgets/text_input_panel.dart';

void main() {
  group('TextInputPanel Widget Tests', () {
    testWidgets('应该显示文本输入面板标题', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: TextInputPanel(),
            ),
          ),
        ),
      );

      expect(find.text('文本输入'), findsOneWidget);
    });

    testWidgets('应该显示两个文本输入框', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: TextInputPanel(),
            ),
          ),
        ),
      );

      expect(find.text('文本 1'), findsOneWidget);
      expect(find.text('文本 2'), findsOneWidget);
      expect(find.byType(TextField), findsNWidgets(2));
    });

    testWidgets('应该显示提示文本', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: TextInputPanel(),
            ),
          ),
        ),
      );

      expect(find.text('请输入第一段古籍文本...'), findsOneWidget);
      expect(find.text('请输入第二段古籍文本...'), findsOneWidget);
    });

    testWidgets('输入文本1应该更新状态', (WidgetTester tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: Scaffold(
              body: TextInputPanel(),
            ),
          ),
        ),
      );

      // 找到第一个文本输入框
      final textField1 = find.byType(TextField).first;
      await tester.enterText(textField1, '春眠不觉晓');
      await tester.pump();

      // 验证状态已更新
      final state = container.read(collationProvider);
      expect(state.text1, '春眠不觉晓');
    });

    testWidgets('输入文本2应该更新状态', (WidgetTester tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: Scaffold(
              body: TextInputPanel(),
            ),
          ),
        ),
      );

      // 找到第二个文本输入框
      final textField2 = find.byType(TextField).last;
      await tester.enterText(textField2, '处处闻啼鸟');
      await tester.pump();

      // 验证状态已更新
      final state = container.read(collationProvider);
      expect(state.text2, '处处闻啼鸟');
    });

    testWidgets('同时输入两个文本应该都更新状态', (WidgetTester tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: Scaffold(
              body: TextInputPanel(),
            ),
          ),
        ),
      );

      // 输入文本1
      final textField1 = find.byType(TextField).first;
      await tester.enterText(textField1, '春眠不觉晓');
      await tester.pump();

      // 输入文本2
      final textField2 = find.byType(TextField).last;
      await tester.enterText(textField2, '处处闻啼鸟');
      await tester.pump();

      // 验证状态已更新
      final state = container.read(collationProvider);
      expect(state.text1, '春眠不觉晓');
      expect(state.text2, '处处闻啼鸟');
    });

    testWidgets('应该支持多行文本输入', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: TextInputPanel(),
            ),
          ),
        ),
      );

      final textFields = find.byType(TextField);
      for (final textField in textFields.evaluate()) {
        final widget = textField.widget as TextField;
        expect(widget.maxLines, null);
        expect(widget.expands, true);
      }
    });
  });
}
