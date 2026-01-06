import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guji_toolkit/features/collation/bloc/bloc.dart';
import 'package:guji_toolkit/features/collation/widgets/widgets.dart';

class CollationPageBloc extends StatelessWidget {
  const CollationPageBloc({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CollationBloc(),
      child: const _CollationPageContent(),
    );
  }
}

class _CollationPageContent extends StatelessWidget {
  const _CollationPageContent();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 标题区域
            Text(
              '古籍对校',
              style: Theme.of(
                context,
              ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              '比较两段古籍文本，输出差异分析结果',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            const CollationExamplesPanel(),
            const SizedBox(height: 24),

            // 主要内容区域
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 左侧：文本输入区
                  const Expanded(flex: 3, child: TextInputPanel()),
                  const SizedBox(width: 16),

                  // 右侧：选项和结果区
                  Expanded(
                    flex: 2,
                    child: Column(
                      children: [
                        // 对校选项
                        const CollationOptionsPanel(),
                        const SizedBox(height: 16),

                        // 对比按钮
                        BlocBuilder<CollationBloc, CollationState>(
                          builder: (context, state) {
                            return SizedBox(
                              width: double.infinity,
                              child: FilledButton.icon(
                                onPressed: state.isComparing
                                    ? null
                                    : () {
                                        context.read<CollationBloc>().add(
                                          const PerformCollationEvent(),
                                        );
                                      },
                                icon: state.isComparing
                                    ? const SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const Icon(Icons.compare_arrows),
                                label: Text(
                                  state.isComparing ? '对比中...' : '开始对比',
                                ),
                                style: FilledButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 16),

                        // 结果显示区
                        const Expanded(child: ResultDisplayPanel()),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
