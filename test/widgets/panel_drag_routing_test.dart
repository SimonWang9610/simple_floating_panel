import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:simple_floating_panel/simple_floating_panel.dart';

import '../panel_test_helpers.dart';

void main() {
  group('panel drag gesture routing', () {
    testWidgets('drags on each panel\'s drag handle move only the dragged panel', (tester) async {
      final context = await pumpPanelAppAndGetContext(tester);
      final controller = PanelController(initialConstraints: testConstraints());

      Widget buildDragHandle(String id) => PanelMoveHandle(
            child: SizedBox.square(
              key: ValueKey('panel-handle-$id'),
              dimension: 60,
              child: ColoredBox(color: Colors.amber, child: Text('Handle $id')),
            ),
          );

      controller.open(
        context,
        Panel(
          id: 'a',
          initialSize: const Size(160, 120),
          maintainState: false,
          initialPosition: const Offset(40, 40),
          builder: (_, __) => Center(child: buildDragHandle('a')),
        ),
      );
      controller.open(
        context,
        Panel(
          id: 'b',
          initialSize: const Size(160, 120),
          maintainState: false,
          initialPosition: const Offset(320, 40),
          builder: (_, __) => Center(child: buildDragHandle('b')),
        ),
      );
      controller.open(
        context,
        Panel(
          id: 'c',
          initialSize: const Size(160, 120),
          maintainState: false,
          initialPosition: const Offset(600, 40),
          builder: (_, __) => Center(child: buildDragHandle('c')),
        ),
      );

      await tester.pumpAndSettle();

      expect(controller.focusedPanel, 'c');

      final panelA = _viewControllerOf(controller, 'a');
      final panelB = _viewControllerOf(controller, 'b');
      final panelC = _viewControllerOf(controller, 'c');

      Offset aOrigin = panelA.value.geometry.origin;
      Offset bOrigin = panelB.value.geometry.origin;
      Offset cOrigin = panelC.value.geometry.origin;

      await tester.drag(find.byKey(const ValueKey('panel-handle-a')), const Offset(30, 20));
      await tester.pumpAndSettle();

      expect(controller.focusedPanel, 'a');
      expect(panelA.value.geometry.origin.dx, greaterThan(aOrigin.dx));
      expect(panelA.value.geometry.origin.dy, greaterThan(aOrigin.dy));
      expect(panelB.value.geometry.origin, bOrigin);
      expect(panelC.value.geometry.origin, cOrigin);
      aOrigin = panelA.value.geometry.origin;

      await tester.drag(find.byKey(const ValueKey('panel-handle-b')), const Offset(-24, 18));
      await tester.pumpAndSettle();

      expect(controller.focusedPanel, 'b');
      expect(panelB.value.geometry.origin.dx, lessThan(bOrigin.dx));
      expect(panelB.value.geometry.origin.dy, greaterThan(bOrigin.dy));
      expect(panelA.value.geometry.origin, aOrigin);
      expect(panelC.value.geometry.origin, cOrigin);
      bOrigin = panelB.value.geometry.origin;

      await tester.drag(find.byKey(const ValueKey('panel-handle-c')), const Offset(16, 22));
      await tester.pumpAndSettle();

      expect(controller.focusedPanel, 'c');
      expect(panelC.value.geometry.origin.dx, greaterThan(cOrigin.dx));
      expect(panelC.value.geometry.origin.dy, greaterThan(cOrigin.dy));
      expect(panelA.value.geometry.origin, aOrigin);
      expect(panelB.value.geometry.origin, bOrigin);
      cOrigin = panelC.value.geometry.origin;

      await tester.drag(find.byKey(const ValueKey('panel-handle-a')), const Offset(-32, 24));
      await tester.pumpAndSettle();

      expect(controller.focusedPanel, 'a');
      expect(panelA.value.geometry.origin, isNot(aOrigin));
      expect(panelA.value.geometry.origin.dy, greaterThan(aOrigin.dy));
      expect(panelB.value.geometry.origin, bOrigin);
      expect(panelC.value.geometry.origin, cOrigin);

      controller.dispose();
    });

    testWidgets('drag on body without a drag handle does not move the panel', (tester) async {
      final context = await pumpPanelAppAndGetContext(tester);
      final controller = PanelController(initialConstraints: testConstraints());

      controller.open(
        context,
        Panel(
          id: 'a',
          initialSize: const Size(200, 200),
          maintainState: false,
          initialPosition: const Offset(60, 60),
          builder: (_, __) => Center(
            child: SizedBox.square(
              key: const ValueKey('plain-body'),
              dimension: 80,
              child: ColoredBox(color: Colors.green),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final panelA = _viewControllerOf(controller, 'a');
      final originBefore = panelA.value.geometry.origin;

      await tester.drag(find.byKey(const ValueKey('plain-body')), const Offset(40, 40));
      await tester.pumpAndSettle();

      expect(panelA.value.geometry.origin, originBefore, reason: 'no handle means body drags do not move the panel');

      controller.dispose();
    });

    testWidgets('vertical drag on a scrollable body scrolls the body and does not move the panel', (tester) async {
      final context = await pumpPanelAppAndGetContext(tester);
      final controller = PanelController(initialConstraints: testConstraints());
      final scrollController = ScrollController();

      controller.open(
        context,
        Panel(
          id: 'scroll',
          initialSize: const Size(200, 160),
          maintainState: false,
          initialPosition: const Offset(60, 60),
          builder: (_, __) => Column(
            children: [
              const PanelMoveHandle(
                child: SizedBox(
                  key: ValueKey('scroll-handle'),
                  height: 28,
                  child: ColoredBox(color: Colors.amber),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  key: const ValueKey('scroll-body'),
                  controller: scrollController,
                  child: Column(
                    children: [
                      for (int i = 0; i < 24; i++) SizedBox(height: 30, child: Text('row $i')),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );

      await tester.pumpAndSettle();

      final panel = _viewControllerOf(controller, 'scroll');
      final originBefore = panel.value.geometry.origin;

      await tester.drag(find.byKey(const ValueKey('scroll-body')), const Offset(0, -80));
      await tester.pumpAndSettle();

      expect(scrollController.offset, greaterThan(0));
      expect(panel.value.geometry.origin, originBefore, reason: 'scrolling the body must not move the panel');

      controller.dispose();
    });
  });
}

PanelViewController _viewControllerOf(PanelController controller, Object id) {
  return controller.orderedPanels.firstWhere((entry) => entry.id == id).controller;
}
