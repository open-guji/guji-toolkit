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
  final ScrollController _scrollController1 = ScrollController();
  final ScrollController _scrollController2 = ScrollController();

  bool _isSyncing = false;

  @override
  void initState() {
    super.initState();
    _scrollController1.addListener(_syncScroll1);
    _scrollController2.addListener(_syncScroll2);
  }

  void _syncScroll1() {
    if (_isSyncing) return;
    _isSyncing = true;
    if (_scrollController2.hasClients) {
      _scrollController2.jumpTo(_scrollController1.offset);
    }
    _isSyncing = false;
  }

  void _syncScroll2() {
    if (_isSyncing) return;
    _isSyncing = true;
    if (_scrollController1.hasClients) {
      _scrollController1.jumpTo(_scrollController2.offset);
    }
    _isSyncing = false;
  }

  @override
  void dispose() {
    _controller1.dispose();
    _controller2.dispose();
    _scrollController1.dispose();
    _scrollController2.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CollationBloc, CollationState>(
      builder: (context, state) {
        // 同步文本到控制器（仅当不同时）
        if (_controller1.text != state.text1) {
          _controller1.value = TextEditingValue(
            text: state.text1,
            selection: TextSelection.collapsed(offset: state.text1.length),
          );
        }
        if (_controller2.text != state.text2) {
          _controller2.value = TextEditingValue(
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
          scrollController: _scrollController1,
          isExpanded: false,
          onChanged: (value) {
            context.read<CollationBloc>().add(UpdateText1Event(value));
          },
        );

        final input2 = HighlightedTextField(
          label: '校本',
          hint: '请输入校本内容（可对比多段文本）...',
          controller: _controller2,
          scrollController: _scrollController2,
          isExpanded: false,
          onChanged: (value) {
            context.read<CollationBloc>().add(UpdateText2Event(value));
          },
        );

        Widget content;
        if (widget.isWide) {
          content = IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(child: input1),
                const SizedBox(width: 16),
                Expanded(child: input2),
              ],
            ),
          );
        } else {
          content = Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [input1, const SizedBox(height: 16), input2],
          );
        }

        return content;
      },
    );
  }
}
