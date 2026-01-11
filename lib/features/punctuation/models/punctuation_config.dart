enum PunctuationMethod {
  specialized,
  llm;

  String get label {
    switch (this) {
      case PunctuationMethod.specialized:
        return '专用模型';
      case PunctuationMethod.llm:
        return '大语言模型';
    }
  }
}

enum LLMServiceType {
  cloud,
  local;

  String get label {
    switch (this) {
      case LLMServiceType.cloud:
        return '云端服务';
      case LLMServiceType.local:
        return '本地部署';
    }
  }
}

class LLMConfig {
  final LLMServiceType serviceType;
  final String provider; // e.g. 'openai', 'deepseek'
  final String apiKey;
  final String baseUrl;
  final String modelName;

  const LLMConfig({
    this.serviceType = LLMServiceType.cloud,
    this.provider = 'openai',
    this.apiKey = '',
    this.baseUrl = '',
    this.modelName = '',
  });

  LLMConfig copyWith({
    LLMServiceType? serviceType,
    String? provider,
    String? apiKey,
    String? baseUrl,
    String? modelName,
  }) {
    return LLMConfig(
      serviceType: serviceType ?? this.serviceType,
      provider: provider ?? this.provider,
      apiKey: apiKey ?? this.apiKey,
      baseUrl: baseUrl ?? this.baseUrl,
      modelName: modelName ?? this.modelName,
    );
  }
}
