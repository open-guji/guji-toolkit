import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../common/widgets/widgets.dart';
import '../bloc/bloc.dart';
import 'punctuation_examples_panel.dart';

class PunctuationInputPanel extends StatefulWidget {
  final bool isWide;
  const PunctuationInputPanel({super.key, this.isWide = false});

  @override
  State<PunctuationInputPanel> createState() => _PunctuationInputPanelState();
}

class _PunctuationInputPanelState extends State<PunctuationInputPanel> {
  final TextEditingController _originalController = TextEditingController();
  final TextEditingController _punctuatedController = TextEditingController();

  @override
  void dispose() {
    _originalController.dispose();
    _punctuatedController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PunctuationBloc, PunctuationState>(
      listenWhen: (previous, current) =>
          previous.originalText != current.originalText ||
          previous.punctuatedText != current.punctuatedText,
      listener: (context, state) {
        if (_originalController.text != state.originalText) {
          _originalController.text = state.originalText;
        }
        if (_punctuatedController.text != state.punctuatedText) {
          _punctuatedController.text = state.punctuatedText;
        }
      },
      builder: (context, state) {
        return LayoutBuilder(
          builder: (context, constraints) {
            // 统一底色：比页面底色稍微淡一点
            // 页面底色是 0xFFF5F2E9
            final panelColor = Color.lerp(
              const Color(0xFFF5F2E9),
              Colors.white,
              0.4,
            );

            final inputOriginal = PanelContainer(
              title: '底本',
              titleTrailing: const PunctuationExamplesPanel(),
              backgroundColor: panelColor,
              isExpanded: widget.isWide,
              child: BorderlessTextField(
                controller: _originalController,
                hintText: '请输入底本内容...',
                minLines: 12,
                onChanged: (value) {
                  context.read<PunctuationBloc>().add(
                    UpdateOriginalTextEvent(value),
                  );
                },
              ),
            );

            final inputPunctuated = PanelContainer(
              title: '标点本',
              titleTrailing: const SizedBox(height: 32), // 占位以对齐左侧"示例"栏高度
              backgroundColor: panelColor,
              isExpanded: widget.isWide,
              footer: state.punctuatedText.isNotEmpty
                  ? CopyDownloadActions(
                      text: state.punctuatedText,
                      fileNamePrefix: 'punctuation_result',
                    )
                  : null,
              child: BorderlessTextField(
                controller: _punctuatedController,
                hintText: '标点后的文本将显示在这里...',
                minLines: 12,
                readOnly: true,
              ),
            );

            if (widget.isWide) {
              return IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch, // 完全对齐
                  children: [
                    Expanded(child: inputOriginal),
                    const SizedBox(width: 24),
                    Expanded(child: inputPunctuated),
                  ],
                ),
              );
            } else {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  inputOriginal,
                  const SizedBox(height: 24),
                  inputPunctuated,
                ],
              );
            }
          },
        );
      },
    );
  }
}
