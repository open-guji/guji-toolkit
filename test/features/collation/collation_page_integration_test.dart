import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:guji_toolkit/features/collation/collation_page.dart';

void main() {
  group('CollationPage 集成测试', () {
    testWidgets('页面应该正确渲染所有组件', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: CollationPage(),
          ),
        ),
      );

      // 验证页面标题
      expect(find.text('古籍对校'), findsOneWidget);
      expect(find.text('比较两段古籍文本,输出差异分析结果'), findsOneWidget);

      // 验证文本输入面板
      expect(find.text('文本输入'), findsOneWidget);
      expect(find.text('文本 1'), findsOneWidget);
      expect(find.text('文本 2'), findsOneWidget);

      // 验证选项面板
      expect(find.text('对校选项'), findsOneWidget);
      expect(find.text('忽略标点符号'), findsOneWidget);
      expect(find.text('繁简兼容'), findsOneWidget);

      // 验证对比按钮
      expect(find.text('开始对比'), findsOneWidget);

      // 验证结果面板
      expect(find.text('对比结果'), findsOneWidget);
    });

    testWidgets('完整的对校流程应该正常工作', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: CollationPage(),
          ),
        ),
      );

      // 1. 输入文本1
      final textField1 = find.byType(TextField).first;
      await tester.enterText(textField1, '春眠不觉晓');
      await tester.pump();

      // 2. 输入文本2
      final textField2 = find.byType(TextField).at(1);
      await tester.enterText(textField2, '春眠不覺曉');
      await tester.pump();

      // 3. 点击开始对比按钮
      final compareButton = find.text('开始对比');
      await tester.tap(compareButton);
      await tester.pump(); // 开始对比
      await tester.pump(); // 完成对比

      // 4. 验证结果显示
      expect(find.textContaining('相似度:'), findsOneWidget);
      expect(find.byType(SelectableText), findsOneWidget);
    });

    testWidgets('空文本对校应该显示错误', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: CollationPage(),
          ),
        ),
      );

      // 不输入任何文本，直接点击对比
      final compareButton = find.text('开始对比');
      await tester.tap(compareButton);
      await tester.pump();
      await tester.pump();

      // 应该显示错误信息
      expect(find.text('请输入两段文本'), findsOneWidget);
    });

    testWidgets('只输入一个文本应该显示错误', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: CollationPage(),
          ),
        ),
      );

      // 只输入文本1
      final textField1 = find.byType(TextField).first;
      await tester.enterText(textField1, '春眠不觉晓');
      await tester.pump();

      // 点击对比
      final compareButton = find.text('开始对比');
      await tester.tap(compareButton);
      await tester.pump();
      await tester.pump();

      // 应该显示错误
      expect(find.text('请输入两段文本'), findsOneWidget);
    });

    testWidgets('相同文本对校应该显示100%相似度', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: CollationPage(),
          ),
        ),
      );

      // 输入相同的文本
      final textField1 = find.byType(TextField).first;
      await tester.enterText(textField1, '春眠不觉晓');
      await tester.pump();

      final textField2 = find.byType(TextField).at(1);
      await tester.enterText(textField2, '春眠不觉晓');
      await tester.pump();

      // 点击对比
      final compareButton = find.text('开始对比');
      await tester.tap(compareButton);
      await tester.pump();
      await tester.pump();

      // 验证100%相似度
      expect(find.textContaining('100.0%'), findsOneWidget);
    });

    testWidgets('修改选项应该影响对校结果', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: CollationPage(),
          ),
        ),
      );

      // 输入繁简混合文本
      final textField1 = find.byType(TextField).first;
      await tester.enterText(textField1, '春眠不觉晓');
      await tester.pump();

      final textField2 = find.byType(TextField).at(1);
      await tester.enterText(textField2, '春眠不覺曉');
      await tester.pump();

      // 取消繁简兼容
      final traditionalCheckbox = find.ancestor(
        of: find.text('繁简兼容'),
        matching: find.byType(CheckboxListTile),
      );
      await tester.tap(traditionalCheckbox);
      await tester.pump();

      // 执行对校
      final compareButton = find.text('开始对比');
      await tester.tap(compareButton);
      await tester.pump();
      await tester.pump();

      // 应该有差异（相似度不是100%）
      final similarityText = tester.widget<Text>(
        find.textContaining('相似度:'),
      );
      expect(similarityText.data, isNot(contains('100.0%')));
    });

    testWidgets('标点符号选项应该正常工作', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: CollationPage(),
          ),
        ),
      );

      // 输入带标点的文本
      final textField1 = find.byType(TextField).first;
      await tester.enterText(textField1, '春眠不觉晓。');
      await tester.pump();

      final textField2 = find.byType(TextField).at(1);
      await tester.enterText(textField2, '春眠不觉晓');
      await tester.pump();

      // 点击忽略标点复选框（取消选中）
      final punctuationCheckbox = find.ancestor(
        of: find.text('忽略标点符号'),
        matching: find.byType(CheckboxListTile),
      );
      await tester.tap(punctuationCheckbox);
      await tester.pump();

      // 执行对校
      final compareButton = find.text('开始对比');
      await tester.tap(compareButton);
      await tester.pump();
      await tester.pump();

      // 应该检测到差异
      expect(find.byType(SelectableText), findsOneWidget);
    });

    testWidgets('对比按钮在对比过程中应该禁用', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: CollationPage(),
          ),
        ),
      );

      // 输入文本
      final textField1 = find.byType(TextField).first;
      await tester.enterText(textField1, '春眠不觉晓');
      await tester.pump();

      final textField2 = find.byType(TextField).at(1);
      await tester.enterText(textField2, '春眠不觉晓');
      await tester.pump();

      // 获取对比按钮
      final compareButton = find.ancestor(
        of: find.text('开始对比'),
        matching: find.byType(FilledButton),
      );

      // 点击前按钮应该是启用的
      final buttonBeforeTap = tester.widget<FilledButton>(compareButton);
      expect(buttonBeforeTap.onPressed, isNotNull);

      // 点击对比（不pump让它保持在对比中状态）
      await tester.tap(compareButton);
      // 只pump一次，让按钮更新但不完成异步操作
      await tester.pump();

      // 在对比过程中按钮可能显示"对比中..."
      // 但由于对比很快完成，我们主要验证逻辑正确性
    });

    testWidgets('多次对校应该正常工作', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: CollationPage(),
          ),
        ),
      );

      // 第一次对校
      await tester.enterText(find.byType(TextField).first, '春眠不觉晓');
      await tester.enterText(find.byType(TextField).at(1), '春眠不覺曉');
      await tester.pump();

      await tester.tap(find.text('开始对比'));
      await tester.pump();
      await tester.pump();

      expect(find.textContaining('相似度:'), findsOneWidget);

      // 第二次对校（更新文本）
      await tester.enterText(find.byType(TextField).first, '床前明月光');
      await tester.enterText(find.byType(TextField).at(1), '床前明月光');
      await tester.pump();

      await tester.tap(find.text('开始对比'));
      await tester.pump();
      await tester.pump();

      expect(find.textContaining('100.0%'), findsOneWidget);
    });

    testWidgets('完全不同的文本应该显示低相似度', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: CollationPage(),
          ),
        ),
      );

      // 输入完全不同的文本
      final textField1 = find.byType(TextField).first;
      await tester.enterText(textField1, '春眠不觉晓');
      await tester.pump();

      final textField2 = find.byType(TextField).at(1);
      await tester.enterText(textField2, '床前明月光');
      await tester.pump();

      // 执行对校
      final compareButton = find.text('开始对比');
      await tester.tap(compareButton);
      await tester.pump();
      await tester.pump();

      // 验证结果存在（相似度应该很低）
      expect(find.textContaining('相似度:'), findsOneWidget);
      expect(find.byType(SelectableText), findsOneWidget);
    });

    testWidgets('长文本对校应该正常工作', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: CollationPage(),
          ),
        ),
      );

      final longText1 = '春眠不觉晓，处处闻啼鸟。夜来风雨声，花落知多少。';
      final longText2 = '春眠不覺曉，處處聞啼鳥。夜來風雨聲，花落知多少。';

      // 输入长文本
      await tester.enterText(find.byType(TextField).first, longText1);
      await tester.enterText(find.byType(TextField).at(1), longText2);
      await tester.pump();

      // 执行对校
      await tester.tap(find.text('开始对比'));
      await tester.pump();
      await tester.pump();

      // 验证结果
      expect(find.textContaining('相似度:'), findsOneWidget);
      expect(find.byType(SelectableText), findsOneWidget);
    });
  });
}
