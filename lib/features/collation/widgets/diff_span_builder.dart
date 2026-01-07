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
    final c1 = changes[i];
    final c2 = changes[i + 1];
    // Check Del->Ins (Standard) OR Ins->Del (Robustness)
    return (c1.type == CollationType.delete &&
            c2.type == CollationType.insert) ||
        (c1.type == CollationType.insert && c2.type == CollationType.delete);
  }

  void _addModificationSpans(List<TextSpan> spans, int i) {
    // Identify which is which
    final c1 = changes[i];
    final c2 = changes[i + 1];

    CollationChange deleteChange;
    CollationChange insertChange;

    if (c1.type == CollationType.delete) {
      deleteChange = c1;
      insertChange = c2;
    } else {
      deleteChange = c2;
      insertChange = c1;
    }

    final int delIdx = c1.type == CollationType.delete ? i : i + 1;
    final int insIdx = c1.type == CollationType.insert ? i : i + 1;

    final currentResolution = resolutions[i] ?? DiffResolution.unresolved;

    void showMenu(PointerEnterEvent event) {
      menuHelper.showModificationMenu(
        event.position,
        delIdx,
        deleteChange.text,
        insIdx,
        insertChange.text,
      );
    }

    void onExit(PointerExitEvent event) {
      menuHelper.onSpanExit();
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
          onEnter: showMenu,
          onExit: onExit,
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
          onEnter: showMenu,
          onExit: onExit,
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
          onEnter: showMenu,
          onExit: onExit,
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
          onEnter: showMenu,
          onExit: onExit,
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

    void onExit(PointerExitEvent event) {
      menuHelper.onSpanExit();
    }

    if (change.type == CollationType.delete) {
      void showMenu(PointerEnterEvent event) {
        menuHelper.showDeleteMenu(event.position, i, change.text);
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
            onEnter: showMenu,
            onExit: onExit,
          ),
        );
      } else if (resolution == DiffResolution.acceptNew) {
        // Deleted (Placeholder)
        spans.add(
          TextSpan(
            text: '\u3000', // Full-width space placeholder
            style: TextStyle(backgroundColor: Colors.yellow.shade200),
            onEnter: showMenu,
            onExit: onExit,
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
            onEnter: showMenu,
            onExit: onExit,
          ),
        );
      }
    } else if (change.type == CollationType.insert) {
      void showMenu(PointerEnterEvent event) {
        menuHelper.showInsertMenu(event.position, i, change.text);
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
            onEnter: showMenu,
            onExit: onExit,
          ),
        );
      } else if (resolution == DiffResolution.acceptOriginal) {
        // Rejected (Placeholder)
        spans.add(
          TextSpan(
            text: '\u3000', // Full-width space placeholder
            style: TextStyle(backgroundColor: Colors.yellow.shade200),
            onEnter: showMenu,
            onExit: onExit,
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
            onEnter: showMenu,
            onExit: onExit,
          ),
        );
      }
    }
  }
}
