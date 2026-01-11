import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'punctuation_event.dart';
import '../models/punctuation_state.dart';
import '../models/punctuation_model.dart';
import '../models/punctuation_config.dart';
import '../engine/punctuation_engine.dart';
import '../engine/llm_punctuation_engine.dart';

class PunctuationBloc extends Bloc<PunctuationEvent, PunctuationState> {
  final PunctuationEngine engine;
  final PunctuationEngine llmEngine = LLMPunctuationEngine();

  PunctuationBloc({required this.engine}) : super(const PunctuationState()) {
    on<UpdateOriginalTextEvent>(_onUpdateOriginalText);
    on<SelectModelEvent>(_onSelectModel);
    on<PerformPunctuationEvent>(_onPerformPunctuation);
    on<LoadPunctuationExampleEvent>(_onLoadExample);
    on<ClearPunctuationResultEvent>(_onClearResult);
    on<UpdateDownloadSourceEvent>(_onUpdateDownloadSource);
    on<UpdateProgressEvent>(_onUpdateProgress);
    on<PunctuationStarted>(_onStarted);
    on<InstallModelEvent>(_onInstallModel);
    on<DeleteModelEvent>(_onDeleteModel);
    on<SwitchMethodEvent>(_onSwitchMethod);
    on<UpdateLLMConfigEvent>(_onUpdateLLMConfig);
  }

  void _onSwitchMethod(
    SwitchMethodEvent event,
    Emitter<PunctuationState> emit,
  ) {
    emit(state.copyWith(selectedMethod: event.method));
  }

  void _onUpdateLLMConfig(
    UpdateLLMConfigEvent event,
    Emitter<PunctuationState> emit,
  ) {
    emit(
      state.copyWith(
        llmConfig: state.llmConfig.copyWith(
          serviceType: event.config.serviceType,
          selectedProvider: event.config.selectedProvider,
          provider: event.config.provider,
          apiKey: event.config.apiKey,
          baseUrl: event.config.baseUrl,
          modelName: event.config.modelName,
        ),
      ),
    );
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

    if (state.selectedMethod == PunctuationMethod.specialized) {
      // Specialized Model Logic
      if (!state.isModelAvailable(state.selectedModel) &&
          !state.installedModels.contains(state.selectedModel)) {
        emit(state.copyWith(error: () => '当前下载源暂不支持该模型，请切换到官方源'));
        return;
      }

      emit(
        state.copyWith(isProcessing: true, progress: 0.0, error: () => null),
      );

      try {
        final model = state.availableModels.firstWhere(
          (m) => m.id == state.selectedModel,
        );
        final modelRepoPath = state.getModelRepoPath(state.selectedModel);
        final progressSubscription = engine
            .downloadModel(modelRepoPath, source: state.downloadSource)
            .listen((progress) {
              add(UpdateProgressEvent(progress));
            });

        final result = await engine.punctuate(
          state.originalText,
          modelRepoPath,
          modelType: model.type,
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
    } else {
      // LLM Logic
      emit(
        state.copyWith(isProcessing: true, progress: 0.0, error: () => null),
      );

      try {
        final result = await llmEngine.punctuate(
          state.originalText,
          state.llmConfig.modelName,
          extraConfig: {
            'provider': state.llmConfig.provider,
            'apiKey': state.llmConfig.apiKey,
            'baseUrl': state.llmConfig.baseUrl,
          },
        );

        emit(
          state.copyWith(
            punctuatedText: result,
            isProcessing: false,
            progress: 1.0,
          ),
        );
      } catch (e) {
        emit(state.copyWith(isProcessing: false, error: () => 'LLM 标点失败: $e'));
      }
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

      final cachedModels = await Future.wait(
        models.map((m) {
          final repoPath = m.onnxRepo ?? m.id;
          return engine.isModelCached(repoPath);
        }),
      );

      final List<String> installedIds = [];
      for (int i = 0; i < models.length; i++) {
        if (cachedModels[i]) installedIds.add(models[i].id);
      }

      emit(
        state.copyWith(
          availableModels: models,
          installedModels: installedIds,
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

  Future<void> _onInstallModel(
    InstallModelEvent event,
    Emitter<PunctuationState> emit,
  ) async {
    if (!state.isModelAvailable(event.modelName)) {
      emit(state.copyWith(error: () => '当前下载源暂不支持该模型，请切换到官方源'));
      return;
    }

    emit(
      state.copyWith(
        selectedModel: event.modelName,
        isProcessing: true,
        progress: 0.0,
        error: () => null,
      ),
    );

    try {
      final model = state.availableModels.firstWhere(
        (m) => m.id == event.modelName,
        orElse: () => throw Exception('Model not found in config'),
      );
      final modelRepoPath = state.getModelRepoPath(event.modelName);
      final progressSubscription = engine
          .downloadModel(modelRepoPath, source: state.downloadSource)
          .listen((progress) {
            add(UpdateProgressEvent(progress));
          });

      await engine.loadModel(modelRepoPath, modelType: model.type);

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

  Future<void> _onDeleteModel(
    DeleteModelEvent event,
    Emitter<PunctuationState> emit,
  ) async {
    print('DEBUG: _onDeleteModel called for ${event.modelName}');
    emit(state.copyWith(isProcessing: true, error: () => null));

    try {
      final modelRepoPath = state.getModelRepoPath(event.modelName);
      print('DEBUG: modelRepoPath is $modelRepoPath');
      await engine.deleteModel(modelRepoPath);

      final updatedInstalled = state.installedModels
          .where((id) => id != event.modelName)
          .toList();

      print('DEBUG: Deletion successful, updating state');
      emit(
        state.copyWith(installedModels: updatedInstalled, isProcessing: false),
      );
    } catch (e) {
      print('DEBUG: Deletion failed: $e');
      emit(state.copyWith(isProcessing: false, error: () => '删除模型失败: $e'));
    }
  }
}
