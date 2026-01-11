import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'punctuation_event.dart';
import '../models/punctuation_state.dart';
import '../models/punctuation_model.dart';
import '../engine/punctuation_engine.dart';

class PunctuationBloc extends Bloc<PunctuationEvent, PunctuationState> {
  final PunctuationEngine engine;

  PunctuationBloc({required this.engine}) : super(const PunctuationState()) {
    on<UpdateOriginalTextEvent>(_onUpdateOriginalText);
    on<SelectModelEvent>(_onSelectModel);
    on<PerformPunctuationEvent>(_onPerformPunctuation);
    on<LoadPunctuationExampleEvent>(_onLoadExample);
    on<ClearPunctuationResultEvent>(_onClearResult);
    on<UpdateDownloadSourceEvent>(_onUpdateDownloadSource);
    on<UpdateProgressEvent>(_onUpdateProgress);
    on<PunctuationStarted>(_onStarted);
    on<ExportModelEvent>(_onExportModel);
    on<InstallModelEvent>(_onInstallModel);
  }

  void _onUpdateOriginalText(
    UpdateOriginalTextEvent event,
    Emitter<PunctuationState> emit,
  ) {
    emit(
      state.copyWith(
        originalText: event.text,
        punctuatedText: '', // Clear punctuated text when original changes
      ),
    );
  }

  void _onSelectModel(SelectModelEvent event, Emitter<PunctuationState> emit) {
    emit(state.copyWith(selectedModel: event.modelName));
  }

  Future<void> _onPerformPunctuation(
    PerformPunctuationEvent event,
    Emitter<PunctuationState> emit,
  ) async {
    if (state.originalText.isEmpty) {
      emit(state.copyWith(error: () => '请输入待标点文本'));
      return;
    }

    emit(state.copyWith(isProcessing: true, progress: 0.0, error: () => null));

    try {
      // 监听下载/加载进度
      final progressSubscription = engine
          .downloadModel(state.selectedModel, source: state.downloadSource)
          .listen((progress) {
            add(UpdateProgressEvent(progress));
          });

      final result = await engine.punctuate(
        state.originalText,
        state.selectedModel,
      );

      await progressSubscription.cancel();

      emit(
        state.copyWith(
          punctuatedText: result,
          isProcessing: false,
          progress: 1.0,
          installedModels: {
            ...state.installedModels,
            state.selectedModel,
          }.toList(),
        ),
      );
    } catch (e) {
      emit(state.copyWith(isProcessing: false, error: () => '标点失败: $e'));
    }
  }

  void _onUpdateProgress(
    UpdateProgressEvent event,
    Emitter<PunctuationState> emit,
  ) {
    emit(state.copyWith(progress: event.progress));
  }

  void _onUpdateDownloadSource(
    UpdateDownloadSourceEvent event,
    Emitter<PunctuationState> emit,
  ) {
    emit(state.copyWith(downloadSource: event.source));
  }

  void _onLoadExample(
    LoadPunctuationExampleEvent event,
    Emitter<PunctuationState> emit,
  ) {
    emit(
      state.copyWith(
        originalText: event.originalText,
        punctuatedText: '', // Only load original text, clear punctuated version
        error: () => null,
      ),
    );
  }

  void _onClearResult(
    ClearPunctuationResultEvent event,
    Emitter<PunctuationState> emit,
  ) {
    emit(
      state.copyWith(originalText: '', punctuatedText: '', error: () => null),
    );
  }

  Future<void> _onStarted(
    PunctuationStarted event,
    Emitter<PunctuationState> emit,
  ) async {
    try {
      // Load model configuration
      final String configJson = await rootBundle.loadString(
        'assets/models/model_config.json',
      );
      final List<dynamic> decoded = json.decode(configJson);
      final List<PunctuationModel> models = decoded
          .map((json) => PunctuationModel.fromJson(json))
          .toList();

      final cachedModels = await engine.getCachedModels();

      emit(
        state.copyWith(
          availableModels: models,
          installedModels: cachedModels,
          // If default isn't in available models (unlikely but safe), use the first one
          selectedModel: models.any((m) => m.id == state.selectedModel)
              ? state.selectedModel
              : (models.isNotEmpty ? models.first.id : state.selectedModel),
        ),
      );
    } catch (e) {
      // Ignore initial check errors or log them
    }
  }

  Future<void> _onExportModel(
    ExportModelEvent event,
    Emitter<PunctuationState> emit,
  ) async {
    try {
      await engine.exportModel(event.modelName);
    } catch (e) {
      emit(state.copyWith(error: () => '导出模型失败: $e'));
    }
  }

  Future<void> _onInstallModel(
    InstallModelEvent event,
    Emitter<PunctuationState> emit,
  ) async {
    emit(
      state.copyWith(
        selectedModel: event.modelName,
        isProcessing: true,
        progress: 0.0,
        error: () => null,
      ),
    );

    try {
      final progressSubscription = engine
          .downloadModel(event.modelName, source: state.downloadSource)
          .listen((progress) {
            add(UpdateProgressEvent(progress));
          });

      await engine.loadModel(event.modelName);

      await progressSubscription.cancel();

      emit(
        state.copyWith(
          isProcessing: false,
          progress: 1.0,
          installedModels: {...state.installedModels, event.modelName}.toList(),
        ),
      );
    } catch (e) {
      emit(state.copyWith(isProcessing: false, error: () => '安装失败: $e'));
    }
  }
}
