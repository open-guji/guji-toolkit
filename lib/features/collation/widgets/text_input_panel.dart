import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guji_toolkit/features/collation/bloc/bloc.dart';

class TextInputPanel extends StatefulWidget {
  const TextInputPanel({super.key});

  @override
  State<TextInputPanel> createState() => _TextInputPanelState();
}

class _TextInputPanelState extends State<TextInputPanel> {
  final TextEditingController _controller1 = TextEditingController();
  final TextEditingController _controller2 = TextEditingController();

  @override
  void initState() {
    super.initState();
    // 初始化控制器内容
    final state = context.read<CollationBloc>().state;
    _controller1.text = state.text1;
    _controller2.text = state.text2;
  }

  @override
  void dispose() {
    _controller1.dispose();
    _controller2.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CollationBloc, CollationState>(
      listenWhen: (previous, current) =>
          previous.text1 != current.text1 || previous.text2 != current.text2,
      listener: (context, state) {
        if (_controller1.text != state.text1) {
          _controller1.text = state.text1;
        }
        if (_controller2.text != state.text2) {
          _controller2.text = state.text2;
        }
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 底本输入框
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '底本',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _controller1,
                maxLines: 8,
                minLines: 4,
                decoration: const InputDecoration(
                  hintText: '请输入底本内容...',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.all(12),
                ),
                onChanged: (value) {
                  context.read<CollationBloc>().add(UpdateText1Event(value));
                },
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 校本输入框
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '校本',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _controller2,
                maxLines: 8,
                minLines: 4,
                decoration: const InputDecoration(
                  hintText: '请输入校本内容（可对比多段文本）...',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.all(12),
                ),
                onChanged: (value) {
                  context.read<CollationBloc>().add(UpdateText2Event(value));
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
