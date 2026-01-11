import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/bloc.dart';
import '../models/punctuation_example.dart';

class PunctuationExamplesPanel extends StatefulWidget {
  const PunctuationExamplesPanel({super.key});

  @override
  State<PunctuationExamplesPanel> createState() =>
      _PunctuationExamplesPanelState();
}

class _PunctuationExamplesPanelState extends State<PunctuationExamplesPanel> {
  bool _isExpanded = true;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 32,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          IconButton(
            onPressed: () => setState(() => _isExpanded = !_isExpanded),
            icon: Icon(
              _isExpanded ? Icons.chevron_right : Icons.chevron_left,
              size: 20,
            ),
            tooltip: _isExpanded ? '收起示例' : '展开示例',
            visualDensity: VisualDensity.compact,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          if (_isExpanded)
            Flexible(
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                shrinkWrap: true,
                itemCount: PunctuationExamples.examples.length,
                itemBuilder: (context, index) {
                  final example = PunctuationExamples.examples[index];
                  return Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: _ExampleButton(example: example),
                  );
                },
              ),
            ),
          const SizedBox(width: 8),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => setState(() => _isExpanded = !_isExpanded),
              borderRadius: BorderRadius.circular(4),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.lightbulb_outline,
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
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ExampleButton extends StatelessWidget {
  final PunctuationExample example;

  const _ExampleButton({required this.example});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            context.read<PunctuationBloc>().add(
              LoadPunctuationExampleEvent(originalText: example.originalText),
            );
          },
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              border: Border.all(
                color: Theme.of(context).colorScheme.outlineVariant,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              example.name,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
              ),
              maxLines: 1,
            ),
          ),
        ),
      ),
    );
  }
}
