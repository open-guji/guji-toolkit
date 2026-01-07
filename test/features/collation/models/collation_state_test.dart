import 'package:flutter_test/flutter_test.dart';
import 'package:guji_toolkit/features/collation/models/collation_state.dart';

void main() {
  group('CollationState', () {
    test('应该创建默认的初始状态', () {
      const state = CollationState();

      expect(state.text1, '');
      expect(state.text2, '');
      expect(state.ignorePunctuation, false);
      expect(state.ignoreTraditional, false);
      expect(state.isComparing, false);
      expect(state.result, null);
    });

    test('应该创建自定义初始状态', () {
      const state = CollationState(
        text1: '春眠不觉晓',
        text2: '春眠不覺曉',
        ignorePunctuation: false,
        ignoreTraditional: false,
        isComparing: true,
      );

      expect(state.text1, '春眠不觉晓');
      expect(state.text2, '春眠不覺曉');
      expect(state.ignorePunctuation, false);
      expect(state.ignoreTraditional, false);
      expect(state.isComparing, true);
    });

    test('copyWith 应该更新指定字段', () {
      const state = CollationState();
      final newState = state.copyWith(text1: '新文本', isComparing: true);

      expect(newState.text1, '新文本');
      expect(newState.text2, ''); // 未改变
      expect(newState.isComparing, true);
      expect(newState.ignorePunctuation, false); // 未改变
    });

    test('copyWith 应该保留未指定的字段', () {
      const state = CollationState(
        text1: '原文本1',
        text2: '原文本2',
        ignorePunctuation: false,
      );
      final newState = state.copyWith(isComparing: true);

      expect(newState.text1, '原文本1');
      expect(newState.text2, '原文本2');
      expect(newState.ignorePunctuation, false);
      expect(newState.isComparing, true);
    });

    test('copyWith 不传参数应该返回相同值的新实例', () {
      const state = CollationState(text1: '测试');
      final newState = state.copyWith();

      expect(newState.text1, state.text1);
      expect(newState.text2, state.text2);
      expect(newState.ignorePunctuation, state.ignorePunctuation);
    });
  });

  group('CollationResult', () {
    test('应该创建成功的对比结果', () {
      const result = CollationResult(
        diff: '春眠不[-觉-][+覺+][-晓-][+曉+]',
        similarity: 0.6,
      );

      expect(result.diff, '春眠不[-觉-][+覺+][-晓-][+曉+]');
      expect(result.similarity, 0.6);
      expect(result.error, null);
    });

    test('应该创建包含错误的结果', () {
      const result = CollationResult(
        diff: '',
        similarity: 0,
        error: '对校失败: 文本为空',
      );

      expect(result.diff, '');
      expect(result.similarity, 0);
      expect(result.error, '对校失败: 文本为空');
    });

    test('相似度应该在 0 到 1 之间', () {
      const result1 = CollationResult(diff: '', similarity: 0.0);
      const result2 = CollationResult(diff: '', similarity: 1.0);
      const result3 = CollationResult(diff: '', similarity: 0.5);

      expect(result1.similarity, 0.0);
      expect(result2.similarity, 1.0);
      expect(result3.similarity, 0.5);
    });
  });
}
