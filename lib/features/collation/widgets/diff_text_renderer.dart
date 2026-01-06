import 'package:flutter/material.dart';

class DiffTextRenderer extends StatelessWidget {
  final String diff;

  const DiffTextRenderer({super.key, required this.diff});

  @override
  Widget build(BuildContext context) {
    final spans = <TextSpan>[];
    final regex = RegExp(r'\[-([^\]]+)-\]|\[\+([^\]]+)\+\]|([^\[\]]+)');

    for (final match in regex.allMatches(diff)) {
      if (match.group(1) != null) {
        // 删除的文本
        spans.add(
          TextSpan(
            text: match.group(1),
            style: TextStyle(
              backgroundColor: Colors.red.shade100,
              color: Colors.red.shade900,
              decoration: TextDecoration.lineThrough,
            ),
          ),
        );
      } else if (match.group(2) != null) {
        // 添加的文本
        spans.add(
          TextSpan(
            text: match.group(2),
            style: TextStyle(
              backgroundColor: Colors.green.shade100,
              color: Colors.green.shade900,
              fontWeight: FontWeight.bold,
            ),
          ),
        );
      } else if (match.group(3) != null) {
        // 相同的文本
        spans.add(
          TextSpan(
            text: match.group(3),
            style: const TextStyle(color: Colors.black87),
          ),
        );
      }
    }

    return SelectableText.rich(
      TextSpan(children: spans),
      style: const TextStyle(fontSize: 16, height: 1.8),
    );
  }
}
