import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guji_toolkit/features/collation/bloc/bloc.dart';

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
                  children: [
                    _ExampleButton(
                      label: '简单短句',
                      text1: '学而时习之，不亦说乎？',
                      text2: '学而时习之，不亦悦乎？',
                    ),
                    const SizedBox(width: 8),
                    _ExampleButton(
                      label: '繁简异体',
                      text1: '國之大事，在祀與戎。',
                      text2: '国之大事，在祀与戎。',
                    ),
                    const SizedBox(width: 8),
                    _ExampleButton(
                      label: '长段落示例',
                      text1:
                          '夫英雄者，胸怀大志，腹有良谋，有包藏宇宙之机，吞吐天地之志者也。操曰：「君言是也。操之志，亦非碌碌之辈也。」',
                      text2:
                          '夫英雄者，胸怀大志，腹有良谋，有包藏宇宙之机，吞吐天地之志者也。公曰：「君言是也。操之志，亦非碌碌之辈也。」',
                    ),
                    const SizedBox(width: 8),
                    _ExampleButton(
                      label: '较多差异',
                      text1:
                          '晋太元中，武陵人捕鱼为业。缘溪行，忘路之远近。忽逢桃花林，夹岸数百步，中无杂树，芳草鲜美，落英缤纷。',
                      text2: '晋太元中，武陵人以为业。沿溪行，忘路之远。忽逢桃林，夹岸数百步，中无杂树，芳草鲜美，落英缤纷。',
                    ),
                  ],
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
