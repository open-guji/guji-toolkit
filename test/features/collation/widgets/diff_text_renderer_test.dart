import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:guji_diff/guji_diff.dart';
import 'package:guji_toolkit/features/collation/widgets/widgets.dart';

void main() {
  group('DiffTextRenderer', () {
    testWidgets('应该渲染普通文本', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DiffTextRenderer(
              changes: [
                CollationChange(type: CollationType.equal, text: '春眠不觉晓'),
              ],
              resolutions: {},
              onResolve: (index, resolution) {},
            ),
          ),
        ),
      );

      expect(find.textContaining('春眠不觉晓'), findsOneWidget);
    });

    testWidgets('应该渲染删除标记', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DiffTextRenderer(
              changes: [
                CollationChange(type: CollationType.equal, text: '春眠'),
                CollationChange(type: CollationType.delete, text: '不'),
                CollationChange(type: CollationType.equal, text: '觉晓'),
              ],
              resolutions: {},
              onResolve: (index, resolution) {},
            ),
          ),
        ),
      );

      expect(find.byType(SelectableText), findsOneWidget);
    });

    testWidgets('应该渲染新增标记', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DiffTextRenderer(
              changes: [
                CollationChange(type: CollationType.equal, text: '春眠'),
                CollationChange(type: CollationType.insert, text: '不'),
                CollationChange(type: CollationType.equal, text: '觉晓'),
              ],
              resolutions: {},
              onResolve: (index, resolution) {},
            ),
          ),
        ),
      );

      expect(find.byType(SelectableText), findsOneWidget);
    });

    testWidgets('应该处理混合标记', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DiffTextRenderer(
              changes: [
                CollationChange(type: CollationType.equal, text: '春眠'),
                CollationChange(type: CollationType.delete, text: '不'),
                CollationChange(type: CollationType.insert, text: '无'),
                CollationChange(type: CollationType.equal, text: '觉晓'),
              ],
              resolutions: {},
              onResolve: (index, resolution) {},
            ),
          ),
        ),
      );

      expect(find.byType(SelectableText), findsOneWidget);
    });

    testWidgets('空文本应该正常渲染', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DiffTextRenderer(
              changes: [],
              resolutions: {},
              onResolve: (index, resolution) {},
            ),
          ),
        ),
      );

      expect(find.byType(SelectableText), findsNothing);
    });
  });
}
