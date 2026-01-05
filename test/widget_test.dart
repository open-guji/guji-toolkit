import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:guji_toolkit/app/app.dart';

void main() {
  testWidgets('Full app smoke test', (WidgetTester tester) async {
    // Set a consistent surface size for web testing.
    await tester.binding.setSurfaceSize(const Size(1200, 800));

    // Build the app.
    await tester.pumpWidget(const ProviderScope(child: GujiApp()));

    // Wait for the initial shell navigation.
    await tester.pumpAndSettle();

    // Verify core structure.
    expect(find.byType(NavigationRail), findsOneWidget);
    expect(find.text('欢迎使用古籍工具箱'), findsOneWidget);
  });
}
