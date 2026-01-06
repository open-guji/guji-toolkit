import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guji_toolkit/features/collation/bloc/bloc.dart';

class CollationOptionsPanel extends StatelessWidget {
  const CollationOptionsPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CollationBloc, CollationState>(
      builder: (context, state) {
        return Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: CheckboxListTile(
                    title: const Text('忽略标点'),
                    value: state.ignorePunctuation,
                    onChanged: (value) {
                      context.read<CollationBloc>().add(
                        ToggleIgnorePunctuationEvent(value ?? true),
                      );
                    },
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                  ),
                ),
                Expanded(
                  child: CheckboxListTile(
                    title: const Text('繁简兼容'),
                    value: state.ignoreTraditional,
                    onChanged: (value) {
                      context.read<CollationBloc>().add(
                        ToggleIgnoreTraditionalEvent(value ?? true),
                      );
                    },
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                  ),
                ),
              ],
            ),
            // OpenCC Status
            if (state.ignoreTraditional) _buildOpenCCStatus(context, state),
          ],
        );
      },
    );
  }

  Widget _buildOpenCCStatus(BuildContext context, CollationState state) {
    if (state.isOpenCCLoading) {
      return Padding(
        padding: const EdgeInsets.only(top: 4.0),
        child: Row(
          children: [
            const SizedBox(
              width: 12,
              height: 12,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            const SizedBox(width: 8),
            Text(
              '正在加载繁简转换引擎...',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.secondary,
              ),
            ),
          ],
        ),
      );
    }
    if (state.openCCError != null) {
      return Padding(
        padding: const EdgeInsets.only(top: 4.0),
        child: Text(
          'OpenCC 加载失败: ${state.openCCError}',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.error,
          ),
        ),
      );
    }
    return const SizedBox.shrink();
  }
}
