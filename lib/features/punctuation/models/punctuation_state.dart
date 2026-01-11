import 'package:equatable/equatable.dart';
import 'punctuation_model.dart';
import 'punctuation_config.dart';

/// 标点状态模型
class PunctuationState extends Equatable {
  final String originalText;
  final String punctuatedText;
  final String selectedModel;
  final PunctuationMethod selectedMethod;
  final LLMConfig llmConfig;
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
    this.selectedMethod = PunctuationMethod.specialized,
    this.llmConfig = const LLMConfig(),
    this.installedModels = const [], // Empty initially to show "Install"
    this.availableModels = const [],
    this.isProcessing = false,
    this.progress = 0.0,
    this.downloadSource = 'huggingface',
    this.error,
  });

  bool isModelAvailable(String modelId) {
    if (selectedMethod == PunctuationMethod.llm) {
      return true; // LLM doesn't need download check
    }
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
    PunctuationMethod? selectedMethod,
    LLMConfig? llmConfig,
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
      selectedMethod: selectedMethod ?? this.selectedMethod,
      llmConfig: llmConfig ?? this.llmConfig,
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
    selectedMethod,
    llmConfig,
    installedModels,
    availableModels,
    isProcessing,
    progress,
    downloadSource,
    error,
  ];
}
