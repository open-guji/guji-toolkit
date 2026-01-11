/// 标点引擎接口
/// 用于解耦具体的算法实现（如本地 Transformers.js 或 远程 LLM）
abstract class PunctuationEngine {
  /// 对文本进行标点
  /// [text] 原始文本
  /// [modelName] 模型名称
  Future<String> punctuate(String text, String modelName);

  /// 下载模型
  /// [modelName] 模型名称
  /// [source] 下载源（如 huggingface, hf-mirror）
  /// 返回进度流 (0.0 到 1.0)
  Stream<double> downloadModel(String modelName, {String? source});

  /// 检查模型是否已安装
  Future<bool> isModelInstalled(String modelName);

  /// 获取引擎名称
  String get engineName;
}
