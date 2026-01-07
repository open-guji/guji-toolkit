import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'diff_text_renderer.dart';
import 'collation_legend.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guji_toolkit/features/collation/bloc/bloc.dart';
import 'package:guji_diff/guji_diff.dart';

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
    // 计算进度
    final stats = _calculateProgress();
    final total = stats.total;
    final resolved = stats.resolved;
    final allResolved = total > 0 && resolved == total;

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
        Row(
          children: [
            const CollationLegend(),
            const Spacer(),
            // 进度指示器 (0/0 时不显示)
            if (total > 0)
              _buildProgressIndicator(context, resolved, total, allResolved),
            const SizedBox(width: 16),
            // 操作按钮
            ElevatedButton.icon(
              onPressed: () => _handleExport(context, isCopy: true),
              icon: const Icon(Icons.copy, size: 16),
              label: const Text('复制'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 12),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton.icon(
              onPressed: () => _handleExport(context, isCopy: false),
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

  _ProgressStats _calculateProgress() {
    int total = 0;
    int resolved = 0;
    int i = 0;
    final changes = result.mergedView;

    while (i < changes.length) {
      final change = changes[i];
      bool isDiff = false;
      bool isUnitResolved = false;

      // 检查是否是修改模式 (Delete + Insert)
      if (change.type == CollationType.delete && i + 1 < changes.length) {
        final nextChange = changes[i + 1];
        if (nextChange.type == CollationType.insert) {
          isDiff = true;
          // 修改模式下，只要其中一个有决议（通常是同步的）
          isUnitResolved =
              resolutions[i] != null &&
              resolutions[i] != DiffResolution.unresolved;
          i += 2;
        } else {
          isDiff = true;
          isUnitResolved =
              resolutions[i] != null &&
              resolutions[i] != DiffResolution.unresolved;
          i++;
        }
      } else if (change.type != CollationType.equal) {
        isDiff = true;
        isUnitResolved =
            resolutions[i] != null &&
            resolutions[i] != DiffResolution.unresolved;
        i++;
      } else {
        i++;
      }

      if (isDiff) {
        total++;
        if (isUnitResolved) {
          resolved++;
        }
      }
    }
    return _ProgressStats(total: total, resolved: resolved);
  }

  String _getResolvedText() {
    final buffer = StringBuffer();
    int i = 0;
    final changes = result.mergedView;

    while (i < changes.length) {
      final change = changes[i];
      final resolution = resolutions[i] ?? DiffResolution.unresolved;

      if (change.type == CollationType.equal) {
        buffer.write(change.text);
        i++;
      } else if (change.type == CollationType.delete &&
          i + 1 < changes.length &&
          changes[i + 1].type == CollationType.insert) {
        // 修改模式
        final insertChange = changes[i + 1];
        if (resolution == DiffResolution.acceptNew) {
          buffer.write(insertChange.text);
        } else {
          // 默认保留底本 (Original) 如果未解决或接受原件
          buffer.write(change.text);
        }
        i += 2;
      } else if (change.type == CollationType.delete) {
        // 单独删除
        if (resolution != DiffResolution.acceptNew) {
          // 只有在未采纳删除（即保留原件）时才写入
          buffer.write(change.text);
        }
        i++;
      } else if (change.type == CollationType.insert) {
        // 单独新增
        if (resolution == DiffResolution.acceptNew) {
          buffer.write(change.text);
        }
        i++;
      }
    }
    return buffer.toString();
  }

  void _handleExport(BuildContext context, {required bool isCopy}) {
    final stats = _calculateProgress();
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
    final text = _getResolvedText();
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

  void _saveAsFile(BuildContext context) {
    final text = _getResolvedText();
    // 简单的保存逻辑，打印并在提示中说明。
    // 在实际 Web 环境中，通常通过 js 触发下载。
    // 这里我们先显示一个提示。
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('正在保存为文件... (功能实现中)')));

    debugPrint('Resolved text length: ${text.length}');
    // For Web platform, you can use:
    // import 'dart:html' as html;
    // final blob = html.Blob([text]);
    // final url = html.Url.createObjectUrlFromBlob(blob);
    // final anchor = html.AnchorElement(href: url)
    //   ..setAttribute("download", "collation_result.txt")
    //   ..click();
    // html.Url.revokeObjectUrl(url);
  }
}

class _ProgressStats {
  final int total;
  final int resolved;
  const _ProgressStats({required this.total, required this.resolved});
}
