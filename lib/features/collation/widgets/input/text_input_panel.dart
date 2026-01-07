import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guji_toolkit/features/collation/bloc/bloc.dart';
import 'highlighted_text_field.dart';

class TextInputPanel extends StatefulWidget {
  final bool isWide;
  const TextInputPanel({super.key, this.isWide = false});

  @override
  State<TextInputPanel> createState() => _TextInputPanelState();
}

class _TextInputPanelState extends State<TextInputPanel> {
  final HighlightEditingController _controller1 = HighlightEditingController();
  final HighlightEditingController _controller2 = HighlightEditingController();

  @override
  void initState() {
    super.initState();
    // 控制器内容将在 build 方法中同步
  }

  @override
  void dispose() {
    _controller1.dispose();
    _controller2.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CollationBloc, CollationState>(
      builder: (context, state) {
        // 同步 state 到控制器,但只在文本真正不同时更新,避免光标跳转
        if (_controller1.text != state.text1) {
          _controller1.value = _controller1.value.copyWith(
            text: state.text1,
            selection: TextSelection.collapsed(offset: state.text1.length),
          );
        }
        if (_controller2.text != state.text2) {
          _controller2.value = _controller2.value.copyWith(
            text: state.text2,
            selection: TextSelection.collapsed(offset: state.text2.length),
          );
        }

        // 检查是否有对比结果
        final hasResult =
            state.result != null && state.result!.text1View.isNotEmpty;

        // 更新控制器的显示状态
        _controller1.showHighlight = hasResult;
        _controller1.highlightSpans = hasResult
            ? HighlightedTextHelper.buildText1Spans(state.result!.text1View)
            : null;

        _controller2.showHighlight = hasResult;
        _controller2.highlightSpans = hasResult
            ? HighlightedTextHelper.buildText2Spans(state.result!.text2View)
            : null;

        final input1 = HighlightedTextField(
          label: '底本',
          hint: '请输入底本内容...',
          controller: _controller1,
          onChanged: (value) {
            context.read<CollationBloc>().add(UpdateText1Event(value));
          },
        );

        final input2 = HighlightedTextField(
          label: '校本',
          hint: '请输入校本内容（可对比多段文本）...',
          controller: _controller2,
          onChanged: (value) {
            context.read<CollationBloc>().add(UpdateText2Event(value));
          },
        );

        if (widget.isWide) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: input1),
              const SizedBox(width: 16),
              Expanded(child: input2),
            ],
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [input1, const SizedBox(height: 16), input2],
        );
      },
    );
  }
}
