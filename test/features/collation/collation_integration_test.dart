import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:guji_toolkit/features/collation/collation_page.dart';
import 'package:guji_toolkit/features/collation/widgets/widgets.dart';

void main() {
  testWidgets('Collation Page Integration Test', (tester) async {
    // 1. App setup
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(useMaterial3: true),
        home: const CollationPage(),
      ),
    );
    await tester.pumpAndSettle();

    // 2. Verify Title
    expect(find.text('古籍对校'), findsOneWidget);

    // 3. Verify Settings Panel
    expect(find.text('设置'), findsOneWidget);
    expect(find.text('忽略标点'), findsOneWidget);
    expect(find.text('繁简兼容'), findsOneWidget);
    expect(find.text('异体字兼容'), findsOneWidget);

    // 4. Verify Inputs and Examples Layout
    // Inputs at left, Examples at right
    final inputsFinder = find.byType(TextInputPanel);
    final examplesFinder = find.byType(CollationExamplesPanel);
    expect(inputsFinder, findsOneWidget);
    expect(examplesFinder, findsOneWidget);

    final inputsRect = tester.getRect(inputsFinder);
    final examplesRect = tester.getRect(examplesFinder);

    // Inputs should be to the left of Examples
    expect(inputsRect.right < examplesRect.left, isTrue);

    // 5. Verify Examples Panel Content
    // Should be vertical in this test context if we use the layout logic
    expect(find.text('示例'), findsOneWidget);
    expect(find.byType(ActionChip), findsWidgets);

    // 6. Verify Action Button
    expect(find.text('开始对比'), findsOneWidget);

    // 7. Verify Inputs Labels
    expect(find.text('底本'), findsOneWidget);
    expect(find.text('校本'), findsOneWidget);

    // 8. Interaction: Click options
    await tester.tap(find.text('繁简兼容')); // Toggle off FFI-dependent option
    await tester.tap(find.text('异体字兼容')); // Toggle off FFI-dependent option
    await tester.pump();

    // 9. Interaction: Type text
    await tester.enterText(find.byType(TextField).at(0), '比如');
    await tester.enterText(find.byType(TextField).at(1), '譬如');
    await tester.pump();

    // 9.5 Wait for OpenCC to be ready (it might be loading)
    // The loading text is "正在加载繁简转换引擎..."
    int retry = 0;
    while (find.text('正在加载繁简转换引擎...').evaluate().isNotEmpty && retry < 10) {
      await tester.pump(const Duration(milliseconds: 100));
      retry++;
    }

    // 10. Interaction: Click Compare
    final compareButton = find.text('开始对比');
    expect(compareButton, findsOneWidget);
    await tester.tap(compareButton);
    await tester.pumpAndSettle();

    // 11. Verify Results Tabs
    if (find.text('文字对比').evaluate().isEmpty) {
      // Check if there is an error message
      final errorFinder = find.byType(
        Container,
      ); // The error container use BoxDecoration with error color
      // Or just look for any text that isn't expected
      print('Result tabs not found. Screen content:');
      for (final widget in tester.allWidgets) {
        if (widget is Text) {
          print('Text: ${widget.data}');
        }
      }
    }

    expect(find.text('文字对比'), findsOneWidget);
    expect(find.text('统计分析'), findsOneWidget);
  });
}
