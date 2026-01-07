import 'package:flutter_test/flutter_test.dart';
import 'package:guji_diff/guji_diff.dart';
import 'package:guji_toolkit/features/collation/models/collation_state.dart';
import 'package:guji_toolkit/features/collation/services/collation_result_exporter.dart';

void main() {
  group('CollationResultExporter', () {
    test('getResolvedText with no changes', () {
      final result = const CollationResult(
        diff: 'hello',
        mergedView: [CollationChange(text: 'hello', type: CollationType.equal)],
        similarity: 1.0,
      );
      final text = CollationResultExporter.getResolvedText(result, {});
      expect(text, 'hello');
    });

    test('getResolvedText with resolved insertion', () {
      final result = const CollationResult(
        diff: 'he[+] llo',
        mergedView: [
          CollationChange(text: 'he', type: CollationType.equal),
          CollationChange(text: 'llo', type: CollationType.insert),
        ],
        similarity: 0.4,
      );
      // Resolution at index 1 is acceptNew
      final text = CollationResultExporter.getResolvedText(result, {
        1: DiffResolution.acceptNew,
      });
      expect(text, 'hello');
    });

    test(
      'getResolvedText with unresolved insertion defaults to empty (base text)',
      () {
        final result = const CollationResult(
          diff: 'he[+] llo',
          mergedView: [
            CollationChange(text: 'he', type: CollationType.equal),
            CollationChange(text: 'llo', type: CollationType.insert),
          ],
          similarity: 0.4,
        );
        final text = CollationResultExporter.getResolvedText(result, {});
        expect(text, 'he');
      },
    );

    test('getResolvedText with resolved deletion', () {
      final result = const CollationResult(
        diff: 'he[-] llo',
        mergedView: [
          CollationChange(text: 'he', type: CollationType.equal),
          CollationChange(text: 'llo', type: CollationType.delete),
        ],
        similarity: 0.4,
      );
      // Resolution at index 1 is acceptNew (Accept deletion)
      final text = CollationResultExporter.getResolvedText(result, {
        1: DiffResolution.acceptNew,
      });
      expect(text, 'he');
    });

    test('getResolvedText with unresolved deletion defaults to base text', () {
      final result = const CollationResult(
        diff: 'he[-] llo',
        mergedView: [
          CollationChange(text: 'he', type: CollationType.equal),
          CollationChange(text: 'llo', type: CollationType.delete),
        ],
        similarity: 0.4,
      );
      final text = CollationResultExporter.getResolvedText(result, {});
      expect(text, 'hello');
    });

    test('getResolvedText with resolved modification (Del+Ins)', () {
      final result = const CollationResult(
        diff: 'appl[-] e [+] y',
        mergedView: [
          CollationChange(text: 'appl', type: CollationType.equal),
          CollationChange(text: 'e', type: CollationType.delete),
          CollationChange(text: 'y', type: CollationType.insert),
        ],
        similarity: 0.8,
      );
      // Index 1 is delete 'e', index 2 is insert 'y'
      // Modification resolution is applied to the first index
      final text = CollationResultExporter.getResolvedText(result, {
        1: DiffResolution.acceptNew,
      });
      expect(text, 'apply');
    });

    test(
      'getResolvedText with unresolved modification defaults to original',
      () {
        final result = const CollationResult(
          diff: 'appl[-] e [+] y',
          mergedView: [
            CollationChange(text: 'appl', type: CollationType.equal),
            CollationChange(text: 'e', type: CollationType.delete),
            CollationChange(text: 'y', type: CollationType.insert),
          ],
          similarity: 0.8,
        );
        final text = CollationResultExporter.getResolvedText(result, {});
        expect(text, 'apple');
      },
    );

    test('calculateProgress identifies modifications correctly', () {
      final result = const CollationResult(
        diff: 'appl[-] e [+] y',
        mergedView: [
          CollationChange(text: 'appl', type: CollationType.equal),
          CollationChange(text: 'e', type: CollationType.delete),
          CollationChange(text: 'y', type: CollationType.insert),
        ],
        similarity: 0.8,
      );
      final stats = CollationResultExporter.calculateProgress(result, {
        1: DiffResolution.acceptNew,
      });
      expect(stats.total, 1);
      expect(stats.resolved, 1);
    });

    test('calculateProgress with multiple changes', () {
      final result = const CollationResult(
        diff: 'a [-] b [+] x  [-] c [+] d',
        mergedView: [
          CollationChange(text: 'a ', type: CollationType.equal),
          CollationChange(text: 'b', type: CollationType.delete),
          CollationChange(text: 'x', type: CollationType.insert),
          CollationChange(text: ' ', type: CollationType.equal),
          CollationChange(text: 'c', type: CollationType.delete),
          CollationChange(text: 'd', type: CollationType.insert),
        ],
        similarity: 0.5,
      );
      // 2 modifications: (b->x) and (c->d)
      final stats = CollationResultExporter.calculateProgress(result, {
        1: DiffResolution.acceptNew,
      });
      expect(stats.total, 2);
      expect(stats.resolved, 1);
    });
  });
}
