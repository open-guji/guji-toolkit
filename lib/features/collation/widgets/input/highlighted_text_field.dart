import 'package:flutter/material.dart';
import 'package:guji_diff/guji_diff.dart';

/// 辅助类:从 CollationChange 列表生成高亮文本
class HighlightedTextHelper {
  /// 为底本生成高亮文本 (显示删除的部分)
  static List<TextSpan> buildText1Spans(List<CollationChange> changes) {
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
          spans.add(
            TextSpan(
              text: change.text,
              style: TextStyle(
                backgroundColor: Colors.red.shade100,
                color: Colors.red.shade900,
                decoration: TextDecoration.lineThrough,
              ),
            ),
          );
          break;
        case CollationType.insert:
          // text1View 不应该包含 insert
          break;
      }
    }

    return spans;
  }

  /// 为校本生成高亮文本 (显示新增的部分)
  static List<TextSpan> buildText2Spans(List<CollationChange> changes) {
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
          // text2View 不应该包含 delete
          break;
        case CollationType.insert:
          spans.add(
            TextSpan(
              text: change.text,
              style: TextStyle(
                backgroundColor: Colors.green.shade100,
                color: Colors.green.shade900,
                fontWeight: FontWeight.bold,
              ),
            ),
          );
          break;
      }
    }

    return spans;
  }

  /// 为合并视图生成高亮文本 (显示删除和新增)
  static List<TextSpan> buildMergedSpans(List<CollationChange> changes) {
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
          spans.add(
            TextSpan(
              text: change.text,
              style: TextStyle(
                backgroundColor: Colors.red.shade100,
                color: Colors.red.shade900,
                decoration: TextDecoration.lineThrough,
              ),
            ),
          );
          break;
        case CollationType.insert:
          spans.add(
            TextSpan(
              text: change.text,
              style: TextStyle(
                backgroundColor: Colors.green.shade100,
                color: Colors.green.shade900,
                fontWeight: FontWeight.bold,
              ),
            ),
          );
          break;
      }
    }

    return spans;
  }
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
class HighlightedTextField extends StatelessWidget {
  final String label;
  final String hint;
  final HighlightEditingController controller;
  final ScrollController? scrollController;
  final Function(String) onChanged;
  final bool isExpanded;

  const HighlightedTextField({
    super.key,
    required this.label,
    required this.hint,
    required this.controller,
    this.scrollController,
    required this.onChanged,
    this.isExpanded = false,
  });

  @override
  Widget build(BuildContext context) {
    final textField = TextField(
      controller: controller,
      scrollController: scrollController,
      maxLines: isExpanded ? null : null, // must be null for expands
      minLines: isExpanded ? null : 5,
      expands: isExpanded,
      textAlignVertical: TextAlignVertical.top,
      decoration: InputDecoration(
        hintText: hint,
        border: const OutlineInputBorder(),
        contentPadding: const EdgeInsets.all(12),
      ),
      onChanged: onChanged,
      style: const TextStyle(fontSize: 14, height: 1.5),
    );

    final wrappedTextField = isExpanded
        ? Expanded(child: textField)
        : ConstrainedBox(
            constraints: const BoxConstraints(
              minHeight: 200,
              maxHeight: 450,
            ),
            child: textField,
          );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: isExpanded ? MainAxisSize.max : MainAxisSize.min,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).primaryColor,
          ),
        ),
        const SizedBox(height: 8),
        wrappedTextField,
      ],
    );
  }
}
