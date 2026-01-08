import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:file_saver/file_saver.dart';
import '../../../models/collation_state.dart';
import '../../../services/collation_result_exporter.dart';

class MergeActions extends StatelessWidget {
  final CollationResult result;
  final Map<int, DiffResolution> resolutions;

  const MergeActions({
    super.key,
    required this.result,
    required this.resolutions,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
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
          'collation_result_${DateTime.now().millisecondsSinceEpoch}';

      if (kIsWeb) {
        await FileSaver.instance.saveFile(
          name: fileName,
          bytes: bytes,
          fileExtension: 'txt',
          mimeType: MimeType.text,
        );
      } else {
        await FileSaver.instance.saveAs(
          name: fileName,
          bytes: bytes,
          fileExtension: 'txt',
          mimeType: MimeType.text,
        );
      }

      if (context.mounted) {
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
