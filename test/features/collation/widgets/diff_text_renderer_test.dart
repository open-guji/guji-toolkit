import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:guji_toolkit/features/collation/widgets/diff_text_renderer.dart';

void main() {
  group('DiffTextRenderer', () {
    testWidgets('应该渲染普通文本', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: DiffTextRenderer(diff: '春眠不觉晓')),
        ),
      );

      expect(find.textContaining('春眠不觉晓'), findsOneWidget);
    });

    testWidgets('应该渲染删除标记', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: DiffTextRenderer(diff: '春眠[-不-]觉晓')),
        ),
      );

      // 验证 RichText 被渲染
      expect(find.byType(SelectableText), findsOneWidget);
    });

    testWidgets('应该渲染新增标记', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: DiffTextRenderer(diff: '春眠[+不+]觉晓')),
        ),
      );

      expect(find.byType(SelectableText), findsOneWidget);
    });

    testWidgets('应该处理混合标记', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: DiffTextRenderer(diff: '春眠[-不-][+无+]觉晓')),
        ),
      );

      expect(find.byType(SelectableText), findsOneWidget);
    });

    testWidgets('空文本应该正常渲染', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: DiffTextRenderer(diff: '')),
        ),
      );

      expect(find.byType(SelectableText), findsOneWidget);
    });
  });
}
