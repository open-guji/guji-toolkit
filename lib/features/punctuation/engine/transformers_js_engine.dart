import 'dart:async';
import 'dart:convert';
import 'dart:js_interop';
import '../models/punctuation_token.dart';
import 'punctuation_engine.dart';

@JS('transformersEngine')
extension type TransformersEngineJS._(JSObject _) implements JSObject {
  external JSPromise<JSString> runPunctuation(
    JSString text,
    JSString modelName,
    JSFunction onProgress,
  );
  external void setSource(JSString source);
  external JSPromise loadModel(
    JSString modelName,
    JSString taskType,
    JSFunction onProgress,
  );
  external JSPromise<JSString> runInference(
    JSString text,
    JSString modelName,
    JSString taskType,
    JSFunction onProgress,
  );
  external JSPromise<JSBoolean> checkCache(JSString modelName);

  external JSPromise exportModel(JSString modelName);
}

class TransformersJsEngine implements PunctuationEngine {
  final _progressController = StreamController<double>.broadcast();

  @override
  String get engineName => 'Transformers.js (Local)';

  @override
  Future<void> loadModel(String modelName, {String? modelType}) async {
    final engine = _getEngine();
    if (engine == null) throw Exception('Transformers engine not found');

    final onProgress = (JSNumber p) {
      _progressController.add(p.toDartDouble);
    }.toJS;

    try {
      await engine
          .loadModel(
            modelName.toJS,
            (modelType ?? 'token-classification').toJS,
            onProgress,
          )
          .toDart;
    } catch (e) {
      throw Exception('模型加载失败: $e');
    }
  }

  @override
  Future<String> punctuate(
    String text,
    String modelName, {
    String? modelType,
  }) async {
    final engine = _getEngine();
    if (engine == null) throw Exception('Transformers engine not found');

    final onProgress = (JSNumber p) {
      _progressController.add(p.toDartDouble);
    }.toJS;

    try {
      final type = modelType ?? 'token-classification';
      final rawJson = await engine
          .runInference(text.toJS, modelName.toJS, type.toJS, onProgress)
          .toDart;

      final resultStr = rawJson.toDart;

      // Parse JSON logic based on task type
      if (type == 'token-classification') {
        final List<dynamic> jsonList = jsonDecode(resultStr);
        final tokens = jsonList
            .map((e) => PunctuationToken.fromJson(e))
            .toList();
        return _reconstructFromTokens(text, tokens);
      } else if (type == 'fill-mask') {
        // SikuBERT output: usually a list of dicts, take first sequence
        final dynamic decoded = jsonDecode(resultStr);
        if (decoded is List && decoded.isNotEmpty) {
          return decoded[0]['sequence'] as String? ?? resultStr;
        }
        return resultStr;
      }

      return resultStr;
    } catch (e) {
      throw Exception('标点执行失败: $e');
    }
  }

  String _reconstructFromTokens(
    String originalText,
    List<PunctuationToken> tokens,
  ) {
    final buffer = StringBuffer();
    final knownPunc = {
      '。',
      '，',
      '？',
      '！',
      '：',
      '；',
      '、',
      '"',
      '\'',
      '《',
      '》',
      '（',
      '）',
    };

    int tokenIndex = 0;

    // Iterate over the ORIGINAL text to ensure content preservation
    for (int i = 0; i < originalText.length; i++) {
      final char = originalText[i];
      buffer.write(char); // Always preserve original character

      // Try to find matching token
      while (tokenIndex < tokens.length) {
        final token = tokens[tokenIndex];
        final word = token.word.replaceAll('##', '').replaceAll(' ', '').trim();

        // Skip structural tokens but don't advance character index
        if (['[CLS]', '[SEP]', '[PAD]'].contains(word)) {
          tokenIndex++;
          continue;
        }

        // Match logic:
        // 1. Exact match
        // 2. Token is [UNK] (unknown character in model)
        // 3. Token contains char (rare BPE cases)
        bool isMatch = word == char || word == '[UNK]' || word.contains(char);

        if (isMatch) {
          // Debug log: print the entity for the first few punctuations found
          if (token.entity != 'O' && token.entity.isNotEmpty) {
            print('Debug: matched char "$char" with entity "${token.entity}"');
          }

          // Found the corresponding token for this character
          // Check direct punctuation match
          if (knownPunc.contains(token.entity)) {
            buffer.write(token.entity);
          }
          // Check if it's a label mapping (e.g. "M-COMMA", "B-,")
          else {
            // Normalize label: remove I-, B-, M-, E-, S- prefixes
            // Example: "M-COMMA" -> "COMMA", "B-," -> ","
            final cleanLabel = token.entity.replaceAll(
              RegExp(r'^[IBMES]-'),
              '',
            );

            // Check if cleanLabel is itself a known punctuation
            if (knownPunc.contains(cleanLabel)) {
              buffer.write(cleanLabel);
            }
            // Check against label map (English names or ASCII symbols)
            else {
              const labelMap = {
                'COMMA': '，',
                ',': '，',
                'PERIOD': '。',
                '.': '。',
                'QUESTION': '？',
                '?': '？',
                'EXCLAMATION': '！',
                '!': '！',
                'COLON': '：',
                ':': '：',
                'SEMICOLON': '；',
                ';': '；',
                'DUNHAO': '、',
                'QUOTE': '"',
              };

              if (labelMap.containsKey(cleanLabel)) {
                buffer.write(labelMap[cleanLabel]);
              }
            }
          }

          tokenIndex++;
          break; // Move to next character in originalText
        } else {
          // Token doesn't match current char.
          // It's possible the token stream is desynchronized or extra tokens exist.
          // We advance token stream to try to sync up, or purely rely on next search.
          // For safety, let's just assume this char has no punctuation if we can't strictly match,
          // BUT we shouldn't discard tokens aggressively.
          // Given the strict nature of Chinese BERT (usually 1 char = 1 token),
          // mismatch usually means we should check the next token.

          // However, without lookahead, simply checking next token is risky.
          // Let's adopt a strategy: if we don't match, we assume this token belongs to a FUTURE char
          // or this char was skipped by tokenizer (unlikely for char-based).
          // Actually, if word is empty after trim, just skip validly.
          if (word.isEmpty) {
            tokenIndex++;
            continue;
          }

          // If distinct mismatch (e.g. char='A', token='B'), logic gets complex.
          // Be defensive: if we can't match, we stop trying to find punctuation for THIS char
          // and don't advance tokenIndex (maybe it belongs to next char).
          break;
        }
      }
    }

    return buffer.toString();
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
