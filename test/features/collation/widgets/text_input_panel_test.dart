import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:guji_toolkit/features/collation/bloc/bloc.dart';
import 'package:guji_toolkit/features/collation/widgets/text_input_panel.dart';
import 'package:mocktail/mocktail.dart';

class MockCollationBloc extends MockBloc<CollationEvent, CollationState>
    implements CollationBloc {}

class FakeUpdateText1Event extends Fake implements UpdateText1Event {}

class FakeUpdateText2Event extends Fake implements UpdateText2Event {}

void main() {
  late MockCollationBloc mockBloc;

  setUpAll(() {
    registerFallbackValue(FakeUpdateText1Event());
    registerFallbackValue(FakeUpdateText2Event());
  });

  setUp(() {
    mockBloc = MockCollationBloc();
  });

  Widget buildTestWidget() {
    return MaterialApp(
      home: Scaffold(
        body: BlocProvider<CollationBloc>.value(
          value: mockBloc,
          child: const TextInputPanel(),
        ),
      ),
    );
  }

  group('TextInputPanel', () {
    testWidgets('应该显示两个文本输入框', (tester) async {
      when(() => mockBloc.state).thenReturn(const CollationState());
      whenListen(
        mockBloc,
        Stream<CollationState>.fromIterable([const CollationState()]),
      );

      await tester.pumpWidget(buildTestWidget());

      expect(find.byType(TextField), findsNWidgets(2));
      expect(find.text('文本 1'), findsOneWidget);
      expect(find.text('文本 2'), findsOneWidget);
    });

    testWidgets('输入文本1应该触发事件', (tester) async {
      when(() => mockBloc.state).thenReturn(const CollationState());
      whenListen(
        mockBloc,
        Stream<CollationState>.fromIterable([const CollationState()]),
      );

      await tester.pumpWidget(buildTestWidget());

      final textField1 = find.byType(TextField).first;
      await tester.enterText(textField1, '春眠不觉晓');

      verify(() => mockBloc.add(any(that: isA<UpdateText1Event>()))).called(1);
    });

    testWidgets('输入文本2应该触发事件', (tester) async {
      when(() => mockBloc.state).thenReturn(const CollationState());
      whenListen(
        mockBloc,
        Stream<CollationState>.fromIterable([const CollationState()]),
      );

      await tester.pumpWidget(buildTestWidget());

      final textField2 = find.byType(TextField).last;
      await tester.enterText(textField2, '处处闻啼鸟');

      verify(() => mockBloc.add(any(that: isA<UpdateText2Event>()))).called(1);
    });

    testWidgets('状态更新应该同步到文本框', (tester) async {
      when(
        () => mockBloc.state,
      ).thenReturn(const CollationState(text1: '已有文本'));
      whenListen(
        mockBloc,
        Stream<CollationState>.fromIterable([
          const CollationState(text1: '已有文本'),
        ]),
      );

      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      expect(find.text('已有文本'), findsOneWidget);
    });
  });
}
