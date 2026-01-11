import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:file_picker/file_picker.dart';
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
                  const SizedBox(width: 16),
                  // Storage Location Selector
                  Icon(
                    Icons.save_outlined,
                    size: 16,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 4),
                  Text('存储位置', style: Theme.of(context).textTheme.bodySmall),
                  const SizedBox(width: 8),
                  _StorageLocationDropdown(
                    selectedLocation: state.storageLocation,
                    onChanged: (value) {
                      if (value != null) {
                        context.read<PunctuationBloc>().add(
                          UpdateStorageLocationEvent(value),
                        );
                      }
                    },
                  ),
                  if (state.storageLocation == StorageLocation.localFile) ...[
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.folder_open, size: 18),
                      tooltip: '选择模型文件夹',
                      onPressed: () async {
                        final String? selectedDirectory = await FilePicker
                            .platform
                            .getDirectoryPath();
                        if (selectedDirectory != null && context.mounted) {
                          context.read<PunctuationBloc>().add(
                            UpdateLocalModelPathEvent(selectedDirectory),
                          );
                        }
                      },
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    if (state.localModelPath != null) ...[
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          state.localModelPath!,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                                overflow: TextOverflow.ellipsis,
                              ),
                          maxLines: 1,
                        ),
                      ),
                    ],
                  ],
                  const Spacer(),
                  // 下载源切换
                  Text(
                    '下载来源',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(width: 8),
                  SegmentedButton<String>(
                    segments: const [
                      ButtonSegment(value: 'hf-mirror', label: Text('国内镜像')),
                      ButtonSegment(value: 'huggingface', label: Text('官方源')),
                    ],
                    selected: {state.downloadSource},
                    onSelectionChanged: (newSelection) {
                      context.read<PunctuationBloc>().add(
                        UpdateDownloadSourceEvent(newSelection.first),
                      );
                    },
                    showSelectedIcon: false,
                    style: SegmentedButton.styleFrom(
                      padding: EdgeInsets.zero,
                      visualDensity: VisualDensity.compact,
                      textStyle: Theme.of(context).textTheme.labelSmall,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const SizedBox(height: 12),
              ...state.availableModels.map((model) {
                final isInstalled = state.installedModels.contains(model.id);
                // Currently, personal models are not on hf-mirror or modelscope
                // If modelscope_url is empty, we assume it's NOT available for hf-mirror yet
                final isAvailableForSource =
                    state.downloadSource == 'huggingface' ||
                    (model.modelscopeUrl.isNotEmpty &&
                        state.downloadSource == 'hf-mirror');

                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              model.name,
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              model.id,
                              style: Theme.of(context).textTheme.labelSmall
                                  ?.copyWith(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurfaceVariant,
                                  ),
                            ),
                          ],
                        ),
                      ),
                      if (isInstalled) ...[
                        IconButton(
                          icon: const Icon(
                            Icons.drive_file_move_outlined,
                            size: 16,
                          ),
                          onPressed: () {
                            context.read<PunctuationBloc>().add(
                              ExportModelEvent(model.id),
                            );
                          },
                          tooltip: '导出到桌面',
                          constraints: const BoxConstraints(),
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                        ),
                        Icon(
                          Icons.check_circle,
                          size: 16,
                          color: Colors.green.shade400,
                        ),
                      ] else if (state.isProcessing &&
                          state.selectedModel == model.id)
                        Text(
                          '${(state.progress * 100).toStringAsFixed(0)}%',
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(
                                color: Theme.of(context).colorScheme.primary,
                              ),
                        )
                      else if (!isAvailableForSource)
                        Text(
                          '内容暂不可用',
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(
                                color: Theme.of(context).colorScheme.error,
                              ),
                        )
                      else
                        TextButton.icon(
                          onPressed: () {
                            context.read<PunctuationBloc>().add(
                              InstallModelEvent(model.id),
                            );
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

class _StorageLocationDropdown extends StatelessWidget {
  final StorageLocation selectedLocation;
  final ValueChanged<StorageLocation?> onChanged;

  const _StorageLocationDropdown({
    required this.selectedLocation,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(4),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<StorageLocation>(
          value: selectedLocation,
          onChanged: onChanged,
          isDense: true,
          style: Theme.of(context).textTheme.bodySmall,
          items: StorageLocation.values.map((location) {
            return DropdownMenuItem<StorageLocation>(
              value: location,
              child: Text(location.label),
            );
          }).toList(),
        ),
      ),
    );
  }
}
