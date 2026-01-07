import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guji_diff/guji_diff.dart';
import 'package:guji_toolkit/features/collation/bloc/collation_event.dart';
import 'package:guji_toolkit/features/collation/models/collation_state.dart';

import 'package:guji_toolkit/features/collation/services/opencc_service.dart';
import 'package:guji_toolkit/features/collation/services/collation_report_analyzer.dart';

/// 文本对校 BLoC
class CollationBloc extends Bloc<CollationEvent, CollationState> {
  final VerbatimCollation _collation;
  final OpenCCService _openCCService;

  CollationBloc({VerbatimCollation? collation, OpenCCService? openCCService})
    : _collation = collation ?? VerbatimCollation(),
      _openCCService = openCCService ?? RealOpenCCService(),
      super(const CollationState()) {
    // 注册事件处理器
    on<UpdateText1Event>(_onUpdateText1);
    on<UpdateText2Event>(_onUpdateText2);
    on<ToggleIgnorePunctuationEvent>(_onToggleIgnorePunctuation);
    on<ToggleIgnoreTraditionalEvent>(_onToggleIgnoreTraditional);
    on<ToggleIgnoreVariantsEvent>(_onToggleIgnoreVariants);
    on<PerformCollationEvent>(_onPerformCollation);
    on<LoadExampleEvent>(_onLoadExample);
    on<ClearResultEvent>(_onClearResult);
    on<ResolveDiffEvent>(_onResolveDiff);
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
      await _openCCService.ensureReady();
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
        result: () => null, // 清空之前的对比结果
        changes: () => const [], // 清空之前的对比结果
        resolutions: const {}, // 清空之前的解决状态
      ),
    );
  }

  /// 处理更新文本1事件
  void _onUpdateText1(UpdateText1Event event, Emitter<CollationState> emit) {
    emit(
      state.copyWith(
        text1: event.text,
        result: () => null, // 清空对比结果
        changes: () => const [],
        resolutions: const {},
      ),
    );
  }

  /// 处理更新文本2事件
  void _onUpdateText2(UpdateText2Event event, Emitter<CollationState> emit) {
    emit(
      state.copyWith(
        text2: event.text,
        result: () => null, // 清空对比结果
        changes: () => const [],
        resolutions: const {},
      ),
    );
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
    if (event.value) {
      // 如果开启了繁简兼容，则强制开启异体字兼容
      emit(state.copyWith(ignoreTraditional: true, ignoreVariants: true));
    } else {
      emit(state.copyWith(ignoreTraditional: false));
    }
  }

  /// 处理切换异体字兼容选项事件
  void _onToggleIgnoreVariants(
    ToggleIgnoreVariantsEvent event,
    Emitter<CollationState> emit,
  ) {
    emit(state.copyWith(ignoreVariants: event.value));
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
          result: () => const CollationResult(
            diff: '',
            similarity: 0.0,
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
        await _openCCService.ensureReady();
      }

      // 创建对校选项
      final options = CollationOptions(
        ignorePunctuation: state.ignorePunctuation,
        ignoreTraditional: state.ignoreTraditional,
        ignoreVariants: state.ignoreVariants,
      );

      // 执行逐字对校
      final fullResult = _collation.compareWithFullContext(
        state.text1,
        state.text2,
        options: options,
      );

      // 使用分析服务生成最终报告
      final collationResult = CollationReportAnalyzer.analyze(
        text1View: fullResult.text1View,
        text2View: fullResult.text2View,
        mergedView: fullResult.mergedView,
        diff: _formatChanges(fullResult.mergedView),
        unifiedDiff: _formatUnifiedDiff(
          fullResult.mergedView,
          state.text1,
          state.text2,
        ),
      );

      emit(
        state.copyWith(
          isComparing: false,
          changes: () => fullResult.mergedView,
          resolutions: const {}, // 新的对比开始，清空之前的解决状态
          result: () => collationResult,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isComparing: false,
          result: () => CollationResult(diff: '', similarity: 0.0, error: '对校失败: $e'),
        ),
      );
    }
  }

  /// 处理清空结果事件
  void _onClearResult(ClearResultEvent event, Emitter<CollationState> emit) {
    emit(
      state.copyWith(result: () => null, changes: () => const [], resolutions: const {}),
    );
  }

  /// 处理解决差异事件
  void _onResolveDiff(ResolveDiffEvent event, Emitter<CollationState> emit) {
    final newResolutions = Map<int, DiffResolution>.from(state.resolutions);
    newResolutions[event.index] = event.resolution;
    emit(state.copyWith(resolutions: newResolutions));
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

  /// 格式化差异列表为 Unified Diff 格式（只显示不同的部分）
  String _formatUnifiedDiff(
    List<CollationChange> changes,
    String text1,
    String text2,
  ) {
    final buffer = StringBuffer();
    buffer.writeln('--- 底本');
    buffer.writeln('+++ 校本');
    buffer.writeln('@@ 文本差异 @@');

    bool hasChanges = false;

    for (var change in changes) {
      if (change.type == CollationType.delete) {
        hasChanges = true;
        buffer.writeln('-${change.text}');
      } else if (change.type == CollationType.insert) {
        hasChanges = true;
        buffer.writeln('+${change.text}');
      }
    }

    if (!hasChanges) {
      buffer.writeln('(没有差异)');
    }

    return buffer.toString();
  }
}
