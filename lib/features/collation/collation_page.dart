import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guji_toolkit/features/collation/bloc/bloc.dart';
import 'package:guji_toolkit/features/collation/widgets/widgets.dart';

/// 古籍对校页面
///
/// 提供两段文本的逐字比对功能，支持：
/// - 忽略标点符号
/// - 繁简兼容（使用 OpenCC）
/// - 相似度计算
class CollationPage extends StatelessWidget {
  const CollationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CollationBloc(),
      child: const _CollationPageContent(),
    );
  }
}

class _CollationPageContent extends StatelessWidget {
  const _CollationPageContent();

  @override
  Widget build(BuildContext context) {
    return const SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _PageHeader(),
            SizedBox(height: 24),
            _SettingsSection(),
            SizedBox(height: 16),
            _InputSection(),
            SizedBox(height: 12),
            CollationActionButton(),
            SizedBox(height: 16),
            ResultDisplayPanel(),
            SizedBox(height: 48),
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
          '文本对校',
          style: Theme.of(
            context,
          ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(width: 12),
        Text(
          '比较两段文本，高亮不同之处，手动校对',
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
              Expanded(flex: 2, child: CollationOptionsPanel()),
              SizedBox(width: 32),
              Expanded(flex: 3, child: CollationExamplesPanel()),
            ],
          );
        }
        return const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CollationOptionsPanel(),
            SizedBox(height: 12),
            CollationExamplesPanel(),
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
        return TextInputPanel(isWide: isWide);
      },
    );
  }
}
