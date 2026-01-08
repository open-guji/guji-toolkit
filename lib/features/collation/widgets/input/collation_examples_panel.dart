import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guji_toolkit/features/collation/bloc/bloc.dart';
import 'package:guji_toolkit/features/collation/models/collation_example.dart';

class CollationExamplesPanel extends StatefulWidget {
  final bool isVertical;

  const CollationExamplesPanel({super.key, this.isVertical = false});

  @override
  State<CollationExamplesPanel> createState() => _CollationExamplesPanelState();
}

class _CollationExamplesPanelState extends State<CollationExamplesPanel> {
  bool _isExpanded = true;

  @override
  Widget build(BuildContext context) {
    if (widget.isVertical) {
      return Align(
        alignment: Alignment.topRight,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            InkWell(
              onTap: () => setState(() => _isExpanded = !_isExpanded),
              borderRadius: BorderRadius.circular(4),
              child: Padding(
                padding: const EdgeInsets.all(2.0),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _isExpanded ? Icons.expand_less : Icons.expand_more,
                      size: 16,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '示例',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 2),
                    Icon(
                      Icons.lightbulb_outline,
                      size: 16,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ],
                ),
              ),
            ),
            if (_isExpanded)
              Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: CollationExamples.examples.map((example) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 4.0),
                      child: _ExampleButton(
                        label: example.name.split('：').last,
                        text1: example.text1,
                        text2: example.text2,
                      ),
                    );
                  }).toList(),
                ),
              ),
          ],
        ),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          height: 32,
          child: IconButton(
            onPressed: () => setState(() => _isExpanded = !_isExpanded),
            icon: Icon(
              _isExpanded ? Icons.chevron_right : Icons.chevron_left,
              size: 20,
            ),
            tooltip: _isExpanded ? '收起示例' : '展开示例',
            visualDensity: VisualDensity.compact,
            padding: const EdgeInsets.all(4),
            constraints: const BoxConstraints(),
          ),
        ),
        if (_isExpanded)
          Flexible(
            child: SizedBox(
              height: 32,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                reverse: true,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: CollationExamples.examples.map((example) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 4.0),
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
          ),
        SizedBox(
          height: 32,
          child: InkWell(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            borderRadius: BorderRadius.circular(4),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '示例',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.lightbulb_outline,
                    size: 16,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ],
              ),
            ),
          ),
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
      label: Text(label, maxLines: 1, overflow: TextOverflow.visible),
      onPressed: () {
        context.read<CollationBloc>().add(
          LoadExampleEvent(text1: text1, text2: text2),
        );
      },
      visualDensity: VisualDensity.compact,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
      labelPadding: EdgeInsets.zero,
    );
  }
}
