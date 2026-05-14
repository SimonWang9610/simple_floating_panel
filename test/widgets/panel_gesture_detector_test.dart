import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:simple_floating_panel/simple_floating_panel.dart';

void main() {
  group('PanelGestureDetector', () {
    testWidgets('center drag triggers move callback instead of resize', (tester) async {
      var moveUpdates = 0;
      final resizeDirections = <ResizeDirection>[];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 220,
                height: 140,
                child: PanelGestureDetector(
                  onMoveUpdate: (_) => moveUpdates++,
                  onResizeUpdate: (_, direction) => resizeDirections.add(direction),
                  child: const SizedBox.shrink(),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final rect = tester.getRect(find.byType(PanelGestureDetector));
      await tester.dragFrom(rect.center, const Offset(24, 16));
      await tester.pumpAndSettle();

      expect(moveUpdates, greaterThan(0));
      expect(resizeDirections, isEmpty);
    });

    testWidgets('corner drag triggers resize callback with corner direction', (tester) async {
      var moveUpdates = 0;
      final resizeDirections = <ResizeDirection>[];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 220,
                height: 140,
                child: PanelGestureDetector(
                  resizeThreshold: 8,
                  onMoveUpdate: (_) => moveUpdates++,
                  onResizeUpdate: (_, direction) => resizeDirections.add(direction),
                  child: const SizedBox.shrink(),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final rect = tester.getRect(find.byType(PanelGestureDetector));
      final topLeft = rect.topLeft + const Offset(2, 2);
      await tester.dragFrom(topLeft, const Offset(20, 14));
      await tester.pumpAndSettle();

      expect(resizeDirections, isNotEmpty);
      expect(resizeDirections.first, ResizeDirection.topLeft);
      expect(moveUpdates, 0);
    });

    testWidgets('edge drag falls back to move when resizable is false', (tester) async {
      var moveUpdates = 0;
      var resizeUpdates = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 220,
                height: 140,
                child: PanelGestureDetector(
                  resizable: false,
                  onMoveUpdate: (_) => moveUpdates++,
                  onResizeUpdate: (_, __) => resizeUpdates++,
                  child: const SizedBox.shrink(),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final rect = tester.getRect(find.byType(PanelGestureDetector));
      final edgePoint = Offset(rect.right - 2, rect.center.dy);

      await tester.dragFrom(edgePoint, const Offset(20, 0));
      await tester.pumpAndSettle();

      expect(moveUpdates, greaterThan(0));
      expect(resizeUpdates, 0);
    });
  });
}
