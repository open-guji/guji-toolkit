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

  String get description {
    switch (this) {
      case PunctuationMethod.specialized:
        return '使用专门训练的古文标点模型，准确度高，模型下载后本地离线使用';
      case PunctuationMethod.llm:
        return '使用大语言模型进行标点，支持自定义提示词，闭源模型需要网络连接和相关账号';
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

/// LLM 提供商枚举
enum LLMProvider {
  openai,
  deepseek,
  qwen,
  zhipu,
  moonshot,
  custom;

  String get label {
    switch (this) {
      case LLMProvider.openai:
        return 'OpenAI';
      case LLMProvider.deepseek:
        return 'DeepSeek';
      case LLMProvider.qwen:
        return '通义千问';
      case LLMProvider.zhipu:
        return '智谱 AI';
      case LLMProvider.moonshot:
        return 'Moonshot';
      case LLMProvider.custom:
        return '自定义';
    }
  }

  String get description {
    switch (this) {
      case LLMProvider.openai:
        return 'OpenAI GPT 系列模型';
      case LLMProvider.deepseek:
        return 'DeepSeek 系列模型';
      case LLMProvider.qwen:
        return '阿里云通义千问系列模型';
      case LLMProvider.zhipu:
        return '智谱 GLM 系列模型';
      case LLMProvider.moonshot:
        return 'Moonshot AI 系列模型';
      case LLMProvider.custom:
        return '自定义 LLM 服务';
    }
  }

  bool get isDevelopment {
    // 只有 custom 不在开发中
    return this != LLMProvider.custom;
  }
}

class LLMConfig {
  final LLMServiceType serviceType;
  final LLMProvider selectedProvider; // 选中的提供商
  final String provider; // e.g. 'openai', 'deepseek' (保留用于兼容)
  final String apiKey;
  final String baseUrl;
  final String modelName;

  const LLMConfig({
    this.serviceType = LLMServiceType.cloud,
    this.selectedProvider = LLMProvider.openai,
    this.provider = 'openai',
    this.apiKey = '',
    this.baseUrl = '',
    this.modelName = '',
  });

  LLMConfig copyWith({
    LLMServiceType? serviceType,
    LLMProvider? selectedProvider,
    String? provider,
    String? apiKey,
    String? baseUrl,
    String? modelName,
  }) {
    return LLMConfig(
      serviceType: serviceType ?? this.serviceType,
      selectedProvider: selectedProvider ?? this.selectedProvider,
      provider: provider ?? this.provider,
      apiKey: apiKey ?? this.apiKey,
      baseUrl: baseUrl ?? this.baseUrl,
      modelName: modelName ?? this.modelName,
    );
  }
}
