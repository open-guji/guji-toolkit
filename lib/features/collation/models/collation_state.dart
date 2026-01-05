/// 对校状态模型
class CollationState {
  final String text1;
  final String text2;
  final bool ignorePunctuation;
  final bool ignoreTraditional;
  final bool isComparing;
  final CollationResult? result;

  const CollationState({
    this.text1 = '',
    this.text2 = '',
    this.ignorePunctuation = true,
    this.ignoreTraditional = true,
    this.isComparing = false,
    this.result,
  });

  CollationState copyWith({
    String? text1,
    String? text2,
    bool? ignorePunctuation,
    bool? ignoreTraditional,
    bool? isComparing,
    CollationResult? result,
  }) {
    return CollationState(
      text1: text1 ?? this.text1,
      text2: text2 ?? this.text2,
      ignorePunctuation: ignorePunctuation ?? this.ignorePunctuation,
      ignoreTraditional: ignoreTraditional ?? this.ignoreTraditional,
      isComparing: isComparing ?? this.isComparing,
      result: result ?? this.result,
    );
  }
}

/// 对校结果模型
class CollationResult {
  final String diff;
  final double similarity;
  final String? error;

  const CollationResult({
    required this.diff,
    required this.similarity,
    this.error,
  });
}
