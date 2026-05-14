import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:simple_floating_panel/src/components/gestures.dart';

import '../models/resize_direction.dart';

class PanelGestureDetector extends StatefulWidget {
  final bool enabled;
  final bool resizable;
  final double resizeThreshold;
  final VoidCallback? onTap;
  final VoidCallback? onInteractionStart;
  final void Function(Offset delta)? onMoveUpdate;
  final void Function(Offset delta, ResizeDirection direction)? onResizeUpdate;
  final HitTestBehavior hitTestBehavior;

  final Widget child;

  const PanelGestureDetector({
    super.key,
    required this.child,
    this.enabled = true,
    this.resizable = true,
    this.resizeThreshold = 5,
    this.onTap,
    this.onInteractionStart,
    this.onMoveUpdate,
    this.onResizeUpdate,
    this.hitTestBehavior = HitTestBehavior.translucent,
  });

  @override
  State<PanelGestureDetector> createState() => _PanelGestureDetectorState();
}

class _PanelGestureDetectorState extends State<PanelGestureDetector> with _ResizeZoneDeterminer<PanelGestureDetector> {
  @override
  bool get resizable => widget.resizable;

  @override
  double get threshold => widget.resizeThreshold;

  final _cursor = ValueNotifier<MouseCursor>(MouseCursor.defer);
  bool _gestureActive = false;

  @override
  void dispose() {
    _cursor.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final gestures = <Type, GestureRecognizerFactory>{};
    final DeviceGestureSettings? gestureSettings = MediaQuery.maybeGestureSettingsOf(context);
    final ScrollBehavior configuration = ScrollConfiguration.of(context);

    if (resizable && widget.enabled && widget.onResizeUpdate != null) {
      gestures[PanelResizeGestureRecognizer] = GestureRecognizerFactoryWithHandlers<PanelResizeGestureRecognizer>(
        () => PanelResizeGestureRecognizer(debugOwner: this, directionChecker: resizeDirectionAt),
        (instance) {
          instance
            ..gestureSettings = gestureSettings
            ..multitouchDragStrategy = configuration.getMultitouchDragStrategy(context)
            ..onStart = _onGestureStart
            ..onEnd = _onGestureEnd
            ..onCancel = _markGestureIdle
            ..onUpdate = (details) {
              final direction = instance.activeDirection;
              if (direction != null) {
                widget.onResizeUpdate?.call(details.delta, direction);
              }
            };
        },
      );
    }

    if (widget.enabled && widget.onMoveUpdate != null) {
      gestures[PanelMoveGestureRecognizer] = GestureRecognizerFactoryWithHandlers<PanelMoveGestureRecognizer>(
        () => PanelMoveGestureRecognizer(debugOwner: this, moveChecker: _checkMoveAllowed),
        (instance) {
          instance
            ..gestureSettings = gestureSettings
            ..multitouchDragStrategy = configuration.getMultitouchDragStrategy(context)
            ..onStart = _onGestureStart
            ..onEnd = _onGestureEnd
            ..onCancel = _markGestureIdle
            ..onUpdate = (details) {
              widget.onMoveUpdate?.call(details.delta);
            };
        },
      );
    }

    if (widget.enabled && widget.onTap != null) {
      gestures[TapGestureRecognizer] = GestureRecognizerFactoryWithHandlers<TapGestureRecognizer>(
        () => TapGestureRecognizer(debugOwner: this),
        (instance) {
          instance
            ..onTap = widget.onTap
            ..gestureSettings = gestureSettings;
        },
      );
    }

    return IgnorePointer(
      ignoring: !widget.enabled,
      child: ValueListenableBuilder<MouseCursor>(
        valueListenable: _cursor,
        builder: (_, cursor, __) {
          return MouseRegion(
            cursor: cursor,
            hitTestBehavior: widget.hitTestBehavior,
            onEnter: (event) {
              if (!_gestureActive) {
                _updateCursor(event.position);
              }
            },
            onExit: (_) {
              if (!_gestureActive) {
                _cursor.value = MouseCursor.defer;
              }
            },
            onHover: (event) {
              if (!_gestureActive) {
                _updateCursor(event.position);
              }
            },
            child: RawGestureDetector(
              behavior: widget.hitTestBehavior,
              gestures: gestures,
              child: SizedBox.expand(child: widget.child),
            ),
          );
        },
      ),
    );
  }

  void _markGestureIdle() {
    _gestureActive = false;
    _cursor.value = MouseCursor.defer;
  }

  void _onGestureEnd(DragEndDetails details) {
    _markGestureIdle();
  }

  void _onGestureStart(DragStartDetails details) {
    _gestureActive = true;
    widget.onInteractionStart?.call();
  }

  bool _checkMoveAllowed(Offset globalPosition) {
    if (!widget.enabled) return false;
    return resizeDirectionAt(globalPosition) == null;
  }

  void _updateCursor(Offset globalPosition) {
    final direction = resizeDirectionAt(globalPosition);
    _cursor.value = direction?.cursor ?? MouseCursor.defer;
  }
}

mixin _ResizeZoneDeterminer<T extends StatefulWidget> on State<T> {
  bool get resizable;
  double get threshold;

  final Map<ResizeDirection, Rect> _resizeZones = {};

  Size? _size;

  ResizeDirection? resizeDirectionAt(Offset globalPosition) {
    _computeZones();

    if (!resizable || _resizeZones.isEmpty) return null;

    final localPosition = _globalToLocal(globalPosition);

    final result = <ResizeDirection>{};

    for (final entry in _resizeZones.entries) {
      if (entry.value.contains(localPosition)) {
        result.add(entry.key);
      }
    }

    if (result.contains(ResizeDirection.left) && result.contains(ResizeDirection.up)) {
      return ResizeDirection.topLeft;
    }

    if (result.contains(ResizeDirection.left) && result.contains(ResizeDirection.down)) {
      return ResizeDirection.bottomLeft;
    }

    if (result.contains(ResizeDirection.right) && result.contains(ResizeDirection.up)) {
      return ResizeDirection.topRight;
    }

    if (result.contains(ResizeDirection.right) && result.contains(ResizeDirection.down)) {
      return ResizeDirection.bottomRight;
    }

    return result.isNotEmpty ? result.first : null;
  }

  void _computeZones() {
    if (!resizable || !mounted) {
      _resizeZones.clear();
      return;
    }

    final size = context.size;
    if (size != null && size != _size) {
      _resizeZones
        ..clear()
        ..addAll(
          {
            ResizeDirection.left: Offset.zero & Size(threshold, size.height),
            ResizeDirection.up: Offset.zero & Size(size.width, threshold),
            ResizeDirection.down: Offset(0, size.height - threshold) & Size(size.width, threshold),
            ResizeDirection.right: Offset(size.width - threshold, 0) & Size(threshold, size.height),
          },
        );
    }
  }

  Offset _globalToLocal(Offset globalPosition) {
    final renderObject = context.findRenderObject();
    if (renderObject is RenderBox) {
      return renderObject.globalToLocal(globalPosition);
    }

    return Offset.zero;
  }

  @override
  void dispose() {
    _size = null;
    _resizeZones.clear();
    super.dispose();
  }
}

extension on ResizeDirection {
  MouseCursor get cursor {
    switch (this) {
      case ResizeDirection.up || ResizeDirection.down:
        return SystemMouseCursors.resizeUpDown;
      case ResizeDirection.left || ResizeDirection.right:
        return SystemMouseCursors.resizeLeftRight;
      case ResizeDirection.topLeft:
        return SystemMouseCursors.resizeUpLeftDownRight;
      case ResizeDirection.bottomRight:
        return SystemMouseCursors.resizeUpLeftDownRight;
      case ResizeDirection.topRight:
        return SystemMouseCursors.resizeUpRightDownLeft;
      case ResizeDirection.bottomLeft:
        return SystemMouseCursors.resizeUpRightDownLeft;
    }
  }
}
