import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guji_toolkit/features/collation/bloc/bloc.dart';

class ResultDisplayPanelBloc extends StatelessWidget {
  const ResultDisplayPanelBloc({super.key});

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
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
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
                                child: _buildDiffText(context, result.diff),
                              ),
                  ),
                ),
                const SizedBox(height: 12),
                // 图例说明
                if (result != null && result.error == null)
                  Wrap(
                    spacing: 16,
                    children: [
                      _LegendItem(
                        color: Colors.red.shade100,
                        label: '[-删除-]',
                      ),
                      _LegendItem(
                        color: Colors.green.shade100,
                        label: '[+添加+]',
                      ),
                    ],
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDiffText(BuildContext context, String diff) {
    final spans = <TextSpan>[];
    final regex = RegExp(r'\[-([^\]]+)-\]|\[\+([^\]]+)\+\]|([^\[\]]+)');

    for (final match in regex.allMatches(diff)) {
      if (match.group(1) != null) {
        // 删除的文本
        spans.add(TextSpan(
          text: match.group(1),
          style: TextStyle(
            backgroundColor: Colors.red.shade100,
            color: Colors.red.shade900,
            decoration: TextDecoration.lineThrough,
          ),
        ));
      } else if (match.group(2) != null) {
        // 添加的文本
        spans.add(TextSpan(
          text: match.group(2),
          style: TextStyle(
            backgroundColor: Colors.green.shade100,
            color: Colors.green.shade900,
            fontWeight: FontWeight.bold,
          ),
        ));
      } else if (match.group(3) != null) {
        // 相同的文本
        spans.add(TextSpan(
          text: match.group(3),
          style: const TextStyle(color: Colors.black87),
        ));
      }
    }

    return SelectableText.rich(
      TextSpan(children: spans),
      style: const TextStyle(fontSize: 16, height: 1.8),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendItem({
    required this.color,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
            border: Border.all(color: Colors.grey.shade400),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}
