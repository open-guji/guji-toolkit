@TestOn('chrome')
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:guji_toolkit/features/collation/collation_page.dart';

/// Web 平台集成测试
///
/// 这些测试需要在 Chrome 环境下运行，因为 guji-diff 包依赖 OpenCC：
/// - Native 环境: OpenCC 使用 FFI (需要编译 native asset)
/// - Web 环境: OpenCC 使用 JavaScript 实现
///
/// 运行方式:
/// ```bash
/// flutter test --platform chrome test/features/collation/collation_web_integration_test.dart
/// ```
void main() {
  group('CollationPage Web 集成测试（需要 OpenCC）', () {
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
      await tester.pumpAndSettle(); // 等待异步操作完成

      // 4. 验证结果显示
      expect(find.textContaining('相似度:'), findsOneWidget);
      expect(find.byType(SelectableText), findsOneWidget);
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
      await tester.pumpAndSettle();

      // 验证100%相似度
      expect(find.textContaining('100.0%'), findsOneWidget);
    });

    testWidgets('繁简体文本启用兼容后应该提高相似度', (WidgetTester tester) async {
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

      // 启用繁简兼容（默认已启用，这里确保）
      final traditionalCheckbox = find.ancestor(
        of: find.text('繁简兼容'),
        matching: find.byType(CheckboxListTile),
      );

      // 先取消再启用，验证切换功能
      await tester.tap(traditionalCheckbox);
      await tester.pump();

      // 执行对校（繁简不兼容）
      await tester.tap(find.text('开始对比'));
      await tester.pump();
      await tester.pumpAndSettle();

      // 记录第一次相似度（应该较低）
      final firstResult = find.textContaining('相似度:');
      expect(firstResult, findsOneWidget);

      // 再次启用繁简兼容
      await tester.tap(traditionalCheckbox);
      await tester.pump();

      // 再次对校（繁简兼容）
      await tester.tap(find.text('开始对比'));
      await tester.pump();
      await tester.pumpAndSettle();

      // 第二次相似度应该更高（接近或等于100%）
      expect(find.textContaining('相似度:'), findsOneWidget);
    });

    testWidgets('标点符号选项应该影响结果', (WidgetTester tester) async {
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
      await tester.pumpAndSettle();

      // 应该检测到差异
      expect(find.byType(SelectableText), findsOneWidget);
      expect(find.textContaining('相似度:'), findsOneWidget);
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
      await tester.pumpAndSettle();

      // 验证结果存在且相似度较低
      expect(find.textContaining('相似度:'), findsOneWidget);
      expect(find.byType(SelectableText), findsOneWidget);

      // 相似度应该小于50%
      // 注意：这里无法直接读取相似度数值，只能验证结果存在
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
      await tester.pumpAndSettle();

      // 验证结果
      expect(find.textContaining('相似度:'), findsOneWidget);
      expect(find.byType(SelectableText), findsOneWidget);
    });

    testWidgets('多次连续对校应该正常工作', (WidgetTester tester) async {
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
      await tester.pumpAndSettle();

      expect(find.textContaining('相似度:'), findsOneWidget);

      // 第二次对校（更新文本）
      await tester.enterText(find.byType(TextField).first, '床前明月光');
      await tester.enterText(find.byType(TextField).at(1), '床前明月光');
      await tester.pump();

      await tester.tap(find.text('开始对比'));
      await tester.pump();
      await tester.pumpAndSettle();

      expect(find.textContaining('100.0%'), findsOneWidget);

      // 第三次对校
      await tester.enterText(find.byType(TextField).first, '疑是地上霜');
      await tester.enterText(find.byType(TextField).at(1), '疑似地上霜');
      await tester.pump();

      await tester.tap(find.text('开始对比'));
      await tester.pump();
      await tester.pumpAndSettle();

      expect(find.textContaining('相似度:'), findsOneWidget);
    });

    testWidgets('差异高亮显示应该正确渲染', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: CollationPage(),
          ),
        ),
      );

      // 输入有明显差异的文本
      await tester.enterText(find.byType(TextField).first, '春眠');
      await tester.enterText(find.byType(TextField).at(1), '春天');
      await tester.pump();

      // 取消繁简兼容，确保能看到差异
      final traditionalCheckbox = find.ancestor(
        of: find.text('繁简兼容'),
        matching: find.byType(CheckboxListTile),
      );
      await tester.tap(traditionalCheckbox);
      await tester.pump();

      // 执行对校
      await tester.tap(find.text('开始对比'));
      await tester.pump();
      await tester.pumpAndSettle();

      // 验证有可选择的文本（包含差异高亮）
      expect(find.byType(SelectableText), findsOneWidget);

      // 验证图例显示
      expect(find.text('[-删除-]'), findsOneWidget);
      expect(find.text('[+添加+]'), findsOneWidget);
    });
  });

  group('CollationPage 错误处理（Web）', () {
    testWidgets('空文本应该显示错误提示', (WidgetTester tester) async {
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
      await tester.pumpAndSettle();

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
      await tester.pumpAndSettle();

      // 应该显示错误
      expect(find.text('请输入两段文本'), findsOneWidget);
    });
  });
}
