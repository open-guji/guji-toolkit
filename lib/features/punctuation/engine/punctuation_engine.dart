/// 标点引擎接口
/// 用于解耦具体的算法实现（如本地 Transformers.js 或 远程 LLM）
abstract class PunctuationEngine {
  /// 预加载/安装模型
  Future<void> loadModel(String modelName, {String? subfolder});

  /// 对文本进行标点
  /// [text] 原始文本
  /// [modelName] 模型名称
  Future<String> punctuate(String text, String modelName, {String? subfolder});

  /// 下载模型
  /// [modelName] 模型名称
  /// [source] 下载源（如 huggingface, hf-mirror）
  /// 返回进度流 (0.0 到 1.0)
  Stream<double> downloadModel(
    String modelName, {
    String? source,
    String? subfolder,
  });

  /// 导出模型到桌面
  Future<void> exportModel(String modelName, {String? subfolder});

  /// 检查模型是否在浏览器缓存中
  Future<bool> isModelCached(String modelName, {String? subfolder});

  /// 获取所有已缓存的模型列表
  Future<List<String>> getCachedModels();

  /// 获取引擎名称

  String get engineName;
}
