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

    // 8. Interaction: Click an option
    // Note: Clicking the text label or the Row containing it should work due to InkWell.
    await tester.tap(find.text('忽略标点'));
    await tester.pump();

    // 9. Interaction: Type text
    // Fixed selectors: searching for hint text or by order
    await tester.enterText(find.byType(TextField).at(0), '比如');
    await tester.enterText(find.byType(TextField).at(1), '譬如');
    await tester.pump();

    // 10. Interaction: Click Compare
    // Result display might appear if logic runs.
  });
}
