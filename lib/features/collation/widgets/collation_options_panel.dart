import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guji_toolkit/features/collation/bloc/bloc.dart';

class CollationOptionsPanel extends StatelessWidget {
  const CollationOptionsPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CollationBloc, CollationState>(
      builder: (context, state) {
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '对校选项',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                CheckboxListTile(
                  title: const Text('忽略标点符号'),
                  subtitle: const Text('对比时不考虑标点差异'),
                  value: state.ignorePunctuation,
                  onChanged: (value) {
                    context.read<CollationBloc>().add(
                      ToggleIgnorePunctuationEvent(value ?? true),
                    );
                  },
                  controlAffinity: ListTileControlAffinity.leading,
                  contentPadding: EdgeInsets.zero,
                ),
                CheckboxListTile(
                  title: const Text('繁简兼容'),
                  subtitle: const Text('自动识别繁简体对应关系'),
                  value: state.ignoreTraditional,
                  onChanged: (value) {
                    context.read<CollationBloc>().add(
                      ToggleIgnoreTraditionalEvent(value ?? true),
                    );
                  },
                  controlAffinity: ListTileControlAffinity.leading,
                  contentPadding: EdgeInsets.zero,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
