import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/bloc.dart';

class PunctuationOptionsPanel extends StatelessWidget {
  const PunctuationOptionsPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PunctuationBloc, PunctuationState>(
      builder: (context, state) {
        return Row(
          children: [
            Icon(
              Icons.tune,
              size: 18,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 8),
            Text(
              '模型选择',
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 16),
            // Model selection
            _ModelDropdown(
              selectedModel: state.selectedModel,
              models: const ['Xenova/siku-bert'],
              onChanged: (value) {
                if (value != null) {
                  context.read<PunctuationBloc>().add(SelectModelEvent(value));
                }
              },
            ),
          ],
        );
      },
    );
  }
}

class _ModelDropdown extends StatelessWidget {
  final String selectedModel;
  final List<String> models;
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
          style: Theme.of(context).textTheme.bodySmall,
          items: models.map((String value) {
            return DropdownMenuItem<String>(value: value, child: Text(value));
          }).toList(),
        ),
      ),
    );
  }
}
