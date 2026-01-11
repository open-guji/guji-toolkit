import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:guji_toolkit/features/collation/widgets/common/collation_panel.dart';
import 'package:guji_toolkit/features/collation/widgets/input/highlighted_text_field.dart';

void main() {
  testWidgets('CollationPanel should have correct minimum height', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CollationPanel(
            child: HighlightedTextField(
              hint: 'test',
              controller: HighlightEditingController(),
              onChanged: (_) {},
            ),
          ),
        ),
      ),
    );

    final container = tester.widget<Container>(find.byType(Container).last);
    final constraints = container.constraints;
    expect(constraints?.minHeight, 150.0);

    tester.allWidgets.forEach(print);

    final textFieldFinder = find.byType(TextField);
    final textFieldRect = tester.getRect(textFieldFinder);
    print('TextField rect: $textFieldRect');

    final containerFinder = find.byType(Container).last;
    final containerRect = tester.getRect(containerFinder);
    print('Container rect: $containerRect');

    // Each line is 14 * 1.5 = 21px. 5 lines = 105px.
    // However, TextField might have some intrinsic padding even if contentPadding is zero.
    // Let's check if it's at least around 100px.
    expect(textFieldRect.height, greaterThanOrEqualTo(100.0));
  });
}
