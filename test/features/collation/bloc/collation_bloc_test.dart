import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:guji_toolkit/features/collation/bloc/bloc.dart';

void main() {
  group('CollationBloc', () {
    late CollationBloc bloc;

    setUp(() {
      bloc = CollationBloc();
    });

    tearDown(() {
      bloc.close();
    });

    test('初始状态应该为默认值', () {
      // 由于构造函数中会触发 CheckOpenCCStatusEvent，状态可能会立即变为 loading
      expect(
        bloc.state,
        anyOf(
          const CollationState(),
          const CollationState(isOpenCCLoading: true),
        ),
      );
      expect(bloc.state.text1, '');
      expect(bloc.state.text2, '');
      expect(bloc.state.ignorePunctuation, true);
      expect(bloc.state.ignoreTraditional, true);
      expect(bloc.state.isComparing, false);
      expect(bloc.state.result, null);
    });

    blocTest<CollationBloc, CollationState>(
      '应该更新文本1',
      build: () => bloc,
      act: (bloc) => bloc.add(const UpdateText1Event('春眠不觉晓')),
      expect: () => [const CollationState(text1: '春眠不觉晓')],
    );

    blocTest<CollationBloc, CollationState>(
      '应该更新文本2',
      build: () => bloc,
      act: (bloc) => bloc.add(const UpdateText2Event('处处闻啼鸟')),
      expect: () => [const CollationState(text2: '处处闻啼鸟')],
    );

    blocTest<CollationBloc, CollationState>(
      '应该切换忽略标点选项',
      build: () => bloc,
      act: (bloc) => bloc.add(const ToggleIgnorePunctuationEvent(false)),
      expect: () => [const CollationState(ignorePunctuation: false)],
    );

    blocTest<CollationBloc, CollationState>(
      '应该切换繁简兼容选项',
      build: () => bloc,
      act: (bloc) => bloc.add(const ToggleIgnoreTraditionalEvent(false)),
      expect: () => [const CollationState(ignoreTraditional: false)],
    );

    blocTest<CollationBloc, CollationState>(
      '空文本执行对校应该返回错误',
      build: () => bloc,
      act: (bloc) => bloc.add(const PerformCollationEvent()),
      expect: () => [
        const CollationState(
          result: CollationResult(diff: '', similarity: 0, error: '请输入两段文本'),
        ),
      ],
    );

    blocTest<CollationBloc, CollationState>(
      '相同文本应该返回100%相似度',
      build: () => bloc,
      seed: () => const CollationState(text1: '春眠不觉晓', text2: '春眠不觉晓'),
      act: (bloc) => bloc.add(const PerformCollationEvent()),
      expect: () => [
        const CollationState(text1: '春眠不觉晓', text2: '春眠不觉晓', isComparing: true),
        isA<CollationState>()
            .having((s) => s.isComparing, 'isComparing', false)
            .having((s) => s.result?.error, 'error', null)
            .having((s) => s.result?.similarity, 'similarity', 1.0)
            .having((s) => s.result?.diff, 'diff', '春眠不觉晓'),
      ],
    );

    blocTest<CollationBloc, CollationState>(
      '完全不同的文本应该返回低相似度',
      build: () => bloc,
      seed: () => const CollationState(text1: '春眠不觉晓', text2: '床前明月光'),
      act: (bloc) => bloc.add(const PerformCollationEvent()),
      expect: () => [
        const CollationState(text1: '春眠不觉晓', text2: '床前明月光', isComparing: true),
        isA<CollationState>()
            .having((s) => s.isComparing, 'isComparing', false)
            .having((s) => s.result?.error, 'error', null)
            .having((s) => s.result?.similarity, 'similarity', lessThan(0.5)),
      ],
    );

    blocTest<CollationBloc, CollationState>(
      '清空结果应该重置结果',
      build: () => bloc,
      seed: () => const CollationState(
        text1: '春眠不觉晓',
        text2: '春眠不觉晓',
        result: CollationResult(diff: '春眠不觉晓', similarity: 1.0),
      ),
      act: (bloc) => bloc.add(const ClearResultEvent()),
      expect: () => [
        const CollationState(
          text1: '春眠不觉晓',
          text2: '春眠不觉晓',
          result: CollationResult(diff: '', similarity: 0),
        ),
      ],
    );

    blocTest<CollationBloc, CollationState>(
      '连续多个事件应该正常处理',
      build: () => bloc,
      act: (bloc) => bloc
        ..add(const UpdateText1Event('春眠不觉晓'))
        ..add(const UpdateText2Event('处处闻啼鸟'))
        ..add(const ToggleIgnorePunctuationEvent(false)),
      expect: () => [
        const CollationState(text1: '春眠不觉晓'),
        const CollationState(text1: '春眠不觉晓', text2: '处处闻啼鸟'),
        const CollationState(
          text1: '春眠不觉晓',
          text2: '处处闻啼鸟',
          ignorePunctuation: false,
        ),
      ],
    );
  });
}
