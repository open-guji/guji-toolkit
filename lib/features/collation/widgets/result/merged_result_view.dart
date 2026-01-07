import 'package:flutter/material.dart';
import 'diff_text_renderer.dart';
import 'collation_legend.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guji_toolkit/features/collation/bloc/bloc.dart';

class MergedResultView extends StatelessWidget {
  final CollationResult result;
  final Map<int, DiffResolution> resolutions;

  const MergedResultView({
    super.key,
    required this.result,
    required this.resolutions,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Theme.of(context).dividerColor,
                width: 1,
              ),
            ),
            child: SingleChildScrollView(
              child: DiffTextRenderer(
                changes: result.mergedView,
                resolutions: resolutions,
                onResolve: (index, resolution) {
                  context.read<CollationBloc>().add(
                    ResolveDiffEvent(index, resolution),
                  );
                },
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        const CollationLegend(),
      ],
    );
  }
}
