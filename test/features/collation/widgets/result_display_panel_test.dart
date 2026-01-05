import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:guji_toolkit/features/collation/models/collation_state.dart';
import 'package:guji_toolkit/features/collation/providers/collation_provider.dart';
import 'package:guji_toolkit/features/collation/widgets/result_display_panel.dart';

void main() {
  group('ResultDisplayPanel Widget Tests', () {
    testWidgets('应该显示对比结果标题', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: ResultDisplayPanel(),
            ),
          ),
        ),
      );

      expect(find.text('对比结果'), findsOneWidget);
    });

    testWidgets('无结果时应该显示提示信息', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: ResultDisplayPanel(),
            ),
          ),
        ),
      );

      expect(find.text('点击"开始对比"查看结果'), findsOneWidget);
    });

    testWidgets('有错误时应该显示错误信息', (WidgetTester tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      // 设置错误状态
      container.read(collationProvider.notifier).state = const CollationState(
        result: CollationResult(
          diff: '',
          similarity: 0,
          error: '对校失败: 文本为空',
        ),
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: Scaffold(
              body: ResultDisplayPanel(),
            ),
          ),
        ),
      );

      expect(find.text('对校失败: 文本为空'), findsOneWidget);
    });

    testWidgets('有结果时应该显示相似度', (WidgetTester tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      // 设置成功结果
      container.read(collationProvider.notifier).state = const CollationState(
        result: CollationResult(
          diff: '春眠不觉晓',
          similarity: 0.85,
        ),
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: Scaffold(
              body: ResultDisplayPanel(),
            ),
          ),
        ),
      );

      expect(find.textContaining('相似度:'), findsOneWidget);
      expect(find.textContaining('85.0%'), findsOneWidget);
    });

    testWidgets('应该正确显示差异文本', (WidgetTester tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(collationProvider.notifier).state = const CollationState(
        result: CollationResult(
          diff: '春眠不[-觉-][+覺+][-晓-][+曉+]',
          similarity: 0.6,
        ),
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: Scaffold(
              body: ResultDisplayPanel(),
            ),
          ),
        ),
      );

      // 验证可选择文本存在
      expect(find.byType(SelectableText), findsOneWidget);
    });

    testWidgets('有结果时应该显示图例', (WidgetTester tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(collationProvider.notifier).state = const CollationState(
        result: CollationResult(
          diff: '春眠不觉晓',
          similarity: 1.0,
        ),
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: Scaffold(
              body: ResultDisplayPanel(),
            ),
          ),
        ),
      );

      expect(find.text('[-删除-]'), findsOneWidget);
      expect(find.text('[+添加+]'), findsOneWidget);
    });

    testWidgets('相似度为100%时应该正确显示', (WidgetTester tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(collationProvider.notifier).state = const CollationState(
        result: CollationResult(
          diff: '春眠不觉晓',
          similarity: 1.0,
        ),
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: Scaffold(
              body: ResultDisplayPanel(),
            ),
          ),
        ),
      );

      expect(find.textContaining('100.0%'), findsOneWidget);
    });

    testWidgets('相似度为0%时应该正确显示', (WidgetTester tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(collationProvider.notifier).state = const CollationState(
        result: CollationResult(
          diff: '[-春眠不觉晓-][+床前明月光+]',
          similarity: 0.0,
        ),
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: Scaffold(
              body: ResultDisplayPanel(),
            ),
          ),
        ),
      );

      expect(find.textContaining('0.0%'), findsOneWidget);
    });

    testWidgets('相似度小数应该保留一位', (WidgetTester tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(collationProvider.notifier).state = const CollationState(
        result: CollationResult(
          diff: '测试文本',
          similarity: 0.6789,
        ),
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: Scaffold(
              body: ResultDisplayPanel(),
            ),
          ),
        ),
      );

      expect(find.textContaining('67.9%'), findsOneWidget);
    });

    testWidgets('结果文本应该可滚动', (WidgetTester tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      // 设置长文本结果
      final longText = '春眠不觉晓' * 100;
      container.read(collationProvider.notifier).state = CollationState(
        result: CollationResult(
          diff: longText,
          similarity: 1.0,
        ),
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: Scaffold(
              body: ResultDisplayPanel(),
            ),
          ),
        ),
      );

      expect(find.byType(SingleChildScrollView), findsOneWidget);
    });
  });
}
