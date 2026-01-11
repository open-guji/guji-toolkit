import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../common/widgets/widgets.dart';
import '../bloc/bloc.dart';
import '../models/punctuation_config.dart';

class PunctuationOptionsPanel extends StatelessWidget {
  const PunctuationOptionsPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PunctuationBloc, PunctuationState>(
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 标题
            Row(
              children: [
                Icon(
                  Icons.tune,
                  size: 18,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  '配置选项',
                  style: Theme.of(context)
                      .textTheme
                      .titleSmall
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // 标点方式选择
            _MethodSelector(state: state),
            const SizedBox(height: 16),

            // 模型选择（仅在专用模型模式下显示）
            if (state.selectedMethod == PunctuationMethod.specialized)
              _ModelSelector(state: state)
            else
              _LLMConfigSection(state: state),
          ],
        );
      },
    );
  }
}

/// 标点方式选择器
class _MethodSelector extends StatelessWidget {
  final PunctuationState state;

  const _MethodSelector({required this.state});

  String _getMethodDescription(PunctuationMethod method) {
    switch (method) {
      case PunctuationMethod.specialized:
        return '使用专门训练的古文标点模型，准确度高，支持离线使用';
      case PunctuationMethod.llm:
        return '使用大语言模型进行标点，支持自定义提示词，需要网络连接';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 左侧：标签和下拉框
        SizedBox(
          width: 280,
          child: Row(
            children: [
              SizedBox(
                width: 80,
                child: Text('标点方式',
                    style: Theme.of(context).textTheme.bodyMedium),
              ),
              Expanded(
                child: SimpleDropdown<PunctuationMethod>(
                  value: state.selectedMethod,
                  items: PunctuationMethod.values,
                  itemLabel: (method) => method.label,
                  onChanged: (value) {
                    if (value != null) {
                      context.read<PunctuationBloc>().add(
                            SwitchMethodEvent(value),
                          );
                    }
                  },
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),

        // 右侧：简介
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              _getMethodDescription(state.selectedMethod),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    height: 1.5,
                  ),
            ),
          ),
        ),
      ],
    );
  }
}

/// 模型选择器（专用模型模式）
class _ModelSelector extends StatelessWidget {
  final PunctuationState state;

  const _ModelSelector({required this.state});

  String _getModelDescription(String modelId) {
    // 根据模型 ID 返回不同的描述
    if (modelId.contains('guwen')) {
      return '专为古文断句设计，基于标点标注，适合文言文标点';
    } else if (modelId.contains('wiki')) {
      return '基于维基百科训练，适合现代文和古文混合文本';
    } else {
      return '通用古文标点模型';
    }
  }

  @override
  Widget build(BuildContext context) {
    // 如果没有可用模型，显示加载提示
    if (state.availableModels.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 8.0),
        child: Text('正在加载模型列表...'),
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 左侧：标签和下拉框
        SizedBox(
          width: 280,
          child: Row(
            children: [
              SizedBox(
                width: 80,
                child: Text('模型选择',
                    style: Theme.of(context).textTheme.bodyMedium),
              ),
              Expanded(
                child: SimpleDropdown<String>(
                  value: state.selectedModel,
                  items: state.availableModels.map((m) => m.id).toList(),
                  itemLabel: (id) {
                    final model = state.availableModels
                        .firstWhere((m) => m.id == id, orElse: () {
                      // 如果找不到，返回一个默认模型
                      return state.availableModels.first;
                    });
                    return model.name;
                  },
                  onChanged: (value) {
                    if (value != null) {
                      context
                          .read<PunctuationBloc>()
                          .add(SelectModelEvent(value));
                    }
                  },
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),

        // 右侧：简介
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              _getModelDescription(state.selectedModel),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    height: 1.5,
                  ),
            ),
          ),
        ),
      ],
    );
  }
}

/// LLM 配置区域
class _LLMConfigSection extends StatelessWidget {
  final PunctuationState state;

  const _LLMConfigSection({required this.state});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 显示开发中提示
        const _DevelopmentNotice(),
        const SizedBox(height: 16),

        // 大语言模型选择（暂时禁用）
        _LLMProviderSelector(state: state, enabled: false),
      ],
    );
  }
}

/// LLM 提供商选择器
class _LLMProviderSelector extends StatelessWidget {
  final PunctuationState state;
  final bool enabled;

  const _LLMProviderSelector({
    required this.state,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 左侧：标签和下拉框
        SizedBox(
          width: 280,
          child: Row(
            children: [
              SizedBox(
                width: 80,
                child: Text(
                  '选择模型',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: enabled
                            ? Theme.of(context).colorScheme.onSurface
                            : Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ),
              Expanded(
                child: SimpleDropdown<LLMProvider>(
                  value: state.llmConfig.selectedProvider,
                  items: LLMProvider.values,
                  itemLabel: (provider) => provider.label,
                  enabled: enabled,
                  onChanged: enabled
                      ? (value) {
                          if (value != null) {
                            context.read<PunctuationBloc>().add(
                                  UpdateLLMConfigEvent(
                                    state.llmConfig
                                        .copyWith(selectedProvider: value),
                                  ),
                                );
                          }
                        }
                      : null,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),

        // 右侧：简介
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              state.llmConfig.selectedProvider.description,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    height: 1.5,
                  ),
            ),
          ),
        ),
      ],
    );
  }
}

/// 正在开发中提示组件
class _DevelopmentNotice extends StatelessWidget {
  const _DevelopmentNotice();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondaryContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            size: 20,
            color: Theme.of(context).colorScheme.secondary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              '此功能正在开发中，敬请期待',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSecondaryContainer,
                    height: 1.5,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
