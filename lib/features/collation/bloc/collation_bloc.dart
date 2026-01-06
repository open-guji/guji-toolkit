import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guji_diff/guji_diff.dart';
import 'package:guji_toolkit/features/collation/bloc/collation_event.dart';
import 'package:guji_toolkit/features/collation/models/collation_state.dart';

/// 古籍对校 BLoC
class CollationBloc extends Bloc<CollationEvent, CollationState> {
  final VerbatimCollation _collation;

  CollationBloc({VerbatimCollation? collation})
    : _collation = collation ?? VerbatimCollation(),
      super(const CollationState()) {
    // 注册事件处理器
    on<UpdateText1Event>(_onUpdateText1);
    on<UpdateText2Event>(_onUpdateText2);
    on<ToggleIgnorePunctuationEvent>(_onToggleIgnorePunctuation);
    on<ToggleIgnoreTraditionalEvent>(_onToggleIgnoreTraditional);
    on<PerformCollationEvent>(_onPerformCollation);
    on<LoadExampleEvent>(_onLoadExample);
    on<ClearResultEvent>(_onClearResult);
    on<CheckOpenCCStatusEvent>(_onCheckOpenCCStatus);

    // 初始化时检查 OpenCC 状态
    add(const CheckOpenCCStatusEvent());
  }

  /// 处理检查 OpenCC 状态事件
  Future<void> _onCheckOpenCCStatus(
    CheckOpenCCStatusEvent event,
    Emitter<CollationState> emit,
  ) async {
    emit(state.copyWith(isOpenCCLoading: true));
    try {
      await TextNormalizer.ensureReady();
      emit(state.copyWith(isOpenCCLoading: false, isOpenCCReady: true));
    } catch (e) {
      emit(
        state.copyWith(
          isOpenCCLoading: false,
          isOpenCCReady: false,
          openCCError: e.toString(),
        ),
      );
    }
  }

  /// 处理加载示例事件
  void _onLoadExample(LoadExampleEvent event, Emitter<CollationState> emit) {
    emit(
      state.copyWith(
        text1: event.text1,
        text2: event.text2,
        result: const CollationResult(diff: '', similarity: 0),
      ),
    );
  }

  /// 处理更新文本1事件
  void _onUpdateText1(UpdateText1Event event, Emitter<CollationState> emit) {
    emit(state.copyWith(text1: event.text));
  }

  /// 处理更新文本2事件
  void _onUpdateText2(UpdateText2Event event, Emitter<CollationState> emit) {
    emit(state.copyWith(text2: event.text));
  }

  /// 处理切换忽略标点选项事件
  void _onToggleIgnorePunctuation(
    ToggleIgnorePunctuationEvent event,
    Emitter<CollationState> emit,
  ) {
    emit(state.copyWith(ignorePunctuation: event.value));
  }

  /// 处理切换繁简兼容选项事件
  void _onToggleIgnoreTraditional(
    ToggleIgnoreTraditionalEvent event,
    Emitter<CollationState> emit,
  ) {
    emit(state.copyWith(ignoreTraditional: event.value));
  }

  /// 处理执行对校事件
  Future<void> _onPerformCollation(
    PerformCollationEvent event,
    Emitter<CollationState> emit,
  ) async {
    // 验证输入
    if (state.text1.isEmpty || state.text2.isEmpty) {
      emit(
        state.copyWith(
          result: const CollationResult(
            diff: '',
            similarity: 0,
            error: '请输入两段文本',
          ),
        ),
      );
      return;
    }

    // 开始对比
    emit(state.copyWith(isComparing: true));

    try {
      // 如果启用了繁简兼容，确保 OpenCC 已就绪（特别是 Web 平台需要异步加载脚本）
      if (state.ignoreTraditional && !state.isOpenCCReady) {
        await TextNormalizer.ensureReady();
      }

      // 创建对校选项
      final options = CollationOptions(
        ignorePunctuation: state.ignorePunctuation,
        ignoreTraditional: state.ignoreTraditional,
      );

      // 执行逐字对校
      final changes = _collation.compare(
        state.text1,
        state.text2,
        options: options,
      );

      // 计算相似度
      final similarity = SimilarityScorer.calculate(changes);

      // 将差异列表转换为可读文本
      final diffText = _formatChanges(changes);

      emit(
        state.copyWith(
          isComparing: false,
          result: CollationResult(diff: diffText, similarity: similarity),
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isComparing: false,
          result: CollationResult(diff: '', similarity: 0, error: '对校失败: $e'),
        ),
      );
    }
  }

  /// 处理清空结果事件
  void _onClearResult(ClearResultEvent event, Emitter<CollationState> emit) {
    emit(
      state.copyWith(result: const CollationResult(diff: '', similarity: 0)),
    );
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
}
