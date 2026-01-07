import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guji_toolkit/features/collation/bloc/bloc.dart';
import 'merged_result_view.dart';
import 'statistical_analysis_view.dart';

class ResultDisplayPanel extends StatelessWidget {
  const ResultDisplayPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CollationBloc, CollationState>(
      builder: (context, state) {
        final result = state.result;

        if (result == null) {
          final hasInput = state.text1.isNotEmpty || state.text2.isNotEmpty;
          return Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 40.0),
              child: Text(
                hasInput ? '对比内容已改变，请重新进行对比' : '点击"开始对比"查看结果',
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
                    MergedResultView(
                      result: result,
                      resolutions: state.resolutions,
                    ),
                    StatisticalAnalysisView(result: result),
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
}
