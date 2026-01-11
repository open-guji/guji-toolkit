import 'package:flutter/material.dart';

/// 统一的文本展示/输入面板外壳
/// 负责处理边框、内边距、标题展示以及高度约束
class CollationPanel extends StatelessWidget {
  final String? title;
  final Widget child;
  final BoxConstraints? constraints;
  final Color? backgroundColor;
  final bool isExpanded;

  const CollationPanel({
    super.key,
    this.title,
    required this.child,
    this.constraints,
    this.backgroundColor,
    this.isExpanded = false,
  });

  @override
  Widget build(BuildContext context) {
    // 默认约束：
    // - 每行约 14px * 1.5 (line-height) = 21px
    // - 5 行 = 105px，加上一些缓冲 = 140px
    final effectiveConstraints =
        constraints ??
        BoxConstraints(
          minHeight: isExpanded ? 300 : 140, // 非展开时至少 5 行高度
          maxHeight: 400,
        );

    final panel = Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color:
            backgroundColor ??
            Theme.of(context).colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).colorScheme.outlineVariant,
          width: 1,
        ),
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
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Text(
            title!,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
        panel,
      ],
    );
  }
}
