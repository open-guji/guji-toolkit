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
    return SelectionContainer.disabled(
      child: SizedBox(
        height: 32,
        child: Align(
          alignment: Alignment.bottomCenter,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end, // 靠右对齐
            crossAxisAlignment: CrossAxisAlignment.end, // 底部对齐
            children: [
            if (_isExpanded)
              Flexible(
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  shrinkWrap: true,
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  itemCount: PunctuationExamples.examples.length,
                  itemBuilder: (context, index) {
                    final example = PunctuationExamples.examples[index];
                    return Padding(
                      padding: const EdgeInsets.only(left: 6.0),
                      child: _ExampleButton(example: example),
                    );
                  },
                ),
              ),
            const SizedBox(width: 4),
            IconButton(
              onPressed: () => setState(() => _isExpanded = !_isExpanded),
              icon: Icon(
                _isExpanded ? Icons.chevron_right : Icons.chevron_left, // 反转方向
                size: 18,
                color: Theme.of(
                  context,
                ).colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
              ),
              tooltip: _isExpanded ? '收起示例' : '展开示例',
              visualDensity: VisualDensity.compact,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => setState(() => _isExpanded = !_isExpanded),
                borderRadius: BorderRadius.circular(4),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 4,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '示例',
                        style: Theme.of(context).textTheme.labelMedium
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurfaceVariant,
                            ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.lightbulb_outline,
                        size: 14,
                        color: Theme.of(
                          context,
                        ).colorScheme.primary.withValues(alpha: 0.8),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
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
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
            decoration: BoxDecoration(
              color: Theme.of(
                context,
              ).colorScheme.surfaceContainerHigh.withValues(alpha: 0.5),
              border: Border.all(
                color: Theme.of(
                  context,
                ).colorScheme.outlineVariant.withValues(alpha: 0.5),
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              example.name,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                fontSize: 10,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              maxLines: 1,
            ),
          ),
        ),
      ),
    );
  }
}
