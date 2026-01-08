import 'package:flutter/material.dart';
import 'package:guji_toolkit/features/collation/models/collation_state.dart';

class DiffMenuHelper {
  final BuildContext context;
  final Function(int index, DiffResolution resolution) onResolve;

  DiffMenuHelper(this.context, this.onResolve);

  // --- Specialized Menus ---

  Widget buildModificationMenu({
    required int deleteIndex,
    required String deleteText,
    required int insertIndex,
    required String insertText,
    required VoidCallback close,
  }) {
    return _AdaptiveMenuLayout(
      children: [
        _buildOptionItem(
          icon: Icons.undo,
          label: '保留底本',
          textPreview: deleteText,
          color: Colors.grey.shade700,
          onTap: () {
            onResolve(deleteIndex, DiffResolution.acceptOriginal);
            onResolve(insertIndex, DiffResolution.acceptOriginal);
            close();
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
            close();
          },
        ),
      ],
    );
  }

  Widget buildDeleteMenu({
    required int index,
    required String text,
    required VoidCallback close,
  }) {
    return _AdaptiveMenuLayout(
      children: [
        _buildOptionItem(
          icon: Icons.undo,
          label: '保留',
          textPreview: text,
          color: Colors.grey.shade700,
          onTap: () {
            onResolve(index, DiffResolution.acceptOriginal);
            close();
          },
        ),
        _buildOptionItem(
          icon: Icons.close,
          label: '移除',
          textPreview: '\u2423',
          color: Colors.grey.shade700,
          onTap: () {
            onResolve(index, DiffResolution.acceptNew);
            close();
          },
        ),
      ],
    );
  }

  Widget buildInsertMenu({
    required int index,
    required String text,
    required VoidCallback close,
  }) {
    return _AdaptiveMenuLayout(
      children: [
        _buildOptionItem(
          icon: Icons.close,
          label: '移除',
          textPreview: '\u2423',
          color: Colors.grey.shade700,
          onTap: () {
            onResolve(index, DiffResolution.acceptOriginal);
            close();
          },
        ),
        _buildOptionItem(
          icon: Icons.check,
          label: '新增',
          textPreview: text,
          color: Colors.green.shade700,
          onTap: () {
            onResolve(index, DiffResolution.acceptNew);
            close();
          },
        ),
      ],
    );
  }

  // --- Helpers for Span Interaction ---

  Widget _buildOptionItem({
    required IconData icon,
    required String label,
    required String textPreview,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      onHover: (_) {},
      child: Container(
        constraints: const BoxConstraints(maxWidth: 200),
        padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 10.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 20),
            if (textPreview.isNotEmpty) ...[
              const SizedBox(height: 2),
              Text(
                textPreview,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: color,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(fontSize: 10, color: Colors.grey),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class _AdaptiveMenuLayout extends StatelessWidget {
  final List<Widget> children;

  const _AdaptiveMenuLayout({required this.children});

  @override
  Widget build(BuildContext context) {
    return IntrinsicWidth(
      child: Row(mainAxisSize: MainAxisSize.min, children: children),
    );
  }
}
