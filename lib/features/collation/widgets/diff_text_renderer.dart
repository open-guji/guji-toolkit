import 'package:flutter/material.dart';
import 'package:guji_diff/guji_diff.dart';
import 'package:guji_toolkit/features/collation/widgets/highlighted_text_field.dart';

class DiffTextRenderer extends StatelessWidget {
  final List<CollationChange> changes;

  const DiffTextRenderer({super.key, required this.changes});

  @override
  Widget build(BuildContext context) {
    if (changes.isEmpty) return const SizedBox.shrink();

    final spans = HighlightedTextHelper.buildMergedSpans(changes);

    return SelectableText.rich(
      TextSpan(children: spans),
      style: const TextStyle(fontSize: 16, height: 1.8),
    );
  }
}
