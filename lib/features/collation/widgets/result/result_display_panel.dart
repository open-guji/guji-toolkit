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
          return const SizedBox.shrink();
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
                height: 450,
                child: TabBarView(
                  children: [
                    SingleChildScrollView(
                      child: MergedResultView(
                        result: result,
                        resolutions: state.resolutions,
                      ),
                    ),
                    SingleChildScrollView(
                      child: StatisticalAnalysisView(result: result),
                    ),
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
        color: Theme.of(context).colorScheme.errorContainer.withAlpha((255 * 0.1).toInt()),
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
