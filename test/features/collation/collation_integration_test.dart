import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:guji_toolkit/features/collation/collation_page.dart';
import 'package:guji_toolkit/features/collation/widgets/widgets.dart';

void main() {
  testWidgets('Collation Page Integration Test', (tester) async {
    // 1. App setup - set larger screen size to trigger wide layout
    tester.view.physicalSize = const Size(1200, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(useMaterial3: true),
        home: const Scaffold(
          body: CollationPage(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // 2. Verify Title
    expect(find.text('文本对校'), findsOneWidget);

    // 3. Verify Settings Panel
    expect(find.text('设置'), findsOneWidget);
    expect(find.text('忽略标点'), findsOneWidget);
    expect(find.text('繁简兼容'), findsOneWidget);

    // 4. Verify Inputs and Examples Layout
    // Inputs at left, Examples at right (in wide layout > 800px)
    final inputsFinder = find.byType(TextInputPanel);
    final examplesFinder = find.byType(CollationExamplesPanel);
    expect(inputsFinder, findsOneWidget);
    expect(examplesFinder, findsOneWidget);

    final inputsRect = tester.getRect(inputsFinder);
    final examplesRect = tester.getRect(examplesFinder);

    // Examples should be to the right of Options (wide layout)
    expect(examplesRect.left > inputsRect.left, isTrue);

    // 5. Verify Examples Panel Content
    expect(find.text('示例'), findsOneWidget);
    // Verify example buttons are present
    expect(find.text('异体字差异'), findsOneWidget);
    expect(find.text('标点差异'), findsOneWidget);
    expect(find.text('繁简混合'), findsOneWidget);
    expect(find.text('多段对比'), findsOneWidget);

    // 6. Verify Action Button
    expect(find.text('开始对比'), findsOneWidget);

    // 7. Verify Inputs Labels
    expect(find.text('底本'), findsOneWidget);
    expect(find.text('校本'), findsOneWidget);

    // 8. Verify initial state - 繁简兼容 should be ON by default
    // We need to turn it OFF to avoid OpenCC FFI issues in tests
    final traditionalCheckbox = find.byKey(const Key('checkbox_ignore_traditional'));
    expect(traditionalCheckbox, findsOneWidget);

    // Get the initial state
    final Checkbox checkbox = tester.widget(traditionalCheckbox);
    if (checkbox.value == true) {
      // Turn off if it's on to avoid OpenCC FFI in tests
      await tester.tap(find.text('繁简兼容'));
      await tester.pump();
    }

    // 9. Interaction: Type text
    await tester.enterText(find.byType(TextField).at(0), '比如');
    await tester.enterText(find.byType(TextField).at(1), '譬如');
    await tester.pump();

    // 10. Interaction: Click Compare
    final compareButton = find.text('开始对比');
    expect(compareButton, findsOneWidget);
    await tester.tap(compareButton);
    await tester.pumpAndSettle();

    // 11. Verify Results Tabs
    expect(find.text('合并模式'), findsOneWidget);
    // Statistical analysis tab includes similarity percentage in label
    expect(find.textContaining('统计分析'), findsOneWidget);
  });
}
