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
                labelStyle: const TextStyle(fontWeight: FontWeight.bold),
                unselectedLabelStyle: const TextStyle(
                  fontWeight: FontWeight.normal,
                ),
                tabs: const [
                  Tab(text: '文字对比'),
                  Tab(text: '统计分析'),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 400, // Fixed height or constrained
                child: TabBarView(
                  children: [
                    _buildTextualAnalysis(context, result),
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
        color: Theme.of(context).colorScheme.errorContainer.withOpacity(0.1),
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

  Widget _buildTextualAnalysis(BuildContext context, result) {
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
            ),
            child: SingleChildScrollView(
              child: DiffTextRenderer(diff: result.diff),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 相似度指示器
          _buildSimilarityCard(context, result.similarity),
          const SizedBox(height: 16),

          // 基础统计
          _buildCountGrid(context, result),
          const SizedBox(height: 24),

          // 常见改动模式
          if (result.patterns.isNotEmpty) ...[
            Text(
              '常见改动模式',
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: result.patterns.entries.map<Widget>((entry) {
                return Chip(
                  label: Text('${entry.key} (${entry.value})'),
                  backgroundColor: Theme.of(
                    context,
                  ).colorScheme.primaryContainer.withOpacity(0.3),
                  side: BorderSide.none,
                  labelStyle: Theme.of(context).textTheme.bodySmall,
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSimilarityCard(BuildContext context, double similarity) {
    final color = similarity > 0.9
        ? Colors.green
        : (similarity > 0.7 ? Colors.orange : Colors.red);

    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.secondaryContainer.withOpacity(0.2),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            SizedBox(
              width: 60,
              height: 60,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CircularProgressIndicator(
                    value: similarity,
                    backgroundColor: Theme.of(context).colorScheme.surface,
                    color: color,
                    strokeWidth: 8,
                  ),
                  Center(
                    child: Text(
                      '${(similarity * 100).toInt()}%',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '文本相似度',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _getSimilarityDescription(similarity),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCountGrid(BuildContext context, result) {
    return Row(
      children: [
        _buildCountItem(context, '新增字符', result.insertCount, Colors.green),
        const SizedBox(width: 12),
        _buildCountItem(context, '删除字符', result.deleteCount, Colors.red),
        const SizedBox(width: 12),
        _buildCountItem(context, '修改/替换', result.modifyCount, Colors.blue),
      ],
    );
  }

  Widget _buildCountItem(
    BuildContext context,
    String label,
    int count,
    Color color,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: Theme.of(context).dividerColor),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Text(label, style: Theme.of(context).textTheme.labelSmall),
            const SizedBox(height: 8),
            Text(
              count.toString(),
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getSimilarityDescription(double similarity) {
    if (similarity > 0.98) return '文本基本完全一致';
    if (similarity > 0.9) return '文本高度相似，仅有少量差异';
    if (similarity > 0.7) return '文本中度相似，存在明显改动';
    if (similarity > 0.4) return '文本相似度较低，建议核对内容';
    return '文本差异巨大';
  }
}
