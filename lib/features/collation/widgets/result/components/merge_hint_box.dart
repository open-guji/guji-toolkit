import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../bloc/bloc.dart';

class MergeHintBox extends StatelessWidget {
  const MergeHintBox({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CollationBloc, CollationState>(
      builder: (context, state) {
        if (!state.showMergeHint) return const SizedBox.shrink();

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.blue.withAlpha(30),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.blue.withAlpha(70)),
          ),
          child: Row(
            children: [
              const Icon(Icons.lightbulb_outline, size: 18, color: Colors.blue),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '提示：您可以把鼠标指针移到修改的文字上面来确认或切换修改内容。',
                  style: TextStyle(
                    fontSize: 13,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, size: 16),
                onPressed: () {
                  context.read<CollationBloc>().add(
                    const DismissMergeHintEvent(),
                  );
                },
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
        );
      },
    );
  }
}
