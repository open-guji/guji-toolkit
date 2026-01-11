import 'package:flutter/material.dart';
import 'package:guji_diff/guji_diff.dart';

/// 辅助类:从 CollationChange 列表生成高亮文本
class HighlightedTextHelper {
  static String _processText(String text) {
    return text.replaceAll('\n', '\u21B5\n');
  }

  /// 生成特定类型的高亮文本
  /// [showDelete] 是否显示删除 (text1 或 merged)
  /// [showInsert] 是否显示新增 (text2 或 merged)
  static List<TextSpan> buildSpans(
    List<CollationChange> changes, {
    bool showDelete = true,
    bool showInsert = true,
  }) {
    final spans = <TextSpan>[];

    for (var change in changes) {
      switch (change.type) {
        case CollationType.equal:
          spans.add(
            TextSpan(
              text: change.text,
              style: const TextStyle(color: Colors.black87),
            ),
          );
          break;
        case CollationType.delete:
          if (showDelete) {
            spans.add(
              TextSpan(
                text: _processText(change.text),
                style: TextStyle(
                  backgroundColor: Colors.red.shade100,
                  color: Colors.red.shade900,
                  decoration: TextDecoration.lineThrough,
                ),
              ),
            );
          }
          break;
        case CollationType.insert:
          if (showInsert) {
            spans.add(
              TextSpan(
                text: _processText(change.text),
                style: TextStyle(
                  backgroundColor: Colors.green.shade100,
                  color: Colors.green.shade900,
                  fontWeight: FontWeight.bold,
                ),
              ),
            );
          }
          break;
      }
    }

    return spans;
  }

  /// 为底本生成高亮文本 (仅显示删除部分)
  static List<TextSpan> buildText1Spans(List<CollationChange> changes) =>
      buildSpans(changes, showInsert: false);

  /// 为校本生成高亮文本 (仅显示新增部分)
  static List<TextSpan> buildText2Spans(List<CollationChange> changes) =>
      buildSpans(changes, showDelete: false);

  /// 为合并视图生成高亮文本 (显示删除和新增)
  static List<TextSpan> buildMergedSpans(List<CollationChange> changes) =>
      buildSpans(changes);
}

/// 自定义 TextEditingController，用于在输入框中直接渲染高亮文本
class HighlightEditingController extends TextEditingController {
  List<TextSpan>? highlightSpans;
  bool showHighlight = false;

  @override
  TextSpan buildTextSpan({
    required BuildContext context,
    TextStyle? style,
    required bool withComposing,
  }) {
    if (showHighlight && highlightSpans != null && highlightSpans!.isNotEmpty) {
      return TextSpan(children: highlightSpans, style: style);
    }
    return super.buildTextSpan(
      context: context,
      style: style,
      withComposing: withComposing,
    );
  }
}

/// 可高亮差异的文本输入框
/// 该组件现在仅负责 TextField 的配置，其外壳由 CollationPanel 提供
class HighlightedTextField extends StatelessWidget {
  final String hint;
  final HighlightEditingController controller;
  final ScrollController? scrollController;
  final Function(String) onChanged;
  final bool isExpanded;
  final bool syncHeight;

  const HighlightedTextField({
    super.key,
    required this.hint,
    required this.controller,
    this.scrollController,
    required this.onChanged,
    this.isExpanded = false,
    this.syncHeight = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      scrollController: scrollController,
      minLines: 5, // 最小显示 5 行
      maxLines: null, // 允许根据内容增长
      expands: false,
      textAlignVertical: TextAlignVertical.top,
      decoration: InputDecoration(
        hintText: hint,
        border: InputBorder.none,
        enabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
        errorBorder: InputBorder.none,
        disabledBorder: InputBorder.none,
        contentPadding: const EdgeInsets.only(right: 12),
        filled: false,
      ),
      onChanged: onChanged,
      style: const TextStyle(fontSize: 14, height: 1.5),
    );
  }
}
