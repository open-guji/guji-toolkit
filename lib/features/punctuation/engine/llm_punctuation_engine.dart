import 'package:http/http.dart' as http;
import 'dart:convert';
import 'punctuation_engine.dart';

class LLMPunctuationEngine implements PunctuationEngine {
  @override
  String get engineName => 'LLM Engine';

  // LLM Config (injected or passed via punctuate arguments)
  // Ideally, valid config is passed during punctuate call or initialization.
  // Here we assume the caller handles config validation.

  @override
  Future<String> punctuate(
    String text,
    String modelName, {
    String? modelType,
    Map<String, dynamic>? extraConfig,
  }) async {
    // extraConfig should contain: baseUrl, apiKey, provider
    if (extraConfig == null) {
      throw Exception('LLM config missing');
    }

    final String provider = extraConfig['provider'] ?? 'openai';
    final String apiKey = extraConfig['apiKey'] ?? '';
    final String baseUrl = extraConfig['baseUrl'] ?? '';

    // Basic Prompt Construction
    final prompt =
        '''
请为以下古文添加现代标点符号。
要求：
1. 仅输出标点后的文本，不要包含任何解释或额外内容。
2. 保持原文文字不变。
3. 使用全角标点。

原文：
$text
''';

    // Dispatch based on provider or service type
    // This is a simplified example. Real implementation would use a proper client.
    try {
      if (baseUrl.isNotEmpty) {
        // Treat as Local LLM / OpenAI Compatible
        return _callOpenAICompatible(baseUrl, apiKey, modelName, prompt);
      } else if (provider.toLowerCase().contains('openai')) {
        return _callOpenAICompatible(
          'https://api.openai.com/v1',
          apiKey,
          modelName,
          prompt,
        );
      } else {
        throw Exception('Unsupported provider or missing Base URL');
      }
    } catch (e) {
      throw Exception('LLM Request Failed: $e');
    }
  }

  Future<String> _callOpenAICompatible(
    String baseUrl,
    String apiKey,
    String model,
    String prompt,
  ) async {
    final url = Uri.parse('$baseUrl/chat/completions');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
      },
      body: jsonEncode({
        'model': model,
        'messages': [
          {'role': 'user', 'content': prompt},
        ],
        'temperature': 0.1, // Low temperature for deterministic output
      }),
    );

    if (response.statusCode == 200) {
      final decoded = jsonDecode(utf8.decode(response.bodyBytes));
      if (decoded['choices'] != null && decoded['choices'].isNotEmpty) {
        return decoded['choices'][0]['message']['content'];
      }
    }
    throw Exception('API Error: ${response.statusCode} ${response.body}');
  }

  // --- No-ops for model management as LLMs are remote/external ---

  @override
  Stream<double> downloadModel(String modelName, {String? source}) async* {
    yield 1.0; // Instant "download"
  }

  Future<void> exportModel(String modelName) async {
    // No-op
  }

  @override
  Future<List<String>> getCachedModels() async {
    return [];
  }

  @override
  Future<bool> isModelCached(String modelName) async {
    return true; // Always "ready"
  }

  @override
  Future<void> loadModel(String modelName, {String? modelType}) async {
    // No-op connection check could go here
  }

  @override
  Future<void> deleteModel(String modelName) async {
    // No-op for LLM
  }
}
