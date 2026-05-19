import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:simple_floating_panel/simple_floating_panel.dart';

import '../panel_test_helpers.dart';

void main() {
  group('panel resize routing', () {
    testWidgets('bottom-right resize works even when panel child is small', (tester) async {
      final context = await pumpPanelAppAndGetContext(tester);
      final controller = PanelController(initialConstraints: testConstraints());

      controller.open(
        context,
        buildPanel(
          id: 'panel',
          text: 'Panel',
          initialPosition: const Offset(120, 80),
          size: const Size(220, 140),
        ),
      );
      await tester.pumpAndSettle();

      final viewController = _viewControllerOf(controller, 'panel');
      final before = viewController.value.geometry;
      final detectorRect = tester.getRect(find.byType(PanelResizeHandle));

      final start = Offset(
        detectorRect.right - 2,
        detectorRect.bottom - 2,
      );

      await tester.dragFrom(start, const Offset(30, 20));
      await tester.pumpAndSettle();

      final after = viewController.value.geometry;
      expect(after.size.width, greaterThan(before.size.width));
      expect(after.size.height, greaterThan(before.size.height));

      controller.dispose();
    });

    testWidgets('right edge drag resizes width from the right side', (tester) async {
      final context = await pumpPanelAppAndGetContext(tester);
      final controller = PanelController(initialConstraints: testConstraints());

      controller.open(
        context,
        buildPanel(
          id: 'panel',
          text: 'Panel',
          initialPosition: const Offset(160, 120),
          size: const Size(240, 180),
        ),
      );
      await tester.pumpAndSettle();

      final viewController = _viewControllerOf(controller, 'panel');
      final before = viewController.value.geometry;
      final detectorRect = tester.getRect(find.byType(PanelResizeHandle));

      final start = Offset(
        detectorRect.right - 2,
        detectorRect.center.dy,
      );

      await tester.dragFrom(start, const Offset(24, 0));
      await tester.pumpAndSettle();

      final after = viewController.value.geometry;
      expect(after.origin.dx, before.origin.dx);
      expect(after.size.width, greaterThan(before.size.width));

      controller.dispose();
    });

    testWidgets('scrollable body extending to the edge still scrolls (no resize border interference)', (tester) async {
      final context = await pumpPanelAppAndGetContext(tester);
      final controller = PanelController(initialConstraints: testConstraints());
      final scrollController = ScrollController();

      controller.open(
        context,
        Panel(
          id: 'scroll',
          initialPosition: const Offset(60, 60),
          initialSize: const Size(200, 160),
          maintainState: false,
          builder: (_, __) => SingleChildScrollView(
            key: const ValueKey('scroll-body'),
            controller: scrollController,
            child: Column(
              children: [for (int i = 0; i < 24; i++) SizedBox(height: 30, child: Text('row $i'))],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final panel = _viewControllerOf(controller, 'scroll');
      final originBefore = panel.value.geometry.origin;
      final sizeBefore = panel.value.geometry.size;

      // Drag from somewhere clearly inside the body, away from the 5px border.
      final scrollableRect = tester.getRect(find.byKey(const ValueKey('scroll-body')));
      await tester.dragFrom(scrollableRect.center, const Offset(0, -80));
      await tester.pumpAndSettle();

      expect(scrollController.offset, greaterThan(0));
      expect(panel.value.geometry.origin, originBefore);
      expect(panel.value.geometry.size, sizeBefore);

      controller.dispose();
    });
  });
}

PanelViewController _viewControllerOf(PanelController controller, Object id) {
  return controller.orderedPanels.firstWhere((entry) => entry.id == id).controller;
}
