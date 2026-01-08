import 'dart:async';
import 'package:flutter/material.dart';
import 'package:guji_toolkit/features/collation/models/collation_state.dart';

class DiffMenuHelper {
  final BuildContext context;
  final Function(int index, DiffResolution resolution) onResolve;

  // Hover state
  static OverlayEntry? _overlayEntry;
  static Timer? _closeTimer;

  DiffMenuHelper(this.context, this.onResolve);

  void hideOverlay() {
    _closeTimer?.cancel();
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _scheduleClose() {
    _closeTimer?.cancel();
    _closeTimer = Timer(const Duration(milliseconds: 300), () {
      hideOverlay();
    });
  }

  void _cancelClose() {
    _closeTimer?.cancel();
  }

  void showHoverMenu({
    required Offset globalPosition,
    required List<Widget> children,
    bool isVertical = false,
  }) {
    // If an overlay is already showing, remove it immediately
    hideOverlay();

    final overlayState = Overlay.of(context);

    // Position below the cursor/text, centered horizontally
    // Assuming a max width of 160 for a single-item-like look,
    // but the actual container has constraints.
    // We'll subtract 60 (half of minWidth) to best-effort center it.
    final double left = globalPosition.dx - 60;
    final double top = globalPosition.dy + 20;

    _overlayEntry = OverlayEntry(
      builder: (context) {
        return Positioned(
          left: left,
          top: top,
          child: MouseRegion(
            onEnter: (_) => _cancelClose(),
            onExit: (_) => _scheduleClose(),
            child: Material(
              color: Colors.transparent,
              child: Container(
                constraints: const BoxConstraints(maxWidth: 300),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 2.0),
                  child: _AdaptiveMenuLayout(
                    isVertical: isVertical,
                    children: children,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );

    overlayState.insert(_overlayEntry!);
  }

  // --- Specialized Menus ---

  void showModificationMenu(
    Offset position,
    int deleteIndex,
    String deleteText,
    int insertIndex,
    String insertText,
  ) {
    final bool isLong = deleteText.length > 4 || insertText.length > 4;

    showHoverMenu(
      globalPosition: position,
      isVertical: isLong,
      children: [
        _buildOptionItem(
          icon: Icons.undo,
          label: '保留底本',
          textPreview: deleteText,
          color: Colors.grey.shade700,
          onTap: () {
            onResolve(deleteIndex, DiffResolution.acceptOriginal);
            onResolve(insertIndex, DiffResolution.acceptOriginal);
            hideOverlay();
          },
        ),
        _buildOptionItem(
          icon: Icons.check,
          label: '采纳校本',
          textPreview: insertText,
          color: Colors.green.shade700,
          onTap: () {
            onResolve(deleteIndex, DiffResolution.acceptNew);
            onResolve(insertIndex, DiffResolution.acceptNew);
            hideOverlay();
          },
        ),
      ],
    );
  }

  void showDeleteMenu(Offset position, int index, String text) {
    final bool isLong = text.length > 4;

    showHoverMenu(
      globalPosition: position,
      isVertical: isLong,
      children: [
        _buildOptionItem(
          icon: Icons.undo,
          label: '保留',
          textPreview: text,
          color: Colors.grey.shade700,
          onTap: () {
            onResolve(index, DiffResolution.acceptOriginal);
            hideOverlay();
          },
        ),
        _buildOptionItem(
          icon: Icons.check,
          label: '删除',
          textPreview: '(删除)',
          color: Colors.red.shade700,
          onTap: () {
            onResolve(index, DiffResolution.acceptNew);
            hideOverlay();
          },
        ),
      ],
    );
  }

  void showInsertMenu(Offset position, int index, String text) {
    final bool isLong = text.length > 4;

    showHoverMenu(
      globalPosition: position,
      isVertical: isLong,
      children: [
        _buildOptionItem(
          icon: Icons.close,
          label: '移除',
          textPreview: '(移除)',
          color: Colors.grey.shade700,
          onTap: () {
            onResolve(index, DiffResolution.acceptOriginal);
            hideOverlay();
          },
        ),
        _buildOptionItem(
          icon: Icons.check,
          label: '新增',
          textPreview: text,
          color: Colors.green.shade700,
          onTap: () {
            onResolve(index, DiffResolution.acceptNew);
            hideOverlay();
          },
        ),
      ],
    );
  }

  // --- Helpers for Span Interaction ---

  void onSpanEnter(Offset globalPosition, Function showMenuCallback) {
    _cancelClose();
    showMenuCallback();
  }

  void onSpanExit() {
    _scheduleClose();
  }

  Widget _buildOptionItem({
    required IconData icon,
    required String label,
    required String textPreview,
    required Color color,
    required VoidCallback onTap,
  }) {
    final displayPreview = textPreview.length > 10
        ? '${textPreview.substring(0, 8)}...'
        : textPreview;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      onHover: (hovering) {
        if (hovering) _cancelClose();
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 10.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 2),
            Text(
              displayPreview,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: color,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              label,
              style: const TextStyle(fontSize: 10, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

class _AdaptiveMenuLayout extends StatelessWidget {
  final List<Widget> children;
  final bool isVertical;

  const _AdaptiveMenuLayout({required this.children, this.isVertical = false});

  @override
  Widget build(BuildContext context) {
    if (isVertical) {
      return IntrinsicWidth(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: children,
        ),
      );
    }
    return IntrinsicWidth(
      child: Row(mainAxisSize: MainAxisSize.min, children: children),
    );
  }
}
