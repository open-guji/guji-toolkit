import 'package:flutter/material.dart';

/// 通用的样式化下拉选择器
/// 提供统一的边框、内边距和主题样式
class StyledDropdown<T> extends StatelessWidget {
  final T value;
  final List<T> items;
  final ValueChanged<T?>? onChanged;
  final String Function(T) itemLabel;
  final bool isDense;
  final bool isExpanded;

  const StyledDropdown({
    super.key,
    required this.value,
    required this.items,
    required this.onChanged,
    required this.itemLabel,
    this.isDense = true,
    this.isExpanded = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(4),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          onChanged: onChanged,
          isDense: isDense,
          isExpanded: isExpanded,
          style: Theme.of(context).textTheme.bodySmall,
          items: items.map((item) {
            return DropdownMenuItem<T>(
              value: item,
              child: Text(
                itemLabel(item),
                overflow: isExpanded ? TextOverflow.ellipsis : null,
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
