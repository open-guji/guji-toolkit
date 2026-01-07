import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guji_toolkit/features/collation/bloc/bloc.dart';
import 'package:guji_toolkit/features/collation/widgets/widgets.dart';

/// 古籍对校页面
///
/// 提供两段文本的逐字比对功能，支持：
/// - 忽略标点符号
/// - 繁简兼容（使用 OpenCC）
/// - 相似度计算
class CollationPage extends StatelessWidget {
  const CollationPage({super.key});

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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 标题区域
              Text(
                '古籍对校',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '比较两段古籍文本，输出差异分析结果',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 24),

              // 1. 设置部分 (最优先显示)
              const CollationOptionsPanel(),
              const SizedBox(height: 16),

              // 2. 文本输入区与示例 (响应式布局)
              LayoutBuilder(
                builder: (context, constraints) {
                  // 屏幕较宽时左右排列，较窄时上下排列
                  final isWide = constraints.maxWidth > 900;

                  return _ResponsiveInputArea(isWide: isWide);
                },
              ),
              const SizedBox(height: 24),

              // 3. 对比按钮
              BlocBuilder<CollationBloc, CollationState>(
                builder: (context, state) {
                  final isDisabled = state.isButtonDisabled;
                  String buttonText;
                  Widget buttonIcon;

                  if (state.isComparing) {
                    buttonText = '对比中...';
                    buttonIcon = const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    );
                  } else if (state.ignoreTraditional && state.isOpenCCLoading) {
                    buttonText = 'OpenCC 加载中...';
                    buttonIcon = const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    );
                  } else {
                    buttonText = '开始对比';
                    buttonIcon = const Icon(Icons.compare_arrows);
                  }

                  return SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: isDisabled
                          ? null
                          : () {
                              context.read<CollationBloc>().add(
                                const PerformCollationEvent(),
                              );
                            },
                      icon: buttonIcon,
                      label: Text(buttonText),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 32),

              // 4. 结果显示区
              const ResultDisplayPanel(),
              const SizedBox(height: 48), // Bottom padding
            ],
          ),
        ),
      ),
    );
  }
}

class _ResponsiveInputArea extends StatelessWidget {
  final bool isWide;

  const _ResponsiveInputArea({required this.isWide});

  @override
  Widget build(BuildContext context) {
    if (isWide) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Expanded(flex: 3, child: TextInputPanel(isWide: true)),
          const SizedBox(width: 24),
          const Expanded(
            flex: 1,
            child: CollationExamplesPanel(isVertical: true),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const TextInputPanel(isWide: false),
        const SizedBox(height: 16),
        const CollationExamplesPanel(),
      ],
    );
  }
}
