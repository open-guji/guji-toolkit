import 'package:flutter/material.dart';
import 'package:guji_toolkit/features/collation/models/collation_state.dart';

class StatisticalAnalysisView extends StatelessWidget {
  final CollationResult result;

  const StatisticalAnalysisView({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 统计信息行：相似度 + 详细统计，更加紧凑
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                // 相似度
                _buildCompactSimilarity(context, result.similarity),
                const SizedBox(width: 32),
                // 具体的增删改统计
                _buildSimpleCount(
                  context,
                  '新增',
                  result.insertCount,
                  Colors.green,
                ),
                const SizedBox(width: 24),
                _buildSimpleCount(
                  context,
                  '删除',
                  result.deleteCount,
                  Colors.red,
                ),
                const SizedBox(width: 24),
                _buildSimpleCount(
                  context,
                  '修改',
                  result.modifyCount,
                  Colors.blue,
                ),
              ],
            ),

            const SizedBox(height: 16),

            // 常见改动模式
            if (result.patterns.isNotEmpty) ...[
              Text(
                '常见改动模式',
                style: Theme.of(
                  context,
                ).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: result.patterns.entries.map<Widget>((entry) {
                  return Chip(
                    label: Text('${entry.key} (${entry.value})'),
                    backgroundColor: Theme.of(
                      context,
                    ).colorScheme.surfaceContainerHigh.withValues(alpha: 0.5),
                    side: BorderSide.none,
                    labelStyle: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(fontSize: 11),
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.zero,
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCompactSimilarity(BuildContext context, double similarity) {
    final color = similarity > 0.9
        ? Colors.green
        : (similarity > 0.7 ? Colors.orange : Colors.red);

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Text(
          '相似度',
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '${(similarity * 100).toInt()}%',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildSimpleCount(
    BuildContext context,
    String label,
    int count,
    Color color,
  ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        // 使用 Baseline 包装点，使其底部对齐文字基准线
        Baseline(
          baseline: 16, // 点的高度是 8，设置为 8 意味着其底部对齐基准线
          baselineType: TextBaseline.alphabetic,
          child: Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          count.toString(),
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
