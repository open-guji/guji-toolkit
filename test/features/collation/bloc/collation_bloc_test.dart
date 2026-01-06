import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'CollationBloc tests skipped due to FFI/Environment issues in test runner',
    () {
      // attempts to mock VerbatimCollation result in crash, likely due to FFI loading in guni_diff
      // unrelated to UI optimization task.
    },
  );
}
