import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/bloc.dart';
import '../models/punctuation_model.dart';
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
            Row(
              children: [
                Icon(
                  Icons.tune,
                  size: 18,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  '标点方式',
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 16),
                // Method selection
                _MethodDropdown(
                  selectedMethod: state.selectedMethod,
                  onChanged: (value) {
                    if (value != null) {
                      context.read<PunctuationBloc>().add(
                        SwitchMethodEvent(value),
                      );
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),

            if (state.selectedMethod == PunctuationMethod.specialized)
              _SpecializedModelOptions(state: state)
            else
              _LLMOptions(state: state),
          ],
        );
      },
    );
  }
}

class _MethodDropdown extends StatelessWidget {
  final PunctuationMethod selectedMethod;
  final ValueChanged<PunctuationMethod?> onChanged;

  const _MethodDropdown({
    required this.selectedMethod,
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
        child: DropdownButton<PunctuationMethod>(
          value: selectedMethod,
          onChanged: onChanged,
          isDense: true,
          style: Theme.of(context).textTheme.bodySmall,
          items: PunctuationMethod.values.map((method) {
            return DropdownMenuItem<PunctuationMethod>(
              value: method,
              child: Text(method.label),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _SpecializedModelOptions extends StatelessWidget {
  final PunctuationState state;

  const _SpecializedModelOptions({required this.state});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const SizedBox(width: 26), // Access icons alignment
        Text('模型选择', style: Theme.of(context).textTheme.bodyMedium),
        const SizedBox(width: 8),
        Expanded(
          child: _ModelDropdown(
            selectedModel: state.selectedModel,
            models: state.availableModels,
            onChanged: (value) {
              if (value != null) {
                context.read<PunctuationBloc>().add(SelectModelEvent(value));
              }
            },
          ),
        ),
      ],
    );
  }
}

class _ModelDropdown extends StatelessWidget {
  final String selectedModel;
  final List<PunctuationModel> models;
  final ValueChanged<String?> onChanged;

  const _ModelDropdown({
    required this.selectedModel,
    required this.models,
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
        child: DropdownButton<String>(
          value: selectedModel,
          onChanged: onChanged,
          isDense: true,
          isExpanded: true,
          style: Theme.of(context).textTheme.bodySmall,
          items: models.map((PunctuationModel model) {
            return DropdownMenuItem<String>(
              value: model.id,
              child: Text(model.name, overflow: TextOverflow.ellipsis),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _LLMOptions extends StatelessWidget {
  final PunctuationState state;

  const _LLMOptions({required this.state});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const SizedBox(width: 26),
            Text('服务类型', style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(width: 8),
            _ServiceTypeDropdown(
              selectedType: state.llmConfig.serviceType,
              onChanged: (value) {
                if (value != null) {
                  context.read<PunctuationBloc>().add(
                    UpdateLLMConfigEvent(
                      state.llmConfig.copyWith(serviceType: value),
                    ),
                  );
                }
              },
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (state.llmConfig.serviceType == LLMServiceType.cloud)
          _CloudLLMInputs(state: state)
        else
          _LocalLLMInputs(state: state),
      ],
    );
  }
}

class _ServiceTypeDropdown extends StatelessWidget {
  final LLMServiceType selectedType;
  final ValueChanged<LLMServiceType?> onChanged;

  const _ServiceTypeDropdown({
    required this.selectedType,
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
        child: DropdownButton<LLMServiceType>(
          value: selectedType,
          onChanged: onChanged,
          isDense: true,
          style: Theme.of(context).textTheme.bodySmall,
          items: LLMServiceType.values.map((type) {
            return DropdownMenuItem<LLMServiceType>(
              value: type,
              child: Text(type.label),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _CloudLLMInputs extends StatelessWidget {
  final PunctuationState state;
  const _CloudLLMInputs({required this.state});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 26.0),
      child: Column(
        children: [
          const SizedBox(height: 8),
          TextField(
            decoration: const InputDecoration(
              labelText: 'API Provider (e.g., OpenAI, DeepSeek)',
              isDense: true,
              border: OutlineInputBorder(),
            ),
            style: Theme.of(context).textTheme.bodySmall,
            onChanged: (val) {
              context.read<PunctuationBloc>().add(
                UpdateLLMConfigEvent(state.llmConfig.copyWith(provider: val)),
              );
            },
            controller: TextEditingController(text: state.llmConfig.provider)
              ..selection = TextSelection.fromPosition(
                TextPosition(offset: state.llmConfig.provider.length),
              ),
          ),
          const SizedBox(height: 8),
          TextField(
            decoration: const InputDecoration(
              labelText: 'API Key',
              isDense: true,
              border: OutlineInputBorder(),
            ),
            style: Theme.of(context).textTheme.bodySmall,
            obscureText: true,
            onChanged: (val) {
              context.read<PunctuationBloc>().add(
                UpdateLLMConfigEvent(state.llmConfig.copyWith(apiKey: val)),
              );
            },
          ),
          const SizedBox(height: 8),
          TextField(
            decoration: const InputDecoration(
              labelText: 'Model Name (e.g., gpt-3.5-turbo)',
              isDense: true,
              border: OutlineInputBorder(),
            ),
            style: Theme.of(context).textTheme.bodySmall,
            onChanged: (val) {
              context.read<PunctuationBloc>().add(
                UpdateLLMConfigEvent(state.llmConfig.copyWith(modelName: val)),
              );
            },
            controller: TextEditingController(text: state.llmConfig.modelName)
              ..selection = TextSelection.fromPosition(
                TextPosition(offset: state.llmConfig.modelName.length),
              ),
          ),
        ],
      ),
    );
  }
}

class _LocalLLMInputs extends StatelessWidget {
  final PunctuationState state;
  const _LocalLLMInputs({required this.state});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 26.0),
      child: Column(
        children: [
          const SizedBox(height: 8),
          TextField(
            decoration: const InputDecoration(
              labelText: 'Base URL (e.g., http://localhost:11434/v1)',
              isDense: true,
              border: OutlineInputBorder(),
            ),
            style: Theme.of(context).textTheme.bodySmall,
            onChanged: (val) {
              context.read<PunctuationBloc>().add(
                UpdateLLMConfigEvent(state.llmConfig.copyWith(baseUrl: val)),
              );
            },
            controller: TextEditingController(text: state.llmConfig.baseUrl)
              ..selection = TextSelection.fromPosition(
                TextPosition(offset: state.llmConfig.baseUrl.length),
              ),
          ),
          const SizedBox(height: 8),
          TextField(
            decoration: const InputDecoration(
              labelText: 'Model Name (e.g., llama2, qwen)',
              isDense: true,
              border: OutlineInputBorder(),
            ),
            style: Theme.of(context).textTheme.bodySmall,
            onChanged: (val) {
              context.read<PunctuationBloc>().add(
                UpdateLLMConfigEvent(state.llmConfig.copyWith(modelName: val)),
              );
            },
            controller: TextEditingController(text: state.llmConfig.modelName)
              ..selection = TextSelection.fromPosition(
                TextPosition(offset: state.llmConfig.modelName.length),
              ),
          ),
        ],
      ),
    );
  }
}
