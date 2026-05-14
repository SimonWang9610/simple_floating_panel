import 'package:flutter/gestures.dart';
import 'package:simple_floating_panel/simple_floating_panel.dart';

typedef PanelResizeDirectionChecker = ResizeDirection? Function(Offset globalPosition);
typedef PanelMoveChecker = bool Function(Offset globalPosition);

final class PanelResizeGestureRecognizer extends PanGestureRecognizer {
  final PanelResizeDirectionChecker directionChecker;

  PanelResizeGestureRecognizer({required this.directionChecker, super.debugOwner});

  final Map<int, ResizeDirection> _directionsByPointer = {};

  ResizeDirection? _activeDirection;

  ResizeDirection? get activeDirection => _activeDirection;

  @override
  void addAllowedPointer(PointerDownEvent event) {
    final direction = directionChecker(event.position);
    if (direction == null) {
      return;
    }
    _directionsByPointer[event.pointer] = direction;
    super.addAllowedPointer(event);
  }

  @override
  void acceptGesture(int pointer) {
    _activeDirection = _directionsByPointer[pointer];
    super.acceptGesture(pointer);
  }

  @override
  void handleEvent(PointerEvent event) {
    if (!_directionsByPointer.containsKey(event.pointer)) {
      return;
    }

    super.handleEvent(event);

    if (event is PointerUpEvent || event is PointerCancelEvent) {
      _directionsByPointer.remove(event.pointer);
      _activeDirection = null;
    }
  }

  @override
  void didStopTrackingLastPointer(int pointer) {
    _directionsByPointer.remove(pointer);
    _activeDirection = null;

    super.didStopTrackingLastPointer(pointer);
  }
}

final class PanelMoveGestureRecognizer extends PanGestureRecognizer {
  final PanelMoveChecker moveChecker;

  PanelMoveGestureRecognizer({required this.moveChecker, super.debugOwner});

  final Map<int, bool> _allowedPointers = {};

  @override
  void addAllowedPointer(PointerDownEvent event) {
    final allowed = moveChecker(event.position);
    _allowedPointers[event.pointer] = allowed;

    if (allowed) {
      super.addAllowedPointer(event);
    }
  }

  @override
  void handleEvent(PointerEvent event) {
    if (_allowedPointers[event.pointer] != true) {
      return;
    }

    super.handleEvent(event);

    if (event is PointerUpEvent || event is PointerCancelEvent) {
      _allowedPointers.remove(event.pointer);
    }
  }

  @override
  void didStopTrackingLastPointer(int pointer) {
    _allowedPointers.remove(pointer);
    super.didStopTrackingLastPointer(pointer);
  }
}
