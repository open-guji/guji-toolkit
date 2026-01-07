import 'package:guji_diff/guji_diff.dart';
import 'package:guji_toolkit/features/collation/models/collation_state.dart';

/// 负责分析对校结果，生成统计报告
class CollationReportAnalyzer {
  /// 分析对校变化列表，提取统计信息
  static CollationResult analyze({
    required List<CollationChange> text1View,
    required List<CollationChange> text2View,
    required List<CollationChange> mergedView,
    required String diff,
    required String unifiedDiff,
  }) {
    // 1. 计算相似度
    final similarity = SimilarityScorer.calculate(mergedView);

    // 2. 详细统计增删改
    int deleteCount = 0;
    int insertCount = 0;
    int modifyCount = 0;
    int i = 0;

    while (i < mergedView.length) {
      final change = mergedView[i];

      // 检查修改模式 (Delete + Insert 对)
      if (change.type == CollationType.delete && i + 1 < mergedView.length) {
        final nextChange = mergedView[i + 1];
        if (nextChange.type == CollationType.insert) {
          // 视为修改，而不是单独的增删
          modifyCount += change.text.length;
          i += 2;
          continue;
        }
      }

      // 处理孤立的变化
      if (change.type == CollationType.delete) {
        deleteCount += change.text.length;
      } else if (change.type == CollationType.insert) {
        insertCount += change.text.length;
      }
      i++;
    }

    // 3. 提取常见改动模式
    final patterns = ChangePatternAnalyzer.analyze(mergedView);

    return CollationResult(
      text1View: text1View,
      text2View: text2View,
      mergedView: mergedView,
      diff: diff,
      unifiedDiff: unifiedDiff,
      similarity: similarity,
      deleteCount: deleteCount,
      insertCount: insertCount,
      modifyCount: modifyCount,
      patterns: patterns,
    );
  }
}
