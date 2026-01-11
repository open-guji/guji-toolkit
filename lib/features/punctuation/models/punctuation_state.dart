import 'package:equatable/equatable.dart';
import 'punctuation_model.dart';

/// 标点状态模型
class PunctuationState extends Equatable {
  final String originalText;
  final String punctuatedText;
  final String selectedModel;
  final List<String> installedModels;
  final List<PunctuationModel> availableModels;
  final bool isProcessing;
  final double progress;
  final String downloadSource; // 'huggingface' or 'hf-mirror'
  final String? error;

  const PunctuationState({
    this.originalText = '',
    this.punctuatedText = '',
    this.selectedModel =
        'sheldonlidev/classical-chinese-punctuation-guwen-biaodian',
    this.installedModels = const [], // Empty initially to show "Install"
    this.availableModels = const [],
    this.isProcessing = false,
    this.progress = 0.0,
    this.downloadSource = 'hf-mirror',
    this.error,
  });

  bool isModelAvailable(String modelId) {
    final model = availableModels.firstWhere(
      (m) => m.id == modelId,
      orElse: () => PunctuationModel(
        id: modelId,
        name: modelId,
        description: '',
        huggingfaceUrl: '',
        modelscopeUrl: '',
        type: '',
      ),
    );
    return downloadSource == 'huggingface' || model.modelscopeUrl.isNotEmpty;
  }

  PunctuationState copyWith({
    String? originalText,
    String? punctuatedText,
    String? selectedModel,
    List<String>? installedModels,
    List<PunctuationModel>? availableModels,
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
      availableModels: availableModels ?? this.availableModels,
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
    availableModels,
    isProcessing,
    progress,
    downloadSource,
    error,
  ];
}
