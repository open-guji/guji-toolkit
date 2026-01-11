import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guji_toolkit/features/common/widgets/widgets.dart';
import '../../bloc/bloc.dart';
import '../../services/collation_result_exporter.dart';
import 'diff_text_renderer.dart';
import 'collation_legend.dart';
import 'components/merge_hint_box.dart';
import 'components/merge_progress_indicator.dart';
import 'components/merge_actions.dart';

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
    // 使用服务计算进度
    final stats = CollationResultExporter.calculateProgress(
      result,
      resolutions,
    );
    final total = stats.total;
    final resolved = stats.resolved;
    final allResolved = total > 0 && resolved == total;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        const MergeHintBox(),
        PanelContainer(
          title: null, // 合并模式不需要标题
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
        const SizedBox(height: 12),
        Row(
          children: [
            const CollationLegend(),
            const Spacer(),
            // 进度指示器 (0/0 时不显示)
            if (total > 0)
              MergeProgressIndicator(
                resolved: resolved,
                total: total,
                allResolved: allResolved,
              )
            else if (result.mergedView.isNotEmpty &&
                result.text1View.isNotEmpty &&
                result.text2View.isNotEmpty)
              const MergePerfectMatchIndicator(),
            const SizedBox(width: 16),
            // 操作按钮
            MergeActions(result: result, resolutions: resolutions),
          ],
        ),
      ],
    );
  }
}
