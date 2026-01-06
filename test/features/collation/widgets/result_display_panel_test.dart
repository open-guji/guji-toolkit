import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:guji_toolkit/features/collation/bloc/bloc.dart';
import 'package:guji_toolkit/features/collation/widgets/result_display_panel.dart';
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

      expect(find.text('请输入文本并点击"开始对比"'), findsOneWidget);
    });

    testWidgets('有结果时应该显示相似度', (tester) async {
      when(() => mockBloc.state).thenReturn(
        const CollationState(
          result: CollationResult(diff: '春眠不觉晓', similarity: 1.0),
        ),
      );

      await tester.pumpWidget(buildTestWidget());

      expect(find.textContaining('100'), findsOneWidget);
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

    testWidgets('差异文本应该被渲染', (tester) async {
      when(() => mockBloc.state).thenReturn(
        const CollationState(
          result: CollationResult(diff: '春眠[-不-]觉晓', similarity: 0.8),
        ),
      );

      await tester.pumpWidget(buildTestWidget());

      // 验证 diff 渲染器被使用
      expect(find.textContaining('春眠'), findsWidgets);
    });

    testWidgets('应该显示图例', (tester) async {
      when(() => mockBloc.state).thenReturn(
        const CollationState(
          result: CollationResult(diff: '春眠不觉晓', similarity: 1.0),
        ),
      );

      await tester.pumpWidget(buildTestWidget());

      // 验证图例显示
      expect(find.text('删除'), findsOneWidget);
      expect(find.text('新增'), findsOneWidget);
    });
  });
}
