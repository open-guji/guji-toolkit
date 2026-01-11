import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/bloc.dart';

class PunctuationModelManagementPanel extends StatelessWidget {
  const PunctuationModelManagementPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PunctuationBloc, PunctuationState>(
      builder: (context, state) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(
              context,
            ).colorScheme.surfaceContainerHighest.withAlpha(50),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Theme.of(context).colorScheme.outlineVariant,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.cloud_download_outlined,
                    size: 18,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '模型管理',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  if (state.isProcessing && state.progress < 1.0)
                    Text(
                      '下载中: ${(state.progress * 100).toStringAsFixed(0)}%',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              // Simplified list of models for now
              ...['Xenova/siku-bert', 'Xenova/puku-bert'].map((model) {
                final isInstalled = state.installedModels.contains(model);
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          model,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                      if (isInstalled)
                        Icon(
                          Icons.check_circle,
                          size: 16,
                          color: Colors.green.shade400,
                        )
                      else
                        TextButton.icon(
                          onPressed: () {
                            // TODO: Add event for downloading model
                          },
                          icon: const Icon(Icons.download, size: 14),
                          label: const Text('安装'),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            textStyle: Theme.of(context).textTheme.labelSmall,
                          ),
                        ),
                    ],
                  ),
                );
              }),
              if (state.isProcessing && state.progress < 1.0)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: LinearProgressIndicator(
                    value: state.progress,
                    minHeight: 2,
                    backgroundColor: Theme.of(
                      context,
                    ).colorScheme.surfaceContainerHighest,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
