import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MainLayout extends StatelessWidget {
  final Widget child;
  final String location;

  const MainLayout({super.key, required this.child, required this.location});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SelectionArea(
        child: Row(
          children: [
            NavigationRail(
              selectedIndex: _getSelectedIndex(location),
              onDestinationSelected: (index) => _onItemTapped(index, context),
              labelType: NavigationRailLabelType.all,
              destinations: const [
                NavigationRailDestination(
                  icon: Icon(Icons.home_outlined),
                  selectedIcon: Icon(Icons.home),
                  label: Text('首页'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.compare_arrows_outlined),
                  selectedIcon: Icon(Icons.compare_arrows),
                  label: Text('文本对校'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.edit_note_outlined),
                  selectedIcon: Icon(Icons.edit_note),
                  label: Text('编辑器'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.scanner_outlined),
                  selectedIcon: Icon(Icons.scanner),
                  label: Text('扫描'),
                ),
              ],
              trailing: Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      onPressed: () => context.go('/settings'),
                      icon: Icon(
                        location.startsWith('/settings')
                            ? Icons.settings
                            : Icons.settings_outlined,
                      ),
                      color: location.startsWith('/settings')
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '设置',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: location.startsWith('/settings')
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
            const VerticalDivider(thickness: 1, width: 1),
            Expanded(child: child),
          ],
        ),
      ),
    );
  }

  int? _getSelectedIndex(String location) {
    if (location == '/') return 0;
    if (location.startsWith('/collation')) return 1;
    if (location.startsWith('/editor')) return 2;
    if (location.startsWith('/scanner')) return 3;
    return null;
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go('/');
        break;
      case 1:
        context.go('/collation');
        break;
      case 2:
        context.go('/editor');
        break;
      case 3:
        context.go('/scanner');
        break;
    }
  }
}
