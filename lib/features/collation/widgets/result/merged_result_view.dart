import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'diff_text_renderer.dart';
import 'collation_legend.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guji_toolkit/features/collation/bloc/bloc.dart';
import 'package:guji_toolkit/features/collation/services/collation_result_exporter.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:convert';
import 'package:flutter/foundation.dart';

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
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Theme.of(context).dividerColor, width: 1),
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 150, maxHeight: 400),
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
        Row(
          children: [
            const CollationLegend(),
            const Spacer(),
            // 进度指示器 (0/0 时不显示)
            if (total > 0)
              _buildProgressIndicator(context, resolved, total, allResolved)
            else if (result.mergedView.isNotEmpty &&
                result.text1View.isNotEmpty &&
                result.text2View.isNotEmpty)
              _buildPerfectMatchIndicator(context),
            const SizedBox(width: 16),
            // 操作按钮
            ElevatedButton.icon(
              onPressed: (result.text1View.isEmpty || result.text2View.isEmpty)
                  ? null
                  : () => _handleExport(context, isCopy: true),
              icon: const Icon(Icons.copy, size: 16),
              label: const Text('复制'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 12),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton.icon(
              onPressed: (result.text1View.isEmpty || result.text2View.isEmpty)
                  ? null
                  : () => _handleExport(context, isCopy: false),
              icon: const Icon(Icons.save_alt, size: 16),
              label: const Text('保存'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 12),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPerfectMatchIndicator(BuildContext context) {
    const color = Colors.green;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.check_circle, color: color, size: 20),
        const SizedBox(width: 4),
        Text(
          '完全匹配',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildProgressIndicator(
    BuildContext context,
    int resolved,
    int total,
    bool allResolved,
  ) {
    final color = allResolved ? Colors.green : Colors.orange;
    final icon = allResolved ? Icons.check_circle : Icons.warning_amber_rounded;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 4),
        Text(
          '已确认: $resolved / $total',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  void _handleExport(BuildContext context, {required bool isCopy}) {
    final stats = CollationResultExporter.calculateProgress(
      result,
      resolutions,
    );
    if (stats.resolved < stats.total) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('确认导出'),
          content: const Text('还有未确认的差异，未确认的部分将默认保留"底本"内容。是否继续？'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('取消'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                if (isCopy) {
                  _copyToClipboard(context);
                } else {
                  _saveAsFile(context);
                }
              },
              child: const Text('继续'),
            ),
          ],
        ),
      );
    } else {
      if (isCopy) {
        _copyToClipboard(context);
      } else {
        _saveAsFile(context);
      }
    }
  }

  void _copyToClipboard(BuildContext context) {
    final text = CollationResultExporter.getResolvedText(result, resolutions);
    Clipboard.setData(ClipboardData(text: text)).then((_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('已复制到剪贴板'),
            duration: Duration(seconds: 1),
          ),
        );
      }
    });
  }

  void _saveAsFile(BuildContext context) async {
    final text = CollationResultExporter.getResolvedText(result, resolutions);
    final bytes = utf8.encode(text);

    try {
      final String fileName =
          'collation_result_${DateTime.now().millisecondsSinceEpoch}.txt';

      // Use FilePicker to let user choose location (or just download on Web)
      final result = await FilePicker.platform.saveFile(
        fileName: fileName,
        bytes: bytes,
        type: FileType.custom,
        allowedExtensions: ['txt'],
      );

      if (result != null && context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('文件保存成功')));
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error saving file: $e');
      }
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('保存失败: $e')));
      }
    }
  }
}
