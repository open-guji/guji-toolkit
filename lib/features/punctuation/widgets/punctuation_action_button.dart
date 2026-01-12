import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/bloc.dart';
import '../models/punctuation_config.dart';

class PunctuationActionButton extends StatelessWidget {
  const PunctuationActionButton({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PunctuationBloc, PunctuationState>(
      buildWhen: (previous, current) =>
          previous.isProcessing != current.isProcessing ||
          previous.progress != current.progress ||
          previous.selectedMethod != current.selectedMethod ||
          previous.selectedModel != current.selectedModel ||
          previous.installedModels != current.installedModels,
      builder: (context, state) {
        final isSpecialized =
            state.selectedMethod == PunctuationMethod.specialized;
        final isModelInstalled = state.installedModels.contains(
          state.selectedModel,
        );
        final canPunctuate = !isSpecialized || isModelInstalled;

        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 400, // 增加宽度
                height: 52, // 略微增加高度
                child: ElevatedButton(
                  onPressed: (state.isProcessing || !canPunctuate)
                      ? null
                      : () {
                          context.read<PunctuationBloc>().add(
                            const PerformPunctuationEvent(),
                          );
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    elevation: 2, // 增加微弱投影
                    shadowColor: Theme.of(
                      context,
                    ).colorScheme.primary.withValues(alpha: 0.3),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(26), // 更圆润
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (state.isProcessing) ...[
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
                          (!isModelInstalled && isSpecialized)
                              ? '正在下载 ${(state.progress * 100).toStringAsFixed(0)}%'
                              : '正在处理',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ] else ...[
                        const Icon(Icons.auto_fix_high, size: 20),
                        const SizedBox(width: 12),
                        const Text(
                          '开始自动标点',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              if (!canPunctuate) ...[
                const SizedBox(height: 8),
                Text(
                  '请先在右侧安装选中的模型',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.error,
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
