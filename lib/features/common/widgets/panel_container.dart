import 'package:flutter/material.dart';

/// 统一的文本展示/输入面板外壳
/// 负责处理边框、内边距、标题展示以及高度约束
class PanelContainer extends StatelessWidget {
  final String? title;
  final Widget? titleTrailing;
  final Widget child;
  final BoxConstraints? constraints;
  final Color? backgroundColor;
  final bool isExpanded;
  final bool hasShadow;

  const PanelContainer({
    super.key,
    this.title,
    this.titleTrailing,
    required this.child,
    this.constraints,
    this.backgroundColor,
    this.isExpanded = false,
    this.hasShadow = false,
  });

  @override
  Widget build(BuildContext context) {
    // TextField 的 minLines 控制最小高度，这里只需要限制最大高度
    final effectiveConstraints =
        constraints ?? const BoxConstraints(maxHeight: 500);

    final panel = Container(
      width: double.infinity,
      padding: const EdgeInsets.only(left: 12, top: 12, bottom: 12, right: 0),
      decoration: BoxDecoration(
        color:
            backgroundColor ??
            Theme.of(context).colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).colorScheme.outlineVariant,
          width: 1,
        ),
        boxShadow: hasShadow
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: ConstrainedBox(constraints: effectiveConstraints, child: child),
    );

    if (title == null) {
      return panel;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0, right: 4.0),
          child: Row(
            children: [
              Text(
                title!,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              if (titleTrailing != null) ...[
                const SizedBox(width: 12),
                Expanded(child: titleTrailing!),
              ],
            ],
          ),
        ),
        panel,
      ],
    );
  }
}
