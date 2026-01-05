import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:guji_diff/guji_diff.dart';
import 'package:guji_toolkit/features/collation/models/collation_state.dart';

/// Mock VerbatimCollation - 不依赖 OpenCC native asset
class MockVerbatimCollation extends VerbatimCollation {
  @override
  List<CollationChange> compare(
    String text1,
    String text2, {
    CollationOptions options = CollationOptions.defaultOptions,
  }) {
    // 简单的字符级对比，不使用 OpenCC
    final changes = <CollationChange>[];

    if (text1 == text2) {
      return [
        CollationChange(type: CollationType.equal, text: text1),
      ];
    }

    // 简化的逐字符对比逻辑
    int i = 0, j = 0;
    while (i < text1.length || j < text2.length) {
      if (i < text1.length && j < text2.length && text1[i] == text2[j]) {
        // 相同字符
        changes.add(CollationChange(type: CollationType.equal, text: text1[i]));
        i++;
        j++;
      } else if (i < text1.length && j < text2.length) {
        // 不同字符 - 视为替换
        changes.add(CollationChange(type: CollationType.delete, text: text1[i]));
        changes.add(CollationChange(type: CollationType.insert, text: text2[j]));
        i++;
        j++;
      } else if (i < text1.length) {
        // text1 有多余字符 - 删除
        changes.add(CollationChange(type: CollationType.delete, text: text1[i]));
        i++;
      } else {
        // text2 有多余字符 - 插入
        changes.add(CollationChange(type: CollationType.insert, text: text2[j]));
        j++;
      }
    }

    return changes;
  }
}

/// Mock CollationNotifier - 使用 Mock VerbatimCollation
class MockCollationNotifier extends Notifier<CollationState> {
  @override
  CollationState build() => const CollationState();

  void updateText1(String text) {
    state = state.copyWith(text1: text);
  }

  void updateText2(String text) {
    state = state.copyWith(text2: text);
  }

  void toggleIgnorePunctuation(bool value) {
    state = state.copyWith(ignorePunctuation: value);
  }

  void toggleIgnoreTraditional(bool value) {
    state = state.copyWith(ignoreTraditional: value);
  }

  Future<void> performCollation() async {
    if (state.text1.isEmpty || state.text2.isEmpty) {
      state = state.copyWith(
        result: const CollationResult(
          diff: '',
          similarity: 0,
          error: '请输入两段文本',
        ),
      );
      return;
    }

    state = state.copyWith(isComparing: true);

    try {
      final options = CollationOptions(
        ignorePunctuation: state.ignorePunctuation,
        ignoreTraditional: state.ignoreTraditional,
      );

      // 使用 Mock 实现
      final collation = MockVerbatimCollation();
      final changes = collation.compare(
        state.text1,
        state.text2,
        options: options,
      );

      final similarity = SimilarityScorer.calculate(changes);
      final diffText = _formatChanges(changes);

      state = state.copyWith(
        isComparing: false,
        result: CollationResult(
          diff: diffText,
          similarity: similarity,
        ),
      );
    } catch (e) {
      state = state.copyWith(
        isComparing: false,
        result: CollationResult(
          diff: '',
          similarity: 0,
          error: '对校失败: $e',
        ),
      );
    }
  }

  String _formatChanges(List<CollationChange> changes) {
    final buffer = StringBuffer();
    for (var change in changes) {
      switch (change.type) {
        case CollationType.equal:
          buffer.write(change.text);
          break;
        case CollationType.delete:
          buffer.write('[-${change.text}-]');
          break;
        case CollationType.insert:
          buffer.write('[+${change.text}+]');
          break;
      }
    }
    return buffer.toString();
  }

  void clearResult() {
    state = state.copyWith(
      result: const CollationResult(diff: '', similarity: 0),
    );
  }
}

final mockCollationProvider =
    NotifierProvider<MockCollationNotifier, CollationState>(
  MockCollationNotifier.new,
);

void main() {
  group('CollationNotifier with Mock (单元测试 - 不需要 OpenCC)', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('初始状态应该为默认值', () {
      final state = container.read(mockCollationProvider);

      expect(state.text1, '');
      expect(state.text2, '');
      expect(state.ignorePunctuation, true);
      expect(state.ignoreTraditional, true);
      expect(state.isComparing, false);
      expect(state.result, null);
    });

    test('updateText1 应该更新文本1', () {
      final notifier = container.read(mockCollationProvider.notifier);

      notifier.updateText1('春眠不觉晓');
      final state = container.read(mockCollationProvider);

      expect(state.text1, '春眠不觉晓');
      expect(state.text2, '');
    });

    test('updateText2 应该更新文本2', () {
      final notifier = container.read(mockCollationProvider.notifier);

      notifier.updateText2('处处闻啼鸟');
      final state = container.read(mockCollationProvider);

      expect(state.text2, '处处闻啼鸟');
      expect(state.text1, '');
    });

    test('performCollation 文本为空时应该返回错误', () async {
      final notifier = container.read(mockCollationProvider.notifier);

      await notifier.performCollation();
      final state = container.read(mockCollationProvider);

      expect(state.result, isNotNull);
      expect(state.result!.error, '请输入两段文本');
      expect(state.isComparing, false);
    });

    test('performCollation 相同文本应该返回100%相似度', () async {
      final notifier = container.read(mockCollationProvider.notifier);

      notifier.updateText1('春眠不觉晓');
      notifier.updateText2('春眠不觉晓');
      await notifier.performCollation();
      final state = container.read(mockCollationProvider);

      expect(state.result, isNotNull);
      expect(state.result!.error, null);
      expect(state.result!.similarity, 1.0);
      expect(state.result!.diff, '春眠不觉晓');
      expect(state.isComparing, false);
    });

    test('performCollation 不同文本应该返回差异', () async {
      final notifier = container.read(mockCollationProvider.notifier);

      notifier.updateText1('春眠不觉晓');
      notifier.updateText2('春眠不覺曉');
      await notifier.performCollation();
      final state = container.read(mockCollationProvider);

      expect(state.result, isNotNull);
      expect(state.result!.error, null);
      expect(state.result!.similarity, lessThan(1.0));
      // 由于是简单的字符对比，会检测到差异
      expect(state.result!.diff, isNot('春眠不觉晓'));
    });

    test('performCollation 完全不同的文本应该返回低相似度', () async {
      final notifier = container.read(mockCollationProvider.notifier);

      notifier.updateText1('春眠不觉晓');
      notifier.updateText2('床前明月光');
      await notifier.performCollation();
      final state = container.read(mockCollationProvider);

      expect(state.result, isNotNull);
      expect(state.result!.error, null);
      expect(state.result!.similarity, lessThan(0.5));
    });

    test('performCollation 部分相同的文本应该返回中等相似度', () async {
      final notifier = container.read(mockCollationProvider.notifier);

      notifier.updateText1('春眠不觉晓处处闻啼鸟');
      notifier.updateText2('春眠不觉晓夜来风雨声');
      await notifier.performCollation();
      final state = container.read(mockCollationProvider);

      expect(state.result, isNotNull);
      expect(state.result!.similarity, greaterThan(0.3));
      expect(state.result!.similarity, lessThan(1.0));
    });

    test('clearResult 应该清空结果', () async {
      final notifier = container.read(mockCollationProvider.notifier);

      notifier.updateText1('春眠不觉晓');
      notifier.updateText2('春眠不覺曉');
      await notifier.performCollation();

      notifier.clearResult();
      final state = container.read(mockCollationProvider);

      expect(state.result!.diff, '');
      expect(state.result!.similarity, 0);
      expect(state.text1, '春眠不觉晓');
      expect(state.text2, '春眠不覺曉');
    });

    test('连续多次对校应该正常工作', () async {
      final notifier = container.read(mockCollationProvider.notifier);

      // 第一次对校
      notifier.updateText1('春眠不觉晓');
      notifier.updateText2('春眠不覺曉');
      await notifier.performCollation();
      final result1 = container.read(mockCollationProvider).result!;
      expect(result1.error, null);

      // 第二次对校
      notifier.updateText1('床前明月光');
      notifier.updateText2('床前明月光');
      await notifier.performCollation();
      final result2 = container.read(mockCollationProvider).result!;
      expect(result2.error, null);
      expect(result2.similarity, 1.0);

      // 第三次对校
      notifier.updateText1('疑是地上霜');
      notifier.updateText2('疑似地上霜');
      await notifier.performCollation();
      final result3 = container.read(mockCollationProvider).result!;
      expect(result3.error, null);
      expect(result3.similarity, lessThan(1.0));
    });
  });
}
