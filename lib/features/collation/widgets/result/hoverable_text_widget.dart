import 'dart:async';
import 'package:flutter/material.dart';

/// A widget that displays text with a hoverable tooltip-style menu
class HoverableTextWidget extends StatefulWidget {
  final String text;
  final TextStyle? style;
  final Widget Function(BuildContext context, VoidCallback close) menuBuilder;
  final LayerLink? anchorLink; // Optional anchor link for menu positioning
  final bool isAnchor; // Whether this widget is the anchor (creates the target)

  const HoverableTextWidget({
    super.key,
    required this.text,
    this.style,
    required this.menuBuilder,
    this.anchorLink,
    this.isAnchor = false,
  });

  @override
  State<HoverableTextWidget> createState() => _HoverableTextWidgetState();
}

class _HoverableTextWidgetState extends State<HoverableTextWidget> {
  OverlayEntry? _overlayEntry;
  final LayerLink _layerLink = LayerLink();
  Timer? _hideTimer;

  void _showMenu() {
    // Cancel any pending hide operation
    _hideTimer?.cancel();

    if (_overlayEntry != null) return;

    // Use anchorLink if provided, otherwise use own link
    final linkToUse = widget.anchorLink ?? _layerLink;

    _overlayEntry = OverlayEntry(
      builder: (context) => CompositedTransformFollower(
        link: linkToUse,
        targetAnchor: Alignment.bottomLeft,
        followerAnchor: Alignment.topLeft,
        offset: const Offset(0, 4),
        child: Material(
          elevation: 8,
          borderRadius: BorderRadius.circular(8),
          child: MouseRegion(
            onEnter: (_) => _cancelHide(),
            onExit: (_) => _scheduleHide(),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: IntrinsicWidth(
                child: widget.menuBuilder(context, _hideMenu),
              ),
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  void _scheduleHide() {
    _hideTimer?.cancel();
    _hideTimer = Timer(const Duration(milliseconds: 200), () {
      _hideMenu();
    });
  }

  void _cancelHide() {
    _hideTimer?.cancel();
  }

  void _hideMenu() {
    _hideTimer?.cancel();
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    _hideMenu();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textWidget = MouseRegion(
      onEnter: (_) => _showMenu(),
      onExit: (_) => _scheduleHide(),
      child: Text(widget.text, style: widget.style),
    );

    // If this is the anchor, wrap with CompositedTransformTarget
    if (widget.isAnchor || widget.anchorLink == null) {
      return CompositedTransformTarget(link: _layerLink, child: textWidget);
    }

    // Otherwise just return the text with MouseRegion
    return textWidget;
  }
}
