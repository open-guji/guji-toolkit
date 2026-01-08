import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('设置'), centerTitle: false),
      body: ListView(
        padding: const EdgeInsets.all(24.0),
        children: [
          _buildSection(context, '关于', [
            _buildInfoTile(context, '项目名称', '古籍助手 (Guji Toolkit)'),
            _buildInfoTile(context, '当前版本', '0.1.0'),
          ]),
          const SizedBox(height: 32),
          _buildSection(context, '依赖项', [
            _buildDependencyTile(context, 'guji_diff', '0.1.2'),
          ]),
        ],
      ),
    );
  }

  Widget _buildSection(
    BuildContext context,
    String title,
    List<Widget> children,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            side: BorderSide(
              color: Theme.of(context).colorScheme.outlineVariant,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildInfoTile(BuildContext context, String label, String value) {
    return ListTile(
      title: Text(label),
      trailing: Text(
        value,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildDependencyTile(
    BuildContext context,
    String name,
    String version,
  ) {
    return ListTile(
      dense: true,
      title: Text(name),
      trailing: Text(
        version,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: Theme.of(context).colorScheme.secondary,
          fontFamily: 'monospace',
        ),
      ),
    );
  }
}
