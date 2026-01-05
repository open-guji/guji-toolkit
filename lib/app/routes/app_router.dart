import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:guji_toolkit/core/widgets/main_layout.dart';
import 'package:guji_toolkit/features/common/placeholders.dart';
import 'package:guji_toolkit/features/home/home_page.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      ShellRoute(
        builder: (context, state, child) {
          return MainLayout(location: state.uri.path, child: child);
        },
        routes: [
          GoRoute(path: '/', builder: (context, state) => const HomePage()),
          GoRoute(
            path: '/editor',
            builder: (context, state) => const EditorPage(),
          ),
          GoRoute(
            path: '/scanner',
            builder: (context, state) => const ScannerPage(),
          ),
          GoRoute(
            path: '/settings',
            builder: (context, state) => const SettingsPage(),
          ),
        ],
      ),
    ],
  );
});
