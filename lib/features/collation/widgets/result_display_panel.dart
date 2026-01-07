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

        if (result == null) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 40.0),
              child: Text(
                '点击"开始对比"查看结果',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          );
        }

        if (result.error != null) {
          return _buildErrorResult(context, result.error!);
        }

        return DefaultTabController(
          length: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TabBar(
                isScrollable: true,
                tabAlignment: TabAlignment.start,
                labelStyle: const TextStyle(fontWeight: FontWeight.bold),
                unselectedLabelStyle: const TextStyle(
                  fontWeight: FontWeight.normal,
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                dividerColor: Colors.transparent,
                tabs: [
                  const Tab(text: '合并模式'),
                  Tab(
                    text:
                        '统计分析${result.similarity > 0 ? ' (${(result.similarity * 100).toInt()}%)' : ''}',
                  ),
                ],
              ),
              Divider(
                height: 1,
                thickness: 1,
                color: Theme.of(context).dividerColor,
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 400, // Fixed height or constrained
                child: TabBarView(
                  children: [
                    _buildMergedView(context, result, state.resolutions),
                    _buildStatisticalAnalysis(context, result),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildErrorResult(BuildContext context, String error) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(
          context,
        ).colorScheme.errorContainer.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Theme.of(context).colorScheme.error),
      ),
      child: Center(
        child: Text(
          error,
          style: TextStyle(color: Theme.of(context).colorScheme.error),
        ),
      ),
    );
  }

  /// 合并模式：显示合并后的文本，高亮差异
  Widget _buildMergedView(
    BuildContext context,
    CollationResult result,
    Map<int, DiffResolution> resolutions,
  ) {
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

  Widget _buildStatisticalAnalysis(BuildContext context, result) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 统计信息行：相似度 + 详细统计，更加紧凑
            Row(
              children: [
                // 相似度
                _buildCompactSimilarity(context, result.similarity),
                const SizedBox(width: 24),
                // 具体的增删改统计
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildSimpleCount(
                        context,
                        '新增',
                        result.insertCount,
                        Colors.green,
                      ),
                      _buildSimpleCount(
                        context,
                        '删除',
                        result.deleteCount,
                        Colors.red,
                      ),
                      _buildSimpleCount(
                        context,
                        '修改',
                        result.modifyCount,
                        Colors.blue,
                      ),
                    ],
                  ),
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
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
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
          ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
