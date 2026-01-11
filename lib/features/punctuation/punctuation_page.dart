import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'bloc/bloc.dart';
import 'widgets/widgets.dart';

class PunctuationPage extends StatelessWidget {
  const PunctuationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => PunctuationBloc(),
      child: const _PunctuationPageContent(),
    );
  }
}

class _PunctuationPageContent extends StatelessWidget {
  const _PunctuationPageContent();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const _PageHeader(),
            const SizedBox(height: 24),
            const _SettingsSection(),
            const SizedBox(height: 16),
            const _InputSection(),
            const SizedBox(height: 12),
            const PunctuationActionButton(),
            const SizedBox(height: 48),
          ],
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

class _SettingsSection extends StatelessWidget {
  const _SettingsSection();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 800;
        if (isWide) {
          return const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 2, child: PunctuationOptionsPanel()),
              SizedBox(width: 32),
              Expanded(flex: 3, child: PunctuationExamplesPanel()),
            ],
          );
        }
        return const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PunctuationOptionsPanel(),
            SizedBox(height: 12),
            PunctuationExamplesPanel(),
          ],
        );
      },
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
