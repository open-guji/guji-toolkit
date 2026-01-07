import 'package:flutter/material.dart';
import 'package:guji_toolkit/features/collation/models/collation_state.dart';

class DiffMenuHelper {
  final BuildContext context;
  final Function(int index, DiffResolution resolution) onResolve;

  DiffMenuHelper(this.context, this.onResolve);

  Future<void> showMenuAt({
    required Offset globalPosition,
    required List<Widget> children,
    bool isVertical = false,
  }) async {
    final RenderBox overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox;
    // Adjust position to be below the text (approx line height + padding)
    // The user wants it "further down" to not block text.
    final Offset targetPosition = globalPosition + const Offset(0, 24);

    final RelativeRect position = RelativeRect.fromRect(
      Rect.fromPoints(targetPosition, targetPosition),
      Offset.zero & overlay.size,
    );

    await showMenu(
      context: context,
      position: position,
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      items: [
        PopupMenuItem(
          enabled: false,
          child: DefaultTextStyle(
            style: Theme.of(context).textTheme.bodyMedium!,
            child: _AdaptiveMenuLayout(
              isVertical: isVertical,
              children: children,
            ),
          ),
        ),
      ],
    );
  }

  void showModificationMenu(
    Offset position,
    int deleteIndex,
    String deleteText,
    int insertIndex,
    String insertText,
  ) {
    // User requested: Short -> Left/Right, Long -> Top/Bottom
    // Threshold: 4 characters
    final bool isLong = deleteText.length > 4 || insertText.length > 4;

    showMenuAt(
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
            Navigator.pop(context);
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
            Navigator.pop(context);
          },
        ),
      ],
    );
  }

  void showDeleteMenu(Offset position, int index, String text) {
    final bool isLong = text.length > 4;

    showMenuAt(
      globalPosition: position,
      isVertical: isLong,
      children: [
        _buildOptionItem(
          icon: Icons.undo,
          label: '保留 (恢复)',
          textPreview: text,
          color: Colors.grey.shade700,
          onTap: () {
            onResolve(index, DiffResolution.acceptOriginal);
            Navigator.pop(context);
          },
        ),
        _buildOptionItem(
          icon: Icons.check,
          label: '确认删除',
          textPreview: '(删除)',
          color: Colors.red.shade700,
          onTap: () {
            onResolve(index, DiffResolution.acceptNew);
            Navigator.pop(context);
          },
        ),
      ],
    );
  }

  void showInsertMenu(Offset position, int index, String text) {
    final bool isLong = text.length > 4;

    showMenuAt(
      globalPosition: position,
      isVertical: isLong,
      children: [
        _buildOptionItem(
          icon: Icons.close,
          label: '移除 (拒绝)',
          textPreview: '(移除)',
          color: Colors.grey.shade700,
          onTap: () {
            onResolve(index, DiffResolution.acceptOriginal);
            Navigator.pop(context);
          },
        ),
        _buildOptionItem(
          icon: Icons.check,
          label: '确认新增',
          textPreview: text,
          color: Colors.green.shade700,
          onTap: () {
            onResolve(index, DiffResolution.acceptNew);
            Navigator.pop(context);
          },
        ),
      ],
    );
  }

  Widget _buildOptionItem({
    required IconData icon,
    required String label,
    required String textPreview,
    required Color color,
    required VoidCallback onTap,
  }) {
    // Show full text if short, truncate if very long but keep enough context
    // If vertical, we can show more line width.
    final displayPreview = textPreview.length > 10
        ? '${textPreview.substring(0, 8)}...'
        : textPreview;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 4),
            Text(
              displayPreview,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: color,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
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
