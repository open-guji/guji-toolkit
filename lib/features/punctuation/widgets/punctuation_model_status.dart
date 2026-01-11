import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/bloc.dart';
import '../models/punctuation_config.dart';

/// 单个模型的状态显示和管理组件
/// 仅在专用模型模式下显示选中模型的状态
class PunctuationModelStatus extends StatelessWidget {
  const PunctuationModelStatus({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PunctuationBloc, PunctuationState>(
      builder: (context, state) {
        // 只在专用模型模式下显示
        if (state.selectedMethod != PunctuationMethod.specialized) {
          return const SizedBox.shrink();
        }

        // 如果没有可用模型，不显示
        if (state.availableModels.isEmpty) {
          return const SizedBox.shrink();
        }

        final selectedModel = state.availableModels.firstWhere(
          (m) => m.id == state.selectedModel,
          orElse: () => state.availableModels.first,
        );

        final isInstalled = state.installedModels.contains(selectedModel.id);
        final isDownloading = state.isProcessing && !isInstalled;

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: Theme.of(context)
                  .colorScheme
                  .outlineVariant
                  .withValues(alpha: 0.5),
            ),
          ),
          child: Row(
            children: [
              // 模型信息
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.download_outlined,
                          size: 16,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '模型状态',
                          style: Theme.of(context)
                              .textTheme
                              .labelLarge
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          selectedModel.name,
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                                  ),
                        ),
                      ],
                    ),
                    if (isDownloading) ...[
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: state.progress,
                        minHeight: 2,
                        backgroundColor:
                            Theme.of(context).colorScheme.surfaceContainerHighest,
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(width: 16),

              // 下载源选择（仅在未安装且未下载时显示）
              if (!isInstalled && !isDownloading) ...[
                Text(
                  '下载源',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
                const SizedBox(width: 8),
                SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(
                      value: 'hf-mirror',
                      label: Text('国内', style: TextStyle(fontSize: 12)),
                    ),
                    ButtonSegment(
                      value: 'huggingface',
                      label: Text('官方', style: TextStyle(fontSize: 12)),
                    ),
                  ],
                  selected: {state.downloadSource},
                  onSelectionChanged: (newSelection) {
                    context.read<PunctuationBloc>().add(
                          UpdateDownloadSourceEvent(newSelection.first),
                        );
                  },
                  showSelectedIcon: false,
                  style: SegmentedButton.styleFrom(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    visualDensity: VisualDensity.compact,
                  ),
                ),
                const SizedBox(width: 16),
              ],

              // 状态/操作按钮
              _buildActionButton(context, state, selectedModel, isInstalled,
                  isDownloading),
            ],
          ),
        );
      },
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    PunctuationState state,
    dynamic selectedModel,
    bool isInstalled,
    bool isDownloading,
  ) {
    if (isInstalled) {
      // 已安装状态
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.check_circle,
            size: 16,
            color: Colors.green.shade600,
          ),
          const SizedBox(width: 6),
          Text(
            '已安装',
            style: TextStyle(
              fontSize: 13,
              color: Colors.green.shade700,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      );
    }

    if (isDownloading) {
      // 下载中状态
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '${(state.progress * 100).toStringAsFixed(0)}%',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      );
    }

    // 检查模型是否可用于当前下载源
    final isAvailableForSource = state.downloadSource == 'huggingface' ||
        (selectedModel.modelscopeUrl.isNotEmpty &&
            state.downloadSource == 'hf-mirror');

    if (!isAvailableForSource) {
      return Text(
        '该源暂不可用',
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Theme.of(context).colorScheme.error,
            ),
      );
    }

    // 未安装状态 - 显示安装按钮
    return TextButton.icon(
      onPressed: () {
        context.read<PunctuationBloc>().add(
              InstallModelEvent(selectedModel.id),
            );
      },
      icon: const Icon(Icons.download, size: 16),
      label: const Text('安装模型', style: TextStyle(fontSize: 13)),
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }
}
