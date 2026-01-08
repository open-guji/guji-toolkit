import 'package:flutter/material.dart';

class MergeProgressIndicator extends StatelessWidget {
  final int resolved;
  final int total;
  final bool allResolved;

  const MergeProgressIndicator({
    super.key,
    required this.resolved,
    required this.total,
    required this.allResolved,
  });

  @override
  Widget build(BuildContext context) {
    final color = allResolved ? Colors.green : Colors.orange;
    final icon = allResolved ? Icons.check_circle : Icons.warning_amber_rounded;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 4),
        Text(
          '已确认: $resolved / $total',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class MergePerfectMatchIndicator extends StatelessWidget {
  const MergePerfectMatchIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    const color = Colors.green;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.check_circle, color: color, size: 20),
        const SizedBox(width: 4),
        Text(
          '完全匹配',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
