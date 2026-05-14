import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:simple_floating_panel/simple_floating_panel.dart';

void main() {
  group('PanelGeometry', () {
    test('copyWith and move update geometry values', () {
      const geometry = PanelGeometry(origin: Offset(10, 20), size: Size(200, 150));

      final copied = geometry.copyWith(size: const Size(240, 180));
      final moved = geometry.move(15, -5);

      expect(copied.origin, const Offset(10, 20));
      expect(copied.size, const Size(240, 180));
      expect(moved.origin, const Offset(25, 15));
      expect(moved.size, const Size(200, 150));
    });

    test('resize from bottomRight increases width and height', () {
      const geometry = PanelGeometry(origin: Offset(20, 30), size: Size(300, 200));

      final resized = geometry.resize(const Offset(40, 25), ResizeDirection.bottomRight);

      expect(resized.origin, const Offset(20, 30));
      expect(resized.size, const Size(340, 225));
    });

    test('resize from topLeft updates origin and decreases size', () {
      const geometry = PanelGeometry(origin: Offset(100, 80), size: Size(320, 240));

      final resized = geometry.resize(const Offset(20, 30), ResizeDirection.topLeft);

      expect(resized.origin, const Offset(120, 110));
      expect(resized.size, const Size(300, 210));
    });

    test('resize with right edge only updates width', () {
      const geometry = PanelGeometry(origin: Offset(40, 50), size: Size(180, 120));

      final resized = geometry.resize(const Offset(25, 100), ResizeDirection.right);

      expect(resized.origin, const Offset(40, 50));
      expect(resized.size, const Size(205, 120));
    });

    test('resize with constraints clamps size from left and preserves right edge', () {
      const geometry = PanelGeometry(origin: Offset(50, 40), size: Size(200, 120));
      final constraints = PanelConstraints(
        minSize: Size(100, 80),
        maxSize: Size(260, 220),
      );

      final resized = geometry.resize(
        const Offset(180, 0),
        ResizeDirection.left,
        constraints: constraints,
      );

      expect(resized.size, const Size(100, 120));
      expect(resized.origin, const Offset(150, 40));
      expect(resized.origin.dx + resized.size.width, 250);
    });

    test('resize with constraints clamps size from top and preserves bottom edge', () {
      const geometry = PanelGeometry(origin: Offset(60, 50), size: Size(180, 140));
      final constraints = PanelConstraints(
        minSize: Size(100, 80),
        maxSize: Size(260, 220),
      );

      final resized = geometry.resize(
        const Offset(0, 120),
        ResizeDirection.up,
        constraints: constraints,
      );

      expect(resized.size, const Size(180, 80));
      expect(resized.origin, const Offset(60, 110));
      expect(resized.origin.dy + resized.size.height, 190);
    });
  });
}
