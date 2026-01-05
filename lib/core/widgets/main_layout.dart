import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MainLayout extends StatelessWidget {
  final Widget child;
  final String location;

  const MainLayout({super.key, required this.child, required this.location});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
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
                icon: Icon(Icons.edit_note_outlined),
                selectedIcon: Icon(Icons.edit_note),
                label: Text('编辑器'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.scanner_outlined),
                selectedIcon: Icon(Icons.scanner),
                label: Text('扫描'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.settings_outlined),
                selectedIcon: Icon(Icons.settings),
                label: Text('设置'),
              ),
            ],
          ),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(child: child),
        ],
      ),
    );
  }

  int _getSelectedIndex(String location) {
    if (location.startsWith('/editor')) return 1;
    if (location.startsWith('/scanner')) return 2;
    if (location.startsWith('/settings')) return 3;
    return 0;
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go('/');
        break;
      case 1:
        context.go('/editor');
        break;
      case 2:
        context.go('/scanner');
        break;
      case 3:
        context.go('/settings');
        break;
    }
  }
}
