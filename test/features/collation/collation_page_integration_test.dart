import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:guji_toolkit/features/collation/collation_page.dart';

void main() {
  group('CollationPage 集成测试', () {
    testWidgets('页面应该正确渲染所有组件', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: CollationPage()));

      // 验证页面标题
      expect(find.text('古籍对校'), findsOneWidget);
      expect(find.text('比较两段古籍文本，输出差异分析结果'), findsOneWidget);

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
      await tester.pumpWidget(const MaterialApp(home: CollationPage()));

      // 等待 OpenCC 就绪（如果是异步加载的话）
      await tester.pumpAndSettle();

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
      await tester.pumpAndSettle(); // 等待对比完成

      // 4. 验证结果显示
      expect(find.textContaining('相似度:'), findsOneWidget);
      expect(find.byType(SelectableText), findsOneWidget);
    });

    testWidgets('空文本对校应该显示错误', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: CollationPage()));

      await tester.pumpAndSettle();

      // 不输入任何文本，直接点击对比
      final compareButton = find.text('开始对比');
      await tester.tap(compareButton);
      await tester.pumpAndSettle();

      // 应该显示错误信息
      expect(find.text('请输入两段文本'), findsOneWidget);
    });

    testWidgets('只输入一个文本应该显示错误', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: CollationPage()));

      await tester.pumpAndSettle();

      // 只输入文本1
      final textField1 = find.byType(TextField).first;
      await tester.enterText(textField1, '春眠不觉晓');
      await tester.pump();

      // 点击对比
      final compareButton = find.text('开始对比');
      await tester.tap(compareButton);
      await tester.pumpAndSettle();

      // 应该显示错误
      expect(find.text('请输入两段文本'), findsOneWidget);
    });

    testWidgets('相同文本对校应该显示100%相似度', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: CollationPage()));

      await tester.pumpAndSettle();

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
      await tester.pumpAndSettle();

      // 验证100%相似度
      expect(find.textContaining('100.0%'), findsOneWidget);
    });

    testWidgets('标点符号选项应该正常工作', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: CollationPage()));

      await tester.pumpAndSettle();

      // 输入带标点的文本
      final textField1 = find.byType(TextField).first;
      await tester.enterText(textField1, '春眠不觉晓。');
      await tester.pump();

      final textField2 = find.byType(TextField).at(1);
      await tester.enterText(textField2, '春眠不觉晓');
      await tester.pump();

      // 默认是忽略标点的，现在的逻辑应该不产生差异（在 integration 文本中相似度为 100%）

      // 点击忽略标点复选框（取消选中）
      final punctuationCheckbox = find.ancestor(
        of: find.text('忽略标点符号'),
        matching: find.byType(CheckboxListTile),
      );
      await tester.tap(punctuationCheckbox);
      await tester.pumpAndSettle();

      // 执行对校
      final compareButton = find.text('开始对比');
      await tester.tap(compareButton);
      await tester.pumpAndSettle();

      // 相似度应该不是 100.0% 了
      final similarityText = tester.widget<Text>(find.textContaining('相似度:'));
      expect(similarityText.data, isNot(contains('100.0%')));
    });

    testWidgets('长文本对校应该正常工作', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: CollationPage()));

      await tester.pumpAndSettle();

      final longText1 = '春眠不觉晓，处处闻啼鸟。夜来风雨声，花落知多少。';
      final longText2 = '春眠不覺曉，處處聞啼鳥。夜來風雨聲，花落知多少。';

      // 输入长文本
      await tester.enterText(find.byType(TextField).first, longText1);
      await tester.enterText(find.byType(TextField).at(1), longText2);
      await tester.pump();

      // 执行对校
      await tester.tap(find.text('开始对比'));
      await tester.pumpAndSettle();

      // 验证结果
      expect(find.textContaining('相似度:'), findsOneWidget);
      expect(find.byType(SelectableText), findsOneWidget);
    });
  });
}
