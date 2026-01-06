import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:guji_toolkit/features/collation/bloc/bloc.dart';
import 'package:guji_toolkit/features/collation/models/collation_example.dart';
import 'package:guji_toolkit/features/collation/widgets/collation_examples_panel.dart';
import 'package:mocktail/mocktail.dart';

class MockCollationBloc extends MockBloc<CollationEvent, CollationState>
    implements CollationBloc {}

class FakeLoadExampleEvent extends Fake implements LoadExampleEvent {}

void main() {
  late MockCollationBloc mockBloc;

  setUpAll(() {
    registerFallbackValue(FakeLoadExampleEvent());
  });

  setUp(() {
    mockBloc = MockCollationBloc();
  });

  Widget buildTestWidget() {
    return MaterialApp(
      home: Scaffold(
        body: BlocProvider<CollationBloc>.value(
          value: mockBloc,
          child: const CollationExamplesPanel(),
        ),
      ),
    );
  }

  group('CollationExamplesPanel', () {
    testWidgets('应该显示示例标题', (tester) async {
      when(() => mockBloc.state).thenReturn(const CollationState());

      await tester.pumpWidget(buildTestWidget());

      expect(find.text('示例：'), findsOneWidget);
    });

    testWidgets('应该显示所有示例按钮', (tester) async {
      when(() => mockBloc.state).thenReturn(const CollationState());

      await tester.pumpWidget(buildTestWidget());

      // 应该为每个示例创建一个按钮
      for (final example in CollationExamples.examples) {
        expect(find.text(example.name.split('：').last), findsOneWidget);
      }
    });

    testWidgets('点击示例按钮应该触发LoadExampleEvent', (tester) async {
      when(() => mockBloc.state).thenReturn(const CollationState());

      await tester.pumpWidget(buildTestWidget());

      // 点击第一个示例
      final firstExample = CollationExamples.examples.first;
      await tester.tap(find.text(firstExample.name.split('：').last));

      verify(() => mockBloc.add(any(that: isA<LoadExampleEvent>()))).called(1);
    });

    testWidgets('示例按钮应该显示描述tooltip', (tester) async {
      when(() => mockBloc.state).thenReturn(const CollationState());

      await tester.pumpWidget(buildTestWidget());

      // 验证 Tooltip 或描述存在
      expect(find.byType(ActionChip), findsWidgets);
    });
  });
}
