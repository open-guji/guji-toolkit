import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:guji_toolkit/features/collation/bloc/bloc.dart';
import 'package:guji_toolkit/features/collation/widgets/widgets.dart';
import 'package:mocktail/mocktail.dart';

class MockCollationBloc extends MockBloc<CollationEvent, CollationState>
    implements CollationBloc {}

void main() {
  late MockCollationBloc mockBloc;

  setUp(() {
    mockBloc = MockCollationBloc();
  });

  Widget buildTestWidget() {
    return MaterialApp(
      home: Scaffold(
        body: BlocProvider<CollationBloc>.value(
          value: mockBloc,
          child: const ResultDisplayPanel(),
        ),
      ),
    );
  }

  group('ResultDisplayPanel', () {
    testWidgets('无结果时应该显示提示信息', (tester) async {
      when(() => mockBloc.state).thenReturn(const CollationState());

      await tester.pumpWidget(buildTestWidget());

      expect(find.text('点击"开始对比"查看结果'), findsOneWidget);
    });

    testWidgets('应该显示标签页', (tester) async {
      when(() => mockBloc.state).thenReturn(
        const CollationState(
          result: CollationResult(diff: '测试', similarity: 1.0),
        ),
      );

      await tester.pumpWidget(buildTestWidget());

      expect(find.text('文字对比'), findsOneWidget);
      expect(find.text('统计分析'), findsOneWidget);
    });

    testWidgets('统计分析页应该显示相似度和计数', (tester) async {
      when(() => mockBloc.state).thenReturn(
        const CollationState(
          result: CollationResult(
            diff: '春眠不觉晓',
            similarity: 0.95,
            insertCount: 2,
            deleteCount: 1,
            modifyCount: 3,
          ),
        ),
      );

      await tester.pumpWidget(buildTestWidget());

      // 切换到统计分析标签
      await tester.tap(find.text('统计分析'));
      await tester.pumpAndSettle();

      expect(find.textContaining('95%'), findsOneWidget);
      expect(find.text('2'), findsOneWidget); // insertCount
      expect(find.text('1'), findsOneWidget); // deleteCount
      expect(find.text('3'), findsOneWidget); // modifyCount
    });

    testWidgets('有错误时应该显示错误信息', (tester) async {
      when(() => mockBloc.state).thenReturn(
        const CollationState(
          result: CollationResult(diff: '', similarity: 0, error: '对校失败'),
        ),
      );

      await tester.pumpWidget(buildTestWidget());

      expect(find.textContaining('对校失败'), findsOneWidget);
    });

    testWidgets('差异文本应该在文字对比页被渲染', (tester) async {
      when(() => mockBloc.state).thenReturn(
        const CollationState(
          result: CollationResult(diff: '春眠[-不-]觉晓', similarity: 0.8),
        ),
      );

      await tester.pumpWidget(buildTestWidget());

      // 默认显示文字对比
      expect(find.textContaining('春眠'), findsWidgets);
      expect(find.text('[-删除-]'), findsOneWidget);
    });
  });
}
