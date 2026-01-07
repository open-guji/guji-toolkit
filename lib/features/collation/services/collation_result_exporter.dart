import 'package:guji_diff/guji_diff.dart';
import 'package:guji_toolkit/features/collation/models/collation_state.dart';

/// Service responsible for exporting collation results and calculating progress.
class CollationResultExporter {
  /// Calculates the resolution progress.
  /// A 'unit' of progress is either a single addition/deletion or a modification (Del+Ins).
  static ProgressStats calculateProgress(
    CollationResult result,
    Map<int, DiffResolution> resolutions,
  ) {
    int total = 0;
    int resolved = 0;
    int i = 0;
    final changes = result.mergedView;

    while (i < changes.length) {
      final change = changes[i];
      bool isDiff = false;
      bool isUnitResolved = false;

      // Check for modification (Delete + Insert)
      if (change.type == CollationType.delete && i + 1 < changes.length) {
        final nextChange = changes[i + 1];
        if (nextChange.type == CollationType.insert) {
          isDiff = true;
          // In modification mode, usually both share the same resolution state.
          isUnitResolved =
              resolutions[i] != null &&
              resolutions[i] != DiffResolution.unresolved;
          i += 2;
        } else {
          isDiff = true;
          isUnitResolved =
              resolutions[i] != null &&
              resolutions[i] != DiffResolution.unresolved;
          i++;
        }
      } else if (change.type != CollationType.equal) {
        isDiff = true;
        isUnitResolved =
            resolutions[i] != null &&
            resolutions[i] != DiffResolution.unresolved;
        i++;
      } else {
        i++;
      }

      if (isDiff) {
        total++;
        if (isUnitResolved) {
          resolved++;
        }
      }
    }
    return ProgressStats(total: total, resolved: resolved);
  }

  /// Generates the final resolved text based on the user's choices.
  /// Unresolved differences default to the 'Original' (base) text.
  static String getResolvedText(
    CollationResult result,
    Map<int, DiffResolution> resolutions,
  ) {
    final buffer = StringBuffer();
    int i = 0;
    final changes = result.mergedView;

    while (i < changes.length) {
      final change = changes[i];
      final resolution = resolutions[i] ?? DiffResolution.unresolved;

      if (change.type == CollationType.equal) {
        buffer.write(change.text);
        i++;
      } else if (change.type == CollationType.delete &&
          i + 1 < changes.length &&
          changes[i + 1].type == CollationType.insert) {
        // Modification mode
        final insertChange = changes[i + 1];
        if (resolution == DiffResolution.acceptNew) {
          buffer.write(insertChange.text);
        } else {
          // Default to Original if unresolved or acceptOriginal
          buffer.write(change.text);
        }
        i += 2;
      } else if (change.type == CollationType.delete) {
        // Single deletion
        if (resolution != DiffResolution.acceptNew) {
          // Keep if not accepted as delete (i.e., keep original)
          buffer.write(change.text);
        }
        i++;
      } else if (change.type == CollationType.insert) {
        // Single insertion
        if (resolution == DiffResolution.acceptNew) {
          buffer.write(change.text);
        }
        i++;
      }
    }
    return buffer.toString();
  }
}

class ProgressStats {
  final int total;
  final int resolved;
  const ProgressStats({required this.total, required this.resolved});
}
