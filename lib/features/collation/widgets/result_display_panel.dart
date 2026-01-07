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
          length: 3,
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
                tabs: const [
                  Tab(text: '合并模式'),
                  Tab(text: '差异模式'),
                  Tab(text: '统计分析'),
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
                    _buildMergedView(context, result),
                    _buildDiffOnlyView(context, result),
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
  Widget _buildMergedView(BuildContext context, result) {
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
              child: DiffTextRenderer(changes: result.mergedView),
            ),
          ),
        ),
        const SizedBox(height: 12),
        const CollationLegend(),
      ],
    );
  }

  /// 差异模式：只显示不同之处（Unified Diff 格式）
  Widget _buildDiffOnlyView(BuildContext context, result) {
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
              child: _buildUnifiedDiffText(result.unifiedDiff),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _buildDiffLegendItem(context, '-', '删除', Colors.red),
            const SizedBox(width: 16),
            _buildDiffLegendItem(context, '+', '新增', Colors.green),
          ],
        ),
      ],
    );
  }

  /// 构建 Unified Diff 文本显示
  Widget _buildUnifiedDiffText(String? unifiedDiff) {
    // 处理空值情况
    if (unifiedDiff == null || unifiedDiff.isEmpty) {
      return const SelectableText(
        '(暂无差异信息)',
        style: TextStyle(fontSize: 14, height: 1.6, color: Colors.grey),
      );
    }

    final lines = unifiedDiff.split('\n');
    final spans = <TextSpan>[];

    for (var line in lines) {
      TextStyle style;
      if (line.startsWith('---') || line.startsWith('+++')) {
        // 文件头
        style = const TextStyle(
          color: Colors.grey,
          fontWeight: FontWeight.bold,
        );
      } else if (line.startsWith('@@')) {
        // 位置信息
        style = TextStyle(
          color: Colors.blue.shade700,
          fontWeight: FontWeight.bold,
        );
      } else if (line.startsWith('-')) {
        // 删除的内容
        style = TextStyle(
          backgroundColor: Colors.red.shade100,
          color: Colors.red.shade900,
        );
      } else if (line.startsWith('+')) {
        // 添加的内容
        style = TextStyle(
          backgroundColor: Colors.green.shade100,
          color: Colors.green.shade900,
        );
      } else {
        // 普通内容
        style = const TextStyle(color: Colors.black87);
      }

      spans.add(TextSpan(text: '$line\n', style: style));
    }

    return SelectableText.rich(
      TextSpan(children: spans),
      style: const TextStyle(
        fontSize: 14,
        height: 1.6,
        fontFamily: 'monospace',
      ),
    );
  }

  /// 构建差异图例项
  Widget _buildDiffLegendItem(
    BuildContext context,
    String symbol,
    String label,
    Color color,
  ) {
    final darkColor = color == Colors.red
        ? Colors.red.shade900
        : Colors.green.shade900;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            symbol,
            style: TextStyle(
              color: darkColor,
              fontWeight: FontWeight.bold,
              fontFamily: 'monospace',
            ),
          ),
        ),
        const SizedBox(width: 4),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
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
                  ).colorScheme.primaryContainer.withValues(alpha: 0.3),
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
      color: Theme.of(
        context,
      ).colorScheme.secondaryContainer.withValues(alpha: 0.2),
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
