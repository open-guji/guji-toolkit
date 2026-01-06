import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guji_toolkit/features/collation/bloc/bloc.dart';

class TextInputPanelBloc extends StatefulWidget {
  const TextInputPanelBloc({super.key});

  @override
  State<TextInputPanelBloc> createState() => _TextInputPanelBlocState();
}

class _TextInputPanelBlocState extends State<TextInputPanelBloc> {
  final TextEditingController _controller1 = TextEditingController();
  final TextEditingController _controller2 = TextEditingController();

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
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '文本输入',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: Row(
                  children: [
                    // 文本1输入框
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '文本 1',
                            style: Theme.of(context).textTheme.labelLarge,
                          ),
                          const SizedBox(height: 8),
                          Expanded(
                            child: TextField(
                              controller: _controller1,
                              maxLines: null,
                              expands: true,
                              decoration: const InputDecoration(
                                hintText: '请输入第一段古籍文本...',
                                border: OutlineInputBorder(),
                              ),
                              onChanged: (value) {
                                context.read<CollationBloc>().add(
                                  UpdateText1Event(value),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    // 文本2输入框
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '文本 2',
                            style: Theme.of(context).textTheme.labelLarge,
                          ),
                          const SizedBox(height: 8),
                          Expanded(
                            child: TextField(
                              controller: _controller2,
                              maxLines: null,
                              expands: true,
                              decoration: const InputDecoration(
                                hintText: '请输入第二段古籍文本...',
                                border: OutlineInputBorder(),
                              ),
                              onChanged: (value) {
                                context.read<CollationBloc>().add(
                                  UpdateText2Event(value),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
