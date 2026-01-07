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

/// 可高亮差异的文本输入框
class HighlightedTextField extends StatefulWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final Function(String) onChanged;
  final List<TextSpan>? highlightSpans;
  final bool showHighlight;

  const HighlightedTextField({
    super.key,
    required this.label,
    required this.hint,
    required this.controller,
    required this.onChanged,
    this.highlightSpans,
    this.showHighlight = false,
  });

  @override
  State<HighlightedTextField> createState() => _HighlightedTextFieldState();
}

class _HighlightedTextFieldState extends State<HighlightedTextField> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).primaryColor,
          ),
        ),
        const SizedBox(height: 8),
        Stack(
          children: [
            // 原始输入框
            TextField(
              controller: widget.controller,
              maxLines: 8,
              minLines: 4,
              decoration: InputDecoration(
                hintText: widget.hint,
                border: const OutlineInputBorder(),
                contentPadding: const EdgeInsets.all(12),
              ),
              onChanged: widget.onChanged,
              style: TextStyle(
                // 当显示高亮时,让输入框文字透明
                color: widget.showHighlight
                    ? Colors.transparent
                    : Colors.black87,
              ),
            ),
            // 高亮层 (只在有结果时显示)
            if (widget.showHighlight && widget.highlightSpans != null)
              Positioned.fill(
                child: IgnorePointer(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.transparent),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: SingleChildScrollView(
                      child: SelectableText.rich(
                        TextSpan(children: widget.highlightSpans!),
                        style: const TextStyle(fontSize: 16, height: 1.5),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}
