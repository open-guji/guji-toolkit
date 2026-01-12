import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:guji_toolkit/core/utils/link_launcher.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 800),
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '欢迎使用古籍助手',
                style: Theme.of(context).textTheme.displayMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                '古籍数字化与校勘的一站式工具箱。',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(
                    '本工具是',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  InkWell(
                    onTap: () =>
                        LinkLauncher.launch('https://www.kaiyuanguji.com/'),
                    child: Text(
                      '开源古籍',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Text(
                    '计划的一部分，欢迎点击访问官网以了解该计划的更多精彩内容。',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 48),
              Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  _ActionCard(
                    title: '文本对校',
                    description: '比较两段文本，输出差异分析。',
                    icon: Icons.compare_arrows,
                    onTap: () => context.go('/collation'),
                  ),
                  _ActionCard(
                    title: '断句标点',
                    description: '自动为古籍文本断句和添加标点。',
                    icon: Icons.format_quote,
                    onTap: () => context.go('/punctuation'),
                  ),
                  _ActionCard(
                    title: '开始编辑',
                    description: '直接修改和校勘文本。',
                    icon: Icons.edit,
                    onTap: () => context.go('/editor'),
                    isComingSoon: true,
                  ),
                  _ActionCard(
                    title: '导入扫描件',
                    description: '上传图片进行 OCR 识别和处理。',
                    icon: Icons.upload_file,
                    onTap: () => context.go('/scanner'),
                    isComingSoon: true,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final VoidCallback onTap;
  final bool isComingSoon;

  const _ActionCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.onTap,
    this.isComingSoon = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: isComingSoon ? 0 : 2,
      color: isComingSoon
          ? Theme.of(context).colorScheme.surfaceContainerHighest.withAlpha(128)
          : null,
      child: InkWell(
        onTap: isComingSoon ? null : onTap,
        child: Container(
          width: 300,
          padding: const EdgeInsets.all(24),
          child: Opacity(
            opacity: isComingSoon ? 0.6 : 1.0,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Icon(
                      icon,
                      size: 40,
                      color: isComingSoon
                          ? Theme.of(context).colorScheme.outline
                          : Theme.of(context).colorScheme.primary,
                    ),
                    if (isComingSoon)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.outlineVariant,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '敬请期待',
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  title,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
