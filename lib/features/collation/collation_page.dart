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
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    '古籍对校',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '比较两段古籍文本，输出差异分析结果',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // 1. 设置与示例 (并排显示)
              LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth > 800;
                  if (isWide) {
                    return const Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(flex: 2, child: CollationOptionsPanel()),
                        SizedBox(width: 32),
                        Expanded(flex: 3, child: CollationExamplesPanel()),
                      ],
                    );
                  }
                  return const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CollationOptionsPanel(),
                      SizedBox(height: 12),
                      CollationExamplesPanel(),
                    ],
                  );
                },
              ),
              const SizedBox(height: 16),

              // 2. 文本输入区 (全宽)
              LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth > 700;
                  return TextInputPanel(isWide: isWide);
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
