import 'package:equatable/equatable.dart';

/// 标点状态模型
class PunctuationState extends Equatable {
  final String originalText;
  final String punctuatedText;
  final String selectedModel;
  final List<String> installedModels;
  final bool isProcessing;
  final double progress;
  final String downloadSource; // 'huggingface' or 'hf-mirror'
  final String? error;

  const PunctuationState({
    this.originalText = '',
    this.punctuatedText = '',
    this.selectedModel = 'Xenova/siku-bert',
    this.installedModels = const [], // Empty initially to show "Install"
    this.isProcessing = false,
    this.progress = 0.0,
    this.downloadSource = 'hf-mirror',
    this.error,
  });

  PunctuationState copyWith({
    String? originalText,
    String? punctuatedText,
    String? selectedModel,
    List<String>? installedModels,
    bool? isProcessing,
    double? progress,
    String? downloadSource,
    String? Function()? error,
  }) {
    return PunctuationState(
      originalText: originalText ?? this.originalText,
      punctuatedText: punctuatedText ?? this.punctuatedText,
      selectedModel: selectedModel ?? this.selectedModel,
      installedModels: installedModels ?? this.installedModels,
      isProcessing: isProcessing ?? this.isProcessing,
      progress: progress ?? this.progress,
      downloadSource: downloadSource ?? this.downloadSource,
      error: error != null ? error() : this.error,
    );
  }

  @override
  List<Object?> get props => [
    originalText,
    punctuatedText,
    selectedModel,
    installedModels,
    isProcessing,
    progress,
    downloadSource,
    error,
  ];
}
