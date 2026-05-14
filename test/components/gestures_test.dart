import 'package:flutter/gestures.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:simple_floating_panel/simple_floating_panel.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('PanelResizeGestureRecognizer', () {
    testWidgets('tracks and clears active direction per pointer lifecycle', (tester) async {
      final recognizer = PanelResizeGestureRecognizer(
        directionChecker: (_) => ResizeDirection.topRight,
      );

      recognizer.addAllowedPointer(const PointerDownEvent(pointer: 1, position: Offset(10, 10)));
      recognizer.acceptGesture(1);

      expect(recognizer.activeDirection, ResizeDirection.topRight);

      recognizer.handleEvent(const PointerUpEvent(pointer: 1, position: Offset(10, 10)));
      expect(recognizer.activeDirection, isNull);

      recognizer.dispose();
    });

    testWidgets('does not activate when checker rejects pointer', (tester) async {
      final recognizer = PanelResizeGestureRecognizer(
        directionChecker: (_) => null,
      );

      recognizer.addAllowedPointer(const PointerDownEvent(pointer: 2, position: Offset(20, 20)));
      recognizer.handleEvent(const PointerUpEvent(pointer: 2, position: Offset(20, 20)));

      expect(recognizer.activeDirection, isNull);

      recognizer.dispose();
    });

    testWidgets('didStopTrackingLastPointer clears active direction', (tester) async {
      final recognizer = PanelResizeGestureRecognizer(
        directionChecker: (_) => ResizeDirection.left,
      );

      recognizer.addAllowedPointer(const PointerDownEvent(pointer: 3, position: Offset(30, 30)));
      recognizer.acceptGesture(3);
      expect(recognizer.activeDirection, ResizeDirection.left);

      recognizer.didStopTrackingLastPointer(3);
      expect(recognizer.activeDirection, isNull);

      recognizer.dispose();
    });
  });

  group('PanelMoveGestureRecognizer', () {
    testWidgets('evaluates move checker per pointer and handles events safely', (tester) async {
      var checks = 0;
      final recognizer = PanelMoveGestureRecognizer(
        moveChecker: (position) {
          checks++;
          return position.dx > 0;
        },
      );

      recognizer.addAllowedPointer(const PointerDownEvent(pointer: 10, position: Offset(-1, 0)));
      recognizer.handleEvent(const PointerMoveEvent(pointer: 10, position: Offset(-2, 0), delta: Offset(-1, 0)));
      recognizer.handleEvent(const PointerUpEvent(pointer: 10, position: Offset(-2, 0)));

      recognizer.addAllowedPointer(const PointerDownEvent(pointer: 11, position: Offset(1, 0)));
      recognizer.acceptGesture(11);
      recognizer.handleEvent(const PointerMoveEvent(pointer: 11, position: Offset(6, 0), delta: Offset(5, 0)));
      recognizer.handleEvent(const PointerUpEvent(pointer: 11, position: Offset(6, 0)));

      expect(checks, 2);

      recognizer.dispose();
    });
  });
}
