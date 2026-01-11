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
}

class TransformersJsEngine implements PunctuationEngine {
  final _progressController = StreamController<double>.broadcast();

  @override
  String get engineName => 'Transformers.js (Local)';

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
  Future<bool> isModelInstalled(String modelName) async {
    return false;
  }

  TransformersEngineJS? _getEngine() {
    return transformersEngine;
  }
}

@JS('transformersEngine')
external TransformersEngineJS? get transformersEngine;
