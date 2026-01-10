import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:yaml/yaml.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String _version = '...';
  String _lastUpdated = '...';
  Map<String, String> _dependencies = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPubspec();
  }

  Future<void> _loadPubspec() async {
    try {
      final yamlString = await rootBundle.loadString('pubspec.yaml');
      final yamlMap = loadYaml(yamlString);

      if (mounted) {
        setState(() {
          _version = yamlMap['version']?.toString() ?? '未知';
          _lastUpdated = yamlMap['last_updated']?.toString() ?? '未知';
          final deps = yamlMap['dependencies'] as YamlMap?;
          if (deps != null) {
            _dependencies = Map.fromEntries(
              deps.entries.where((e) => e.key.toString() == 'guji_diff').map((
                e,
              ) {
                final key = e.key.toString();
                final value = e.value;
                // 处理复杂依赖 (如 path, git 等)
                if (value is YamlMap) {
                  if (value.containsKey('path')) {
                    return MapEntry(key, 'local: ${value['path']}');
                  } else if (value.containsKey('git')) {
                    return MapEntry(key, 'git');
                  }
                }
                return MapEntry(key, value.toString());
              }),
            );
          }
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading pubspec: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('设置'), centerTitle: false),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(24.0),
              children: [
                _buildSection(context, '关于', [
                  _buildInfoTile(context, '项目名称', '古籍助手 (Guji Toolkit)'),
                  _buildInfoTile(context, '当前版本', _version),
                  _buildInfoTile(context, '更新时间', _lastUpdated),
                ]),
                const SizedBox(height: 32),
                if (_dependencies.isNotEmpty)
                  _buildSection(context, '依赖项', [
                    ..._dependencies.entries.map(
                      (e) => _buildDependencyTile(context, e.key, e.value),
                    ),
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
