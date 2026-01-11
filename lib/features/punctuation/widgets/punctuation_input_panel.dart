import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../common/widgets/widgets.dart';
import '../bloc/bloc.dart';

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
    return BlocListener<PunctuationBloc, PunctuationState>(
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
      child: LayoutBuilder(
        builder: (context, constraints) {
          final inputOriginal = PanelContainer(
            title: '底本',
            isExpanded: widget.isWide,
            child: BorderlessTextField(
              controller: _originalController,
              hintText: '请输入底本内容...',
              minLines: 8,
              onChanged: (value) {
                context.read<PunctuationBloc>().add(
                  UpdateOriginalTextEvent(value),
                );
              },
            ),
          );

          final inputPunctuated = PanelContainer(
            title: '标点本',
            isExpanded: widget.isWide,
            child: BorderlessTextField(
              controller: _punctuatedController,
              hintText: '标点后的文本将显示在这里...',
              minLines: 8,
              readOnly: true,
            ),
          );

          if (widget.isWide) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: inputOriginal),
                const SizedBox(width: 24),
                Expanded(child: inputPunctuated),
              ],
            );
          } else {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                inputOriginal,
                const SizedBox(height: 20),
                inputPunctuated,
              ],
            );
          }
        },
      ),
    );
  }
}
