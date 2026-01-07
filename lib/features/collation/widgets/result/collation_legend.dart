import 'package:flutter/material.dart';

class CollationLegend extends StatelessWidget {
  const CollationLegend({super.key});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 16,
      children: [
        _LegendItem(color: Colors.red.shade100, label: '删除'),
        _LegendItem(color: Colors.green.shade100, label: '添加'),
        _LegendItem(color: Colors.yellow.shade200, label: '已确认'),
      ],
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendItem({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
            border: Border.all(color: Colors.grey.shade400),
          ),
        ),
        const SizedBox(width: 4),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}
