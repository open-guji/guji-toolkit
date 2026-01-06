import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guji_toolkit/features/collation/bloc/bloc.dart';
import 'package:guji_toolkit/features/collation/models/collation_example.dart';

class CollationExamplesPanel extends StatelessWidget {
  const CollationExamplesPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.lightbulb_outline,
              size: 18,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 8),
            Text(
              '示例：',
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: CollationExamples.examples.map((example) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: _ExampleButton(
                        label: example.name.split('：').last,
                        text1: example.text1,
                        text2: example.text2,
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ExampleButton extends StatelessWidget {
  final String label;
  final String text1;
  final String text2;

  const _ExampleButton({
    required this.label,
    required this.text1,
    required this.text2,
  });

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      label: Text(label),
      onPressed: () {
        context.read<CollationBloc>().add(
          LoadExampleEvent(text1: text1, text2: text2),
        );
      },
    );
  }
}
