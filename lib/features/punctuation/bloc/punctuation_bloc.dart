import 'package:flutter_bloc/flutter_bloc.dart';
import 'punctuation_event.dart';
import '../models/punctuation_state.dart';

class PunctuationBloc extends Bloc<PunctuationEvent, PunctuationState> {
  PunctuationBloc() : super(const PunctuationState()) {
    on<UpdateOriginalTextEvent>(_onUpdateOriginalText);
    on<SelectModelEvent>(_onSelectModel);
    on<PerformPunctuationEvent>(_onPerformPunctuation);
    on<LoadPunctuationExampleEvent>(_onLoadExample);
    on<ClearPunctuationResultEvent>(_onClearResult);
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

    emit(state.copyWith(isProcessing: true, progress: 0.1, error: () => null));

    try {
      // TODO: Implement actual punctuation logic via Engine layer
      await Future.delayed(const Duration(seconds: 2));

      // Mock result
      emit(
        state.copyWith(
          punctuatedText: '【标注版本】${state.originalText}',
          isProcessing: false,
          progress: 1.0,
        ),
      );
    } catch (e) {
      emit(state.copyWith(isProcessing: false, error: () => '标点失败: $e'));
    }
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
}
