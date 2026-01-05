import 'package:guji_diff/guji_diff.dart';

/// Mock VerbatimCollation for testing without OpenCC dependency
class MockVerbatimCollation implements VerbatimCollation {
  @override
  List<CollationChange> compare(
    String text1,
    String text2, {
    CollationOptions options = CollationOptions.defaultOptions,
  }) {
    // 简单的字符对比逻辑，不依赖 OpenCC
    if (text1 == text2) {
      return [
        CollationChange(type: CollationType.equal, text: text1),
      ];
    }

    final changes = <CollationChange>[];

    // 简化的 diff 逻辑（仅用于测试）
    if (text1.length > text2.length) {
      changes.add(CollationChange(type: CollationType.equal, text: text2));
      changes.add(CollationChange(
        type: CollationType.delete,
        text: text1.substring(text2.length),
      ));
    } else if (text2.length > text1.length) {
      changes.add(CollationChange(type: CollationType.equal, text: text1));
      changes.add(CollationChange(
        type: CollationType.insert,
        text: text2.substring(text1.length),
      ));
    } else {
      // 逐字符对比
      for (int i = 0; i < text1.length; i++) {
        if (text1[i] == text2[i]) {
          changes.add(CollationChange(
            type: CollationType.equal,
            text: text1[i],
          ));
        } else {
          changes.add(CollationChange(
            type: CollationType.delete,
            text: text1[i],
          ));
          changes.add(CollationChange(
            type: CollationType.insert,
            text: text2[i],
          ));
        }
      }
    }

    return changes;
  }

  @override
  String toUnifiedDiff(String text1, String text2) {
    return 'Mock unified diff';
  }
}

/// Mock SimilarityScorer for testing
class MockSimilarityScorer {
  static double calculate(List<CollationChange> changes) {
    // 简化的相似度计算
    return SimilarityScorer.calculate(changes);
  }
}
