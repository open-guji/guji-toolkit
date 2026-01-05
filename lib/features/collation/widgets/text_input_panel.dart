import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:guji_toolkit/features/collation/providers/collation_provider.dart';

class TextInputPanel extends ConsumerWidget {
  const TextInputPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '文本输入',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Row(
                children: [
                  // 文本1输入框
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '文本 1',
                          style: Theme.of(context).textTheme.labelLarge,
                        ),
                        const SizedBox(height: 8),
                        Expanded(
                          child: TextField(
                            maxLines: null,
                            expands: true,
                            decoration: const InputDecoration(
                              hintText: '请输入第一段古籍文本...',
                              border: OutlineInputBorder(),
                            ),
                            onChanged: (value) {
                              ref
                                  .read(collationProvider.notifier)
                                  .updateText1(value);
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  // 文本2输入框
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '文本 2',
                          style: Theme.of(context).textTheme.labelLarge,
                        ),
                        const SizedBox(height: 8),
                        Expanded(
                          child: TextField(
                            maxLines: null,
                            expands: true,
                            decoration: const InputDecoration(
                              hintText: '请输入第二段古籍文本...',
                              border: OutlineInputBorder(),
                            ),
                            onChanged: (value) {
                              ref
                                  .read(collationProvider.notifier)
                                  .updateText2(value);
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
