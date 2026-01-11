import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
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
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: Theme.of(
                context,
              ).colorScheme.outlineVariant.withValues(alpha: 0.3),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // 第一行：标题、模型安装状态和操作按钮
                Row(
                  children: [
                    Icon(
                      Icons.download_outlined,
                      size: 14,
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withValues(alpha: 0.7),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '模型安装',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.8),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // 始终显示安装状态
                    Icon(
                      isInstalled
                          ? Icons.check_circle
                          : Icons.radio_button_unchecked,
                      size: 13,
                      color: isInstalled
                          ? Colors.green.shade600.withValues(alpha: 0.8)
                          : Theme.of(context).colorScheme.onSurfaceVariant
                                .withValues(alpha: 0.4),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      isInstalled ? '已安装' : '未安装',
                      style: TextStyle(
                        fontSize: 11,
                        color: isInstalled
                            ? Colors.green.shade700.withValues(alpha: 0.8)
                            : Theme.of(context).colorScheme.onSurfaceVariant
                                  .withValues(alpha: 0.7),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Spacer(),
                    if (!isInstalled && !isDownloading) ...[
                      SelectionContainer.disabled(
                        child: Text(
                          '确保你所在的地区可以访问 Hugging Face',
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(
                                fontSize: 10,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant
                                    .withValues(alpha: 0.7),
                              ),
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                    // 状态/操作按钮
                    _buildActionButton(
                      context,
                      state,
                      selectedModel,
                      isInstalled,
                      isDownloading,
                    ),
                  ],
                ),
                // 下载进度条
                if (isDownloading) ...[
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: state.progress,
                    minHeight: 2,
                    backgroundColor: Theme.of(
                      context,
                    ).colorScheme.surfaceContainerHighest,
                  ),
                ],
                // 模型元数据（作者和链接）
                const SizedBox(height: 8),
                _ModelMetadata(model: selectedModel),
              ],
            ),
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
      // 已安装状态：显示删除按钮
      return IconButton(
        onPressed: () {
          final bloc = context.read<PunctuationBloc>();
          // 确认删除
          showDialog(
            context: context,
            builder: (confirmContext) => AlertDialog(
              title: const Text('确认删除'),
              content: Text('确定要从缓存中删除模型 "${selectedModel.name}" 吗？'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(confirmContext),
                  child: const Text('取消'),
                ),
                TextButton(
                  onPressed: () {
                    bloc.add(DeleteModelEvent(selectedModel.id));
                    Navigator.pop(confirmContext);
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.error,
                  ),
                  child: const Text('确认删除'),
                ),
              ],
            ),
          );
        },
        icon: const Icon(Icons.delete_outline, size: 20),
        tooltip: '从缓存中删除',
        color: Theme.of(context).colorScheme.error.withValues(alpha: 0.7),
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(),
        visualDensity: VisualDensity.compact,
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
    final isAvailableForSource =
        state.downloadSource == 'huggingface' ||
        (selectedModel.hasOnnxRepo && state.downloadSource == 'modelscope');

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
      label: const Text('安装', style: TextStyle(fontSize: 13)),
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }
}

/// 模型元数据组件（作者、HuggingFace 链接等）
class _ModelMetadata extends StatelessWidget {
  final dynamic model;

  const _ModelMetadata({required this.model});

  Future<void> _openUrl(String urlString) async {
    final url = Uri.parse(urlString);
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 16,
      runSpacing: 6,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        // 模型大小 (第一位)
        if (model.size != null)
          _buildInfoItem(context, Icons.balance_outlined, '大小: ${model.size}'),
        // 原作者
        _buildInfoItem(
          context,
          Icons.person_outline,
          '作者: ${model.originalAuthor}',
        ),
        // HuggingFace 链接
        InkWell(
          onTap: () => _openUrl(model.getOriginalUrl()),
          child: _buildInfoItem(
            context,
            Icons.open_in_new,
            'HuggingFace 仓库',
            color: Theme.of(context).colorScheme.primary,
            underline: true,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoItem(
    BuildContext context,
    IconData icon,
    String label, {
    Color? color,
    bool underline = false,
  }) {
    final textColor = color ?? Theme.of(context).colorScheme.onSurfaceVariant;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: textColor),
        const SizedBox(width: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: textColor,
            decoration: underline ? TextDecoration.underline : null,
          ),
        ),
      ],
    );
  }
}
