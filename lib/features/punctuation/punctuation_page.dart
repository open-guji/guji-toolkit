import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'bloc/bloc.dart';
import 'models/punctuation_config.dart';
import 'engine/transformers_js_engine.dart';
import 'widgets/widgets.dart';

class PunctuationPage extends StatelessWidget {
  const PunctuationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          PunctuationBloc(engine: TransformersJsEngine())
            ..add(const PunctuationStarted()),
      child: _PunctuationPageContent(),
    );
  }
}

class _PunctuationPageContent extends StatelessWidget {
  const _PunctuationPageContent();

  @override
  Widget build(BuildContext context) {
    return BlocListener<PunctuationBloc, PunctuationState>(
      listenWhen: (previous, current) =>
          current.error != null && previous.error != current.error,
      listener: (context, state) {
        if (state.error != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.error!),
              backgroundColor: Theme.of(context).colorScheme.error,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const _PageHeader(),
              const SizedBox(height: 32),
              // 配置区域 - 两栏布局
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.tune,
                        size: 18,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '配置选项',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 左侧：标点方式和模型选择
                      const Expanded(flex: 3, child: PunctuationOptionsPanel()),
                      const SizedBox(width: 24),
                      // 右侧：模型安装详情（仅在专用模型模式下）
                      Expanded(
                        flex: 2,
                        child: BlocBuilder<PunctuationBloc, PunctuationState>(
                          buildWhen: (previous, current) =>
                              previous.selectedMethod != current.selectedMethod,
                          builder: (context, state) {
                            if (state.selectedMethod ==
                                PunctuationMethod.specialized) {
                              return const PunctuationModelStatus();
                            }
                            return const SizedBox.shrink();
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 32),
              const _InputSection(),
              const SizedBox(height: 40),
              const PunctuationActionButton(),
              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }
}

class _PageHeader extends StatelessWidget {
  const _PageHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Text(
          '断句标点',
          style: Theme.of(
            context,
          ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(width: 12),
        Text(
          '为古籍文本进行自动标点，支持多种模型选择',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _InputSection extends StatelessWidget {
  const _InputSection();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 700;
        return PunctuationInputPanel(isWide: isWide);
      },
    );
  }
}
