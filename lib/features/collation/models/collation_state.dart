import 'package:equatable/equatable.dart';

/// 对校状态模型
class CollationState extends Equatable {
  final String text1;
  final String text2;
  final bool ignorePunctuation;
  final bool ignoreTraditional;
  final bool ignoreVariants;
  final bool isComparing;
  final CollationResult? result;

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
    isOpenCCLoading,
    isOpenCCReady,
    openCCError,
  ];
}

/// 对校结果模型
class CollationResult extends Equatable {
  final String diff;
  final double similarity;
  final String? error;

  const CollationResult({
    required this.diff,
    required this.similarity,
    this.error,
  });

  @override
  List<Object?> get props => [diff, similarity, error];
}
