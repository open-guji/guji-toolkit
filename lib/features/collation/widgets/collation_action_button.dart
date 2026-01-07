import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/bloc.dart';

/// 对校操作按钮
///
/// 处理各种加载状态（对校中、OpenCC准备中）以及禁用逻辑
class CollationActionButton extends StatelessWidget {
  const CollationActionButton({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CollationBloc, CollationState>(
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
    );
  }
}
