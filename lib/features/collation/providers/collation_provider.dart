import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:guji_diff/guji_diff.dart';
import 'package:guji_toolkit/features/collation/models/collation_state.dart';

/// 对校状态管理
class CollationNotifier extends Notifier<CollationState> {
  @override
  CollationState build() => const CollationState();

  /// 更新文本1
  void updateText1(String text) {
    state = state.copyWith(text1: text);
  }

  /// 更新文本2
  void updateText2(String text) {
    state = state.copyWith(text2: text);
  }

  /// 切换忽略标点选项
  void toggleIgnorePunctuation(bool value) {
    state = state.copyWith(ignorePunctuation: value);
  }

  /// 切换繁简兼容选项
  void toggleIgnoreTraditional(bool value) {
    state = state.copyWith(ignoreTraditional: value);
  }

  /// 执行对校
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
      // 创建对校选项
      final options = CollationOptions(
        ignorePunctuation: state.ignorePunctuation,
        ignoreTraditional: state.ignoreTraditional,
      );

      // 执行逐字对校
      final collation = VerbatimCollation();
      final changes = collation.compare(
        state.text1,
        state.text2,
        options: options,
      );

      // 计算相似度
      final similarity = SimilarityScorer.calculate(changes);

      // 将差异列表转换为可读文本
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

  /// 格式化差异列表为可读文本
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

  /// 清空结果
  void clearResult() {
    state = state.copyWith(
      result: const CollationResult(diff: '', similarity: 0),
    );
  }
}

/// 对校状态 Provider
final collationProvider =
    NotifierProvider<CollationNotifier, CollationState>(CollationNotifier.new);
