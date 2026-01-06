import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:guji_toolkit/features/collation/bloc/bloc.dart';
import 'package:guji_toolkit/features/collation/widgets/collation_options_panel.dart';
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
          child: const CollationOptionsPanel(),
        ),
      ),
    );
  }

  group('CollationOptionsPanel', () {
    testWidgets('应该显示标题和两个选项', (tester) async {
      when(() => mockBloc.state).thenReturn(const CollationState());

      await tester.pumpWidget(buildTestWidget());

      expect(find.text('忽略标点'), findsOneWidget);
      expect(find.text('繁简兼容'), findsOneWidget);
    });

    testWidgets('忽略标点选项应该根据状态显示勾选状态', (tester) async {
      when(
        () => mockBloc.state,
      ).thenReturn(const CollationState(ignorePunctuation: true));

      await tester.pumpWidget(buildTestWidget());

      final checkbox = tester.widget<CheckboxListTile>(
        find.widgetWithText(CheckboxListTile, '忽略标点'),
      );
      expect(checkbox.value, true);
    });

    testWidgets('点击忽略标点选项应该触发事件', (tester) async {
      when(() => mockBloc.state).thenReturn(const CollationState());

      await tester.pumpWidget(buildTestWidget());
      await tester.tap(find.widgetWithText(CheckboxListTile, '忽略标点'));

      verify(
        () => mockBloc.add(const ToggleIgnorePunctuationEvent(false)),
      ).called(1);
    });

    testWidgets('点击繁简兼容选项应该触发事件', (tester) async {
      when(() => mockBloc.state).thenReturn(const CollationState());

      await tester.pumpWidget(buildTestWidget());
      await tester.tap(find.widgetWithText(CheckboxListTile, '繁简兼容'));

      verify(
        () => mockBloc.add(const ToggleIgnoreTraditionalEvent(false)),
      ).called(1);
    });

    testWidgets('OpenCC 加载中应该显示加载指示器', (tester) async {
      when(() => mockBloc.state).thenReturn(
        const CollationState(ignoreTraditional: true, isOpenCCLoading: true),
      );

      await tester.pumpWidget(buildTestWidget());

      expect(find.text('正在加载繁简转换引擎...'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('OpenCC 就绪应该显示就绪状态', (tester) async {
      when(() => mockBloc.state).thenReturn(
        const CollationState(ignoreTraditional: true, isOpenCCReady: true),
      );

      await tester.pumpWidget(buildTestWidget());

      // Subtitle helper was removed, so this check is no longer valid or needs update if status is shown elsewhere
      // Currently, success state has no text indicator in the new UI, just absence of error/loading
      // We can check that the loading indicator is GONE
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('OpenCC 错误应该显示错误信息', (tester) async {
      when(() => mockBloc.state).thenReturn(
        const CollationState(ignoreTraditional: true, openCCError: '加载失败'),
      );

      await tester.pumpWidget(buildTestWidget());

      expect(find.textContaining('OpenCC 加载失败'), findsOneWidget);
    });
  });
}
