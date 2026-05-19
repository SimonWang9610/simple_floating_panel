import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:simple_floating_panel/simple_floating_panel.dart';

import '../panel_test_helpers.dart';

void main() {
  group('PanelResizeBorder', () {
    testWidgets('drag on bottom-right corner resizes the panel both ways', (tester) async {
      final context = await pumpPanelAppAndGetContext(tester);
      final controller = PanelController(initialConstraints: testConstraints());

      controller.open(
        context,
        buildPanel(
          id: 'p',
          text: 'Panel',
          initialPosition: const Offset(40, 40),
          size: const Size(240, 180),
        ),
      );
      await tester.pumpAndSettle();

      final view = _viewControllerOf(controller, 'p');
      final before = view.value.geometry;
      final borderRect = tester.getRect(find.byType(PanelResizeHandle));

      await tester.dragFrom(
        borderRect.bottomRight - const Offset(2, 2),
        const Offset(40, 30),
      );
      await tester.pumpAndSettle();

      expect(view.value.geometry.size.width, greaterThan(before.size.width));
      expect(view.value.geometry.size.height, greaterThan(before.size.height));

      controller.dispose();
    });

    testWidgets('top-left corner drag resizes from the origin', (tester) async {
      final context = await pumpPanelAppAndGetContext(tester);
      final controller = PanelController(initialConstraints: testConstraints());

      controller.open(
        context,
        buildPanel(
          id: 'p',
          text: 'Panel',
          initialPosition: const Offset(120, 120),
          size: const Size(240, 180),
        ),
      );
      await tester.pumpAndSettle();

      final view = _viewControllerOf(controller, 'p');
      final before = view.value.geometry;
      final borderRect = tester.getRect(find.byType(PanelResizeHandle));

      await tester.dragFrom(
        borderRect.topLeft + const Offset(2, 2),
        const Offset(-20, -15),
      );
      await tester.pumpAndSettle();

      expect(view.value.geometry.origin.dx, lessThan(before.origin.dx));
      expect(view.value.geometry.origin.dy, lessThan(before.origin.dy));
      expect(view.value.geometry.size.width, greaterThan(before.size.width));
      expect(view.value.geometry.size.height, greaterThan(before.size.height));

      controller.dispose();
    });

    testWidgets('vertical drag inside the body scrolls and does not resize the panel', (tester) async {
      final context = await pumpPanelAppAndGetContext(tester);
      final controller = PanelController(initialConstraints: testConstraints());
      final scrollController = ScrollController();

      controller.open(
        context,
        Panel(
          id: 'p',
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

      final view = _viewControllerOf(controller, 'p');
      final geoBefore = view.value.geometry;

      final body = tester.getRect(find.byKey(const ValueKey('scroll-body')));
      await tester.dragFrom(body.center, const Offset(0, -90));
      await tester.pumpAndSettle();

      expect(scrollController.offset, greaterThan(0));
      expect(view.value.geometry, geoBefore);

      controller.dispose();
    });
  });
}

PanelViewController _viewControllerOf(PanelController controller, Object id) {
  return controller.orderedPanels.firstWhere((entry) => entry.id == id).controller;
}
