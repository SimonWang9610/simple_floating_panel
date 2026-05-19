import 'package:flutter/material.dart';

import '../models/enums.dart';
import '../models/resize_direction.dart';
import '../scope.dart';

/// A region that resizes the enclosing panel in [direction] when dragged.
///
/// Compose these around the parts of the panel you want resize affordances on.
/// Each handle owns its own gesture recognizer over its own bounds, so nothing
/// inside the panel body (scrollables, inputs, etc.) competes with the resize
/// gesture.
///
/// For the common "add resize handles on every edge and corner" use case,
/// prefer [PanelResizeBorder] which composes eight handles around a child.
class PanelResizeEdgeHandle extends StatelessWidget {
  /// Direction this handle resizes in.
  final ResizeDirection direction;

  /// Whether the handle responds to gestures.
  final bool enabled;

  /// Mouse cursor shown when hovering. Defaults to the directional resize cursor.
  final MouseCursor? cursor;

  /// How the handle should behave during hit testing. Defaults to [HitTestBehavior.opaque]
  /// so the handle reliably claims its bounds even if [child] is transparent.
  final HitTestBehavior hitTestBehavior;

  final Widget child;

  const PanelResizeEdgeHandle({
    super.key,
    required this.direction,
    required this.child,
    this.enabled = true,
    this.cursor,
    this.hitTestBehavior = HitTestBehavior.opaque,
  });

  @override
  Widget build(BuildContext context) {
    if (!enabled) return child;

    final controller = PanelEntryScope.of(context).controller;

    return MouseRegion(
      cursor: cursor ?? direction.cursor,
      child: GestureDetector(
        behavior: hitTestBehavior,
        onPanStart: (_) => controller.bringToFront(),
        onPanUpdate: (details) {
          if (controller.value.mode != PanelViewMode.normal) return;
          controller.resize(details.delta, direction);
        },
        child: child,
      ),
    );
  }
}

/// Wraps [child] with eight invisible [PanelResizeHandle]s — one per edge and
/// one per corner — laid out via a [Stack].
///
/// The handles only intercept pointer events within their [thickness]-wide edge
/// strips, so the body in the centre remains free for scrollables, taps, and
/// anything else.
class PanelResizeHandle extends StatelessWidget {
  /// Thickness, in logical pixels, of each edge handle. Corner handles are
  /// [thickness] × [thickness] and overlap the edge handles at the corners.
  final double thickness;

  /// Disable to remove all eight handles (e.g. when the panel is maximized).
  final bool enabled;

  final Widget child;

  const PanelResizeHandle({
    super.key,
    required this.child,
    this.thickness = 5,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    if (!enabled) return child;

    return Stack(
      children: [
        Positioned.fill(child: child),
        Positioned(
          top: 0,
          left: thickness,
          right: thickness,
          height: thickness,
          child: const PanelResizeEdgeHandle(direction: ResizeDirection.up, child: SizedBox.expand()),
        ),
        Positioned(
          bottom: 0,
          left: thickness,
          right: thickness,
          height: thickness,
          child: const PanelResizeEdgeHandle(direction: ResizeDirection.down, child: SizedBox.expand()),
        ),
        Positioned(
          top: thickness,
          bottom: thickness,
          left: 0,
          width: thickness,
          child: const PanelResizeEdgeHandle(direction: ResizeDirection.left, child: SizedBox.expand()),
        ),
        Positioned(
          top: thickness,
          bottom: thickness,
          right: 0,
          width: thickness,
          child: const PanelResizeEdgeHandle(direction: ResizeDirection.right, child: SizedBox.expand()),
        ),
        Positioned(
          top: 0,
          left: 0,
          width: thickness,
          height: thickness,
          child: const PanelResizeEdgeHandle(direction: ResizeDirection.topLeft, child: SizedBox.expand()),
        ),
        Positioned(
          top: 0,
          right: 0,
          width: thickness,
          height: thickness,
          child: const PanelResizeEdgeHandle(direction: ResizeDirection.topRight, child: SizedBox.expand()),
        ),
        Positioned(
          bottom: 0,
          left: 0,
          width: thickness,
          height: thickness,
          child: const PanelResizeEdgeHandle(direction: ResizeDirection.bottomLeft, child: SizedBox.expand()),
        ),
        Positioned(
          bottom: 0,
          right: 0,
          width: thickness,
          height: thickness,
          child: const PanelResizeEdgeHandle(direction: ResizeDirection.bottomRight, child: SizedBox.expand()),
        ),
      ],
    );
  }
}

extension on ResizeDirection {
  MouseCursor get cursor {
    switch (this) {
      case ResizeDirection.up || ResizeDirection.down:
        return SystemMouseCursors.resizeUpDown;
      case ResizeDirection.left || ResizeDirection.right:
        return SystemMouseCursors.resizeLeftRight;
      case ResizeDirection.topLeft || ResizeDirection.bottomRight:
        return SystemMouseCursors.resizeUpLeftDownRight;
      case ResizeDirection.topRight || ResizeDirection.bottomLeft:
        return SystemMouseCursors.resizeUpRightDownLeft;
    }
  }
}
