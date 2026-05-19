import 'package:flutter/material.dart';

import '../models/enums.dart';
import '../scope.dart';

/// Marks the subtree that drives the "move" gesture for the enclosing panel.
///
/// Wrap your panel's title bar or a dedicated grip area with [PanelMoveHandle].
/// Dragging anywhere inside the handle moves the panel via the
/// [PanelEntryScope]'s controller; tapping it brings the panel to front.
///
/// The rest of the panel body is left untouched, so child scrollables, buttons
/// and other gestures behave normally without competing with the move
/// recognizer.
class PanelMoveHandle extends StatelessWidget {
  /// Whether the handle responds to gestures.
  final bool enabled;

  /// Mouse cursor shown when hovering the handle.
  final MouseCursor cursor;

  /// How the handle should behave during hit testing.
  final HitTestBehavior hitTestBehavior;

  final Widget child;

  const PanelMoveHandle({
    super.key,
    required this.child,
    this.enabled = true,
    this.cursor = SystemMouseCursors.move,
    this.hitTestBehavior = HitTestBehavior.opaque,
  });

  @override
  Widget build(BuildContext context) {
    if (!enabled) return child;

    final controller = PanelEntryScope.of(context).controller;

    return MouseRegion(
      cursor: cursor,
      child: GestureDetector(
        behavior: hitTestBehavior,
        onPanStart: (_) => controller.bringToFront(),
        onPanUpdate: (details) {
          if (controller.value.mode != PanelViewMode.normal) return;
          controller.move(details.delta.dx, details.delta.dy);
        },
        onTap: controller.bringToFront,
        child: child,
      ),
    );
  }
}
