import 'package:equatable/equatable.dart';
import 'package:guji_diff/guji_diff.dart';

/// 对校状态模型
class CollationState extends Equatable {
  final String text1;
  final String text2;
  final bool ignorePunctuation;
  final bool ignoreTraditional;
  final bool ignoreVariants;
  final bool isComparing;
  final CollationResult? result;
  final List<CollationChange>? changes;

  // OpenCC 加载状态
  final bool isOpenCCLoading;
  final bool isOpenCCReady;
  final String? openCCError;

  const CollationState({
    this.text1 = '',
    this.text2 = '',
    this.ignorePunctuation = true,
    this.ignoreTraditional = true,
    this.ignoreVariants = true,
    this.isComparing = false,
    this.result,
    this.changes,
    this.isOpenCCLoading = false,
    this.isOpenCCReady = false,
    this.openCCError,
  });

  CollationState copyWith({
    String? text1,
    String? text2,
    bool? ignorePunctuation,
    bool? ignoreTraditional,
    bool? ignoreVariants,
    bool? isComparing,
    CollationResult? result,
    List<CollationChange>? changes,
    bool? isOpenCCLoading,
    bool? isOpenCCReady,
    String? openCCError,
  }) {
    return CollationState(
      text1: text1 ?? this.text1,
      text2: text2 ?? this.text2,
      ignorePunctuation: ignorePunctuation ?? this.ignorePunctuation,
      ignoreTraditional: ignoreTraditional ?? this.ignoreTraditional,
      ignoreVariants: ignoreVariants ?? this.ignoreVariants,
      isComparing: isComparing ?? this.isComparing,
      result: result ?? this.result,
      changes: changes ?? this.changes,
      isOpenCCLoading: isOpenCCLoading ?? this.isOpenCCLoading,
      isOpenCCReady: isOpenCCReady ?? this.isOpenCCReady,
      openCCError: openCCError ?? this.openCCError,
    );
  }

  /// 按钮是否应该被禁用
  bool get isButtonDisabled =>
      isComparing || (ignoreTraditional && isOpenCCLoading);

  @override
  List<Object?> get props => [
    text1,
    text2,
    ignorePunctuation,
    ignoreTraditional,
    ignoreVariants,
    isComparing,
    result,
    changes,
    isOpenCCLoading,
    isOpenCCReady,
    openCCError,
  ];
}

/// 对校结果模型
class CollationResult extends Equatable {
  final List<CollationChange> text1View;
  final List<CollationChange> text2View;
  final List<CollationChange> mergedView;
  final String diff; // 原有的 diff 文本，兼容旧代码
  final String unifiedDiff;
  final double similarity;
  final int insertCount;
  final int deleteCount;
  final int modifyCount;
  final Map<String, int> patterns;
  final String? error;

  const CollationResult({
    this.text1View = const [],
    this.text2View = const [],
    this.mergedView = const [],
    required this.diff,
    this.unifiedDiff = '',
    required this.similarity,
    this.insertCount = 0,
    this.deleteCount = 0,
    this.modifyCount = 0,
    this.patterns = const {},
    this.error,
  });

  @override
  List<Object?> get props => [
    text1View,
    text2View,
    mergedView,
    diff,
    unifiedDiff,
    similarity,
    insertCount,
    deleteCount,
    modifyCount,
    patterns,
    error,
  ];
}
