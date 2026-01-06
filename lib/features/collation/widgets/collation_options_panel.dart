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
                  subtitle: _buildTraditionalSubtitle(state),
                  value: state.ignoreTraditional,
                  onChanged: (value) {
                    context.read<CollationBloc>().add(
                      ToggleIgnoreTraditionalEvent(value ?? true),
                    );
                  },
                  controlAffinity: ListTileControlAffinity.leading,
                  contentPadding: EdgeInsets.zero,
                ),
                // OpenCC 加载状态指示器
                if (state.ignoreTraditional && state.isOpenCCLoading)
                  Padding(
                    padding: const EdgeInsets.only(left: 16.0, top: 8.0),
                    child: Row(
                      children: [
                        const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'OpenCC 正在加载...',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: Theme.of(context).colorScheme.secondary,
                              ),
                        ),
                      ],
                    ),
                  ),
                // OpenCC 加载错误
                if (state.openCCError != null)
                  Padding(
                    padding: const EdgeInsets.only(left: 16.0, top: 8.0),
                    child: Text(
                      'OpenCC 加载失败: ${state.openCCError}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTraditionalSubtitle(CollationState state) {
    if (state.isOpenCCLoading) {
      return const Text('正在加载繁简转换引擎...');
    } else if (state.isOpenCCReady) {
      return const Text('自动识别繁简体对应关系 ✓');
    } else if (state.openCCError != null) {
      return const Text('繁简转换不可用');
    } else {
      return const Text('自动识别繁简体对应关系');
    }
  }
}
