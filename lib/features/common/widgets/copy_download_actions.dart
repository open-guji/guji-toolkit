import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:file_saver/file_saver.dart';

class CopyDownloadActions extends StatelessWidget {
  final String text;
  final String fileNamePrefix;

  const CopyDownloadActions({
    super.key,
    required this.text,
    this.fileNamePrefix = 'result',
  });

  @override
  Widget build(BuildContext context) {
    if (text.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      width: double.infinity,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          TextButton.icon(
            onPressed: () => _copyToClipboard(context),
            icon: const Icon(Icons.copy, size: 16),
            label: const Text('复制'),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              visualDensity: VisualDensity.compact,
            ),
          ),
          const SizedBox(width: 8),
          TextButton.icon(
            onPressed: () => _saveAsFile(context),
            icon: const Icon(Icons.save_alt, size: 16),
            label: const Text('保存'),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              visualDensity: VisualDensity.compact,
            ),
          ),
        ],
      ),
    );
  }

  void _copyToClipboard(BuildContext context) {
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
    final bytes = utf8.encode(text);

    try {
      final String fileName =
          '${fileNamePrefix}_${DateTime.now().millisecondsSinceEpoch}';

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
