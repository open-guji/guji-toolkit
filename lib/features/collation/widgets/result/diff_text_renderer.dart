import 'package:flutter/material.dart';
import 'package:guji_diff/guji_diff.dart';
import 'package:guji_toolkit/features/collation/models/collation_state.dart';
import 'diff_span_builder.dart';
import 'diff_menu_helper.dart';

/// 渲染可交互的差异文本
class DiffTextRenderer extends StatelessWidget {
  final List<CollationChange> changes;
  final Map<int, DiffResolution> resolutions;
  final Function(int index, DiffResolution resolution) onResolve;

  const DiffTextRenderer({
    super.key,
    required this.changes,
    required this.resolutions,
    required this.onResolve,
  });

  @override
  Widget build(BuildContext context) {
    if (changes.isEmpty) return const SizedBox.shrink();

    final menuHelper = DiffMenuHelper(context, onResolve);
    final spanBuilder = DiffSpanBuilder(
      context: context,
      changes: changes,
      resolutions: resolutions,
      menuHelper: menuHelper,
    );

    return SelectableText.rich(
      TextSpan(children: spanBuilder.build()),
      style: const TextStyle(fontSize: 14, height: 1.5),
    );
  }
}
