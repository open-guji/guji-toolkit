import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:guji_diff/guji_diff.dart';
import 'package:guji_toolkit/features/collation/models/collation_state.dart';
import 'package:guji_toolkit/features/collation/widgets/diff_menu_helper.dart';

class DiffSpanBuilder {
  final BuildContext context;
  final List<CollationChange> changes;
  final Map<int, DiffResolution> resolutions;
  final DiffMenuHelper menuHelper;

  DiffSpanBuilder({
    required this.context,
    required this.changes,
    required this.resolutions,
    required this.menuHelper,
  });

  List<TextSpan> build() {
    final List<TextSpan> spans = [];
    int i = 0;
    while (i < changes.length) {
      final change = changes[i];
      final resolution = resolutions[i] ?? DiffResolution.unresolved;

      bool isModification = _isModification(i);

      if (isModification) {
        _addModificationSpans(spans, i);
        i += 2;
      } else {
        _addSingleSpan(spans, i, change, resolution);
        i++;
      }
    }
    return spans;
  }

  bool _isModification(int i) {
    if (i + 1 >= changes.length) return false;
    return changes[i].type == CollationType.delete &&
        changes[i + 1].type == CollationType.insert;
  }

  void _addModificationSpans(List<TextSpan> spans, int i) {
    final deleteChange = changes[i];
    final insertChange = changes[i + 1];
    final currentResolution = resolutions[i] ?? DiffResolution.unresolved;
    final deleteIndex = i;
    final insertIndex = i + 1;

    void showMenu(TapUpDetails details) {
      menuHelper.showModificationMenu(
        details.globalPosition,
        deleteIndex,
        deleteChange.text,
        insertIndex,
        insertChange.text,
      );
    }

    if (currentResolution == DiffResolution.acceptOriginal) {
      // Keep Original (Yellow)
      spans.add(
        TextSpan(
          text: deleteChange.text,
          style: TextStyle(
            color: Colors.black87,
            backgroundColor: Colors.yellow.shade200,
          ),
          recognizer: TapGestureRecognizer()..onTapUp = showMenu,
        ),
      );
    } else if (currentResolution == DiffResolution.acceptNew) {
      // Accept New (Yellow)
      spans.add(
        TextSpan(
          text: insertChange.text,
          style: TextStyle(
            color: Colors.black87,
            backgroundColor: Colors.yellow.shade200,
          ),
          recognizer: TapGestureRecognizer()..onTapUp = showMenu,
        ),
      );
    } else {
      // Unresolved: Red Del + Green Ins
      spans.add(
        TextSpan(
          text: deleteChange.text,
          style: TextStyle(
            backgroundColor: Colors.red.shade100,
            color: Colors.red.shade900,
            decoration: TextDecoration.lineThrough,
          ),
          recognizer: TapGestureRecognizer()..onTapUp = showMenu,
        ),
      );
      spans.add(
        TextSpan(
          text: insertChange.text,
          style: TextStyle(
            backgroundColor: Colors.green.shade100,
            color: Colors.green.shade900,
            fontWeight: FontWeight.bold,
          ),
          recognizer: TapGestureRecognizer()..onTapUp = showMenu,
        ),
      );
    }
  }

  void _addSingleSpan(
    List<TextSpan> spans,
    int i,
    CollationChange change,
    DiffResolution resolution,
  ) {
    if (change.type == CollationType.equal) {
      spans.add(
        TextSpan(
          text: change.text,
          style: const TextStyle(color: Colors.black87),
        ),
      );
      return;
    }

    if (change.type == CollationType.delete) {
      void showMenu(TapUpDetails details) {
        menuHelper.showDeleteMenu(details.globalPosition, i, change.text);
      }

      if (resolution == DiffResolution.acceptOriginal) {
        // Restored (Yellow)
        spans.add(
          TextSpan(
            text: change.text,
            style: TextStyle(
              color: Colors.black87,
              backgroundColor: Colors.yellow.shade200,
            ),
            recognizer: TapGestureRecognizer()..onTapUp = showMenu,
          ),
        );
      } else if (resolution == DiffResolution.acceptNew) {
        // Deleted (Placeholder) - User wants a chance to undo
        spans.add(
          TextSpan(
            text: '\u3000', // Full-width space placeholder
            style: TextStyle(backgroundColor: Colors.yellow.shade200),
            recognizer: TapGestureRecognizer()..onTapUp = showMenu,
          ),
        );
      } else {
        // Unresolved (Red Strike)
        spans.add(
          TextSpan(
            text: change.text,
            style: TextStyle(
              backgroundColor: Colors.red.shade100,
              color: Colors.red.shade900,
              decoration: TextDecoration.lineThrough,
            ),
            recognizer: TapGestureRecognizer()..onTapUp = showMenu,
          ),
        );
      }
    } else if (change.type == CollationType.insert) {
      void showMenu(TapUpDetails details) {
        menuHelper.showInsertMenu(details.globalPosition, i, change.text);
      }

      if (resolution == DiffResolution.acceptNew) {
        // Accepted (Yellow)
        spans.add(
          TextSpan(
            text: change.text,
            style: TextStyle(
              color: Colors.black87,
              backgroundColor: Colors.yellow.shade200,
            ),
            recognizer: TapGestureRecognizer()..onTapUp = showMenu,
          ),
        );
      } else if (resolution == DiffResolution.acceptOriginal) {
        // Rejected (Placeholder)
        spans.add(
          TextSpan(
            text: '\u3000', // Full-width space placeholder
            style: TextStyle(backgroundColor: Colors.yellow.shade200),
            recognizer: TapGestureRecognizer()..onTapUp = showMenu,
          ),
        );
      } else {
        // Unresolved (Green Bold)
        spans.add(
          TextSpan(
            text: change.text,
            style: TextStyle(
              backgroundColor: Colors.green.shade100,
              color: Colors.green.shade900,
              fontWeight: FontWeight.bold,
            ),
            recognizer: TapGestureRecognizer()..onTapUp = showMenu,
          ),
        );
      }
    }
  }
}
