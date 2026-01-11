import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/bloc.dart';

class PunctuationActionButton extends StatelessWidget {
  const PunctuationActionButton({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PunctuationBloc, PunctuationState>(
      builder: (context, state) {
        final isLoading = state.isProcessing;

        return SizedBox(
          height: 48,
          child: ElevatedButton(
            onPressed: isLoading
                ? null
                : () {
                    context.read<PunctuationBloc>().add(
                      const PerformPunctuationEvent(),
                    );
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isLoading) ...[
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '正在标点...',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ] else ...[
                  const Icon(Icons.auto_fix_high, size: 20),
                  const SizedBox(width: 8),
                  const Text(
                    '开始自动标点',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
