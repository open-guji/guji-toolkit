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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title and Options in one row
            Row(
              children: [
                // Title
                Icon(
                  Icons.settings,
                  size: 18,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  '设置',
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 24),
                // Options
                _OptionCheckbox(
                  label: '忽略标点',
                  value: state.ignorePunctuation,
                  checkboxKey: const Key('checkbox_ignore_punctuation'),
                  disabled: state.isComparing,
                  onChanged: (value) {
                    context.read<CollationBloc>().add(
                      ToggleIgnorePunctuationEvent(value ?? true),
                    );
                  },
                ),
                const SizedBox(width: 16),
                _OptionCheckbox(
                  label: '繁简兼容',
                  value: state.ignoreTraditional,
                  checkboxKey: const Key('checkbox_ignore_traditional'),
                  disabled: state.isComparing,
                  onChanged: (value) {
                    context.read<CollationBloc>().add(
                      ToggleIgnoreTraditionalEvent(value ?? true),
                    );
                  },
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

class _OptionCheckbox extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool?> onChanged;
  final Key? checkboxKey;
  final bool disabled;

  const _OptionCheckbox({
    required this.label,
    required this.value,
    required this.onChanged,
    this.checkboxKey,
    this.disabled = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onChanged(!value),
      borderRadius: BorderRadius.circular(4),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 24,
              height: 24,
              child: Checkbox(
                key: checkboxKey,
                value: value,
                onChanged: disabled ? null : onChanged,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: disabled ? Theme.of(context).disabledColor : null,
              ),
            ),
            const SizedBox(width: 8), // slightly more touch area
          ],
        ),
      ),
    );
  }
}
