import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../collation/widgets/common/collation_panel.dart';
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
          final inputOriginal = CollationPanel(
            title: '底本',
            isExpanded: widget.isWide,
            child: TextField(
              controller: _originalController,
              maxLines: null,
              minLines: 5,
              textAlignVertical: TextAlignVertical.top,
              decoration: const InputDecoration(
                hintText: '请输入底本内容...',
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                errorBorder: InputBorder.none,
                disabledBorder: InputBorder.none,
                contentPadding: EdgeInsets.only(right: 12),
                filled: false,
              ),
              style: const TextStyle(fontSize: 14, height: 1.5),

              onChanged: (value) {
                context.read<PunctuationBloc>().add(
                  UpdateOriginalTextEvent(value),
                );
              },
            ),
          );

          final inputPunctuated = CollationPanel(
            title: '标点本',
            isExpanded: widget.isWide,
            child: TextField(
              controller: _punctuatedController,
              maxLines: null,
              minLines: 5,
              readOnly: true, // Output field
              textAlignVertical: TextAlignVertical.top,
              decoration: const InputDecoration(
                hintText: '标点后的文本将显示在这里...',
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                errorBorder: InputBorder.none,
                disabledBorder: InputBorder.none,
                contentPadding: EdgeInsets.only(right: 12),
                filled: false,
              ),
              style: const TextStyle(fontSize: 14, height: 1.5),
            ),
          );

          if (widget.isWide) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: inputOriginal),
                const SizedBox(width: 16),
                Expanded(child: inputPunctuated),
              ],
            );
          } else {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                inputOriginal,
                const SizedBox(height: 16),
                inputPunctuated,
              ],
            );
          }
        },
      ),
    );
  }
}
