import 'package:flutter/material.dart';
import 'package:guji_diff/guji_diff.dart';
import 'package:guji_toolkit/features/collation/models/collation_state.dart';
import 'diff_menu_helper.dart';
import 'hoverable_text_widget.dart';

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

  List<InlineSpan> build() {
    final List<InlineSpan> spans = [];
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
    // Append an invisible zero-width space at the end to force the last span
    // to be rendered (prevents Flutter from trimming trailing whitespace-only spans).
    spans.add(const TextSpan(text: '\u200B'));
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

  void _addModificationSpans(List<InlineSpan> spans, int i) {
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

    // Wrap both in a single hover unit to ensure alignment with the first (original/delete) element
    spans.add(
      WidgetSpan(
        alignment: PlaceholderAlignment.baseline,
        baseline: TextBaseline.alphabetic,
        child: HoverableTextWidget(
          menuBuilder: (context, close) => menuHelper.buildModificationMenu(
            deleteIndex: delIdx,
            deleteText: deleteChange.text,
            insertIndex: insIdx,
            insertText: insertChange.text,
            close: close,
          ),
          child: Text.rich(
            TextSpan(
              children: [
                if (currentResolution == DiffResolution.acceptOriginal)
                  TextSpan(
                    text: deleteChange.text,
                    style: TextStyle(
                      color: Colors.black87,
                      backgroundColor: Colors.yellow.shade200,
                    ),
                  )
                else if (currentResolution == DiffResolution.acceptNew)
                  TextSpan(
                    text: insertChange.text,
                    style: TextStyle(
                      color: Colors.black87,
                      backgroundColor: Colors.yellow.shade200,
                    ),
                  )
                else ...[
                  TextSpan(
                    text: deleteChange.text,
                    style: TextStyle(
                      backgroundColor: Colors.red.shade100,
                      color: Colors.red.shade900,
                      decoration: TextDecoration.lineThrough,
                    ),
                  ),
                  TextSpan(
                    text: insertChange.text,
                    style: TextStyle(
                      backgroundColor: Colors.green.shade100,
                      color: Colors.green.shade900,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _addSingleSpan(
    List<InlineSpan> spans,
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
      if (resolution == DiffResolution.acceptOriginal) {
        // Restored (Yellow)
        spans.add(
          WidgetSpan(
            alignment: PlaceholderAlignment.baseline,
            baseline: TextBaseline.alphabetic,
            child: HoverableTextWidget(
              text: change.text,
              style: TextStyle(
                color: Colors.black87,
                backgroundColor: Colors.yellow.shade200,
              ),
              menuBuilder: (context, close) => menuHelper.buildDeleteMenu(
                index: i,
                text: change.text,
                close: close,
              ),
            ),
          ),
        );
      } else if (resolution == DiffResolution.acceptNew) {
        // Deleted (Placeholder)
        spans.add(
          WidgetSpan(
            alignment: PlaceholderAlignment.baseline,
            baseline: TextBaseline.alphabetic,
            child: HoverableTextWidget(
              text: '\u2423', // Open box space symbol
              style: TextStyle(
                backgroundColor: Colors.yellow.shade200,
                color: Colors.yellow.shade900.withValues(alpha: 0.5),
              ),
              menuBuilder: (context, close) => menuHelper.buildDeleteMenu(
                index: i,
                text: change.text,
                close: close,
              ),
            ),
          ),
        );
      } else {
        // Unresolved (Red Strike)
        spans.add(
          WidgetSpan(
            alignment: PlaceholderAlignment.baseline,
            baseline: TextBaseline.alphabetic,
            child: HoverableTextWidget(
              text: change.text,
              style: TextStyle(
                backgroundColor: Colors.red.shade100,
                color: Colors.red.shade900,
                decoration: TextDecoration.lineThrough,
              ),
              menuBuilder: (context, close) => menuHelper.buildDeleteMenu(
                index: i,
                text: change.text,
                close: close,
              ),
            ),
          ),
        );
      }
    } else if (change.type == CollationType.insert) {
      if (resolution == DiffResolution.acceptNew) {
        // Accepted (Yellow)
        spans.add(
          WidgetSpan(
            alignment: PlaceholderAlignment.baseline,
            baseline: TextBaseline.alphabetic,
            child: HoverableTextWidget(
              text: change.text,
              style: TextStyle(
                color: Colors.black87,
                backgroundColor: Colors.yellow.shade200,
              ),
              menuBuilder: (context, close) => menuHelper.buildInsertMenu(
                index: i,
                text: change.text,
                close: close,
              ),
            ),
          ),
        );
      } else if (resolution == DiffResolution.acceptOriginal) {
        // Rejected (Placeholder)
        spans.add(
          WidgetSpan(
            alignment: PlaceholderAlignment.baseline,
            baseline: TextBaseline.alphabetic,
            child: HoverableTextWidget(
              text: '\u2423', // Open box space symbol
              style: TextStyle(
                backgroundColor: Colors.yellow.shade200,
                color: Colors.yellow.shade900.withValues(alpha: 0.5),
              ),
              menuBuilder: (context, close) => menuHelper.buildInsertMenu(
                index: i,
                text: change.text,
                close: close,
              ),
            ),
          ),
        );
      } else {
        // Unresolved (Green Bold)
        spans.add(
          WidgetSpan(
            alignment: PlaceholderAlignment.baseline,
            baseline: TextBaseline.alphabetic,
            child: HoverableTextWidget(
              text: change.text,
              style: TextStyle(
                backgroundColor: Colors.green.shade100,
                color: Colors.green.shade900,
                fontWeight: FontWeight.bold,
              ),
              menuBuilder: (context, close) => menuHelper.buildInsertMenu(
                index: i,
                text: change.text,
                close: close,
              ),
            ),
          ),
        );
      }
    }
  }
}
