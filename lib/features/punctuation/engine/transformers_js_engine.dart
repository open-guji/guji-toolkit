import 'dart:async';
import 'dart:js_interop';
import 'punctuation_engine.dart';

@JS('transformersEngine')
extension type TransformersEngineJS._(JSObject _) implements JSObject {
  external JSPromise<JSString> runPunctuation(
    JSString text,
    JSString modelName,
    JSFunction onProgress,
  );
  external void setSource(JSString source);
  external JSPromise loadModel(JSString modelName, JSFunction onProgress);
  external JSPromise<JSBoolean> checkCache(JSString modelName);

  external JSPromise exportModel(JSString modelName);
}

class TransformersJsEngine implements PunctuationEngine {
  final _progressController = StreamController<double>.broadcast();

  @override
  String get engineName => 'Transformers.js (Local)';

  @override
  Future<void> loadModel(String modelName) async {
    final engine = _getEngine();
    if (engine == null) throw Exception('Transformers engine not found');

    final onProgress = (JSNumber p) {
      _progressController.add(p.toDartDouble);
    }.toJS;

    // We trust that the JS engine is correctly loaded based on index.html
    // If not, it will throw a property access error on call.

    try {
      await engine.loadModel(modelName.toJS, onProgress).toDart;
    } catch (e) {
      throw Exception('模型加载失败: $e');
    }
  }

  @override
  Future<String> punctuate(String text, String modelName) async {
    final engine = _getEngine();
    if (engine == null) throw Exception('Transformers engine not found');

    final onProgress = (JSNumber p) {
      _progressController.add(p.toDartDouble);
    }.toJS;

    try {
      final resultValue = await engine
          .runPunctuation(text.toJS, modelName.toJS, onProgress)
          .toDart;
      return resultValue.toDart;
    } catch (e) {
      throw Exception('标点执行失败: $e');
    }
  }

  @override
  Stream<double> downloadModel(String modelName, {String? source}) async* {
    final engine = _getEngine();
    if (engine != null && source != null) {
      engine.setSource(source.toJS);
    }

    // 触发下载只需监听进度流
    yield* _progressController.stream;
  }

  @override
  Future<bool> isModelCached(String modelName) async {
    final engine = _getEngine();
    if (engine == null) return false;
    final result = await engine.checkCache(modelName.toJS).toDart;
    return result.toDart;
  }

  @override
  Future<List<String>> getCachedModels() async {
    // Currently we only have one model, simplify check
    final cached = await isModelCached('Xenova/siku-bert');
    return cached ? ['Xenova/siku-bert'] : [];
  }

  @override
  Future<void> exportModel(String modelName) async {
    final engine = _getEngine();
    if (engine == null) return;
    await engine.exportModel(modelName.toJS).toDart;
  }

  TransformersEngineJS? _getEngine() {
    final engine = transformersEngine;
    if (engine == null) {
      // In web, sometimes it takes a split second for the script to attach to window
      // though typically not if loaded in index.html.
      // We'll return null and let the caller handle it.
      return null;
    }
    return engine;
  }
}

@JS('transformersEngine')
external TransformersEngineJS? get transformersEngine;
