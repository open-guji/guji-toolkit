import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guji_toolkit/features/collation/bloc/bloc.dart';
import 'package:guji_toolkit/features/collation/widgets/diff_text_renderer.dart';
import 'package:guji_toolkit/features/collation/widgets/collation_legend.dart';

class ResultDisplayPanel extends StatelessWidget {
  const ResultDisplayPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CollationBloc, CollationState>(
      builder: (context, state) {
        final result = state.result;

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '对比结果',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (result != null)
                      Text(
                        '相似度: ${(result.similarity * 100).toStringAsFixed(1)}%',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Theme.of(context).colorScheme.outline,
                      ),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: result == null
                        ? Center(
                            child: Text(
                              '点击"开始对比"查看结果',
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurfaceVariant,
                                  ),
                            ),
                          )
                        : result.error != null
                        ? Center(
                            child: Text(
                              result.error!,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.error,
                              ),
                            ),
                          )
                        : SingleChildScrollView(
                            child: DiffTextRenderer(diff: result.diff),
                          ),
                  ),
                ),
                const SizedBox(height: 12),
                if (result != null && result.error == null)
                  const CollationLegend(),
              ],
            ),
          ),
        );
      },
    );
  }
}
