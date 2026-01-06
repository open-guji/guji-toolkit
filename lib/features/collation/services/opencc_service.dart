import 'package:guji_diff/guji_diff.dart'; // wrapper for TextNormalizer which is in guji_diff?
// No, TextNormalizer is in guji_toolkit?
// In collation_bloc.dart it was calling TextNormalizer.ensureReady().
// Checks imports in collation_bloc.dart (Step 608):
// import 'package:guji_diff/guji_diff.dart';
// It assumes TextNormalizer is visible.
// If TextNormalizer is in guji_diff, then import is correct.

abstract class OpenCCService {
  Future<void> ensureReady();
}

class RealOpenCCService implements OpenCCService {
  @override
  Future<void> ensureReady() => TextNormalizer.ensureReady();
}
