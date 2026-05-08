import 'package:flutter_test/flutter_test.dart';
import 'package:simple_floating_panel/simple_floating_panel.dart';

import '../panel_test_helpers.dart';

void main() {
  group('Master-only usage', () {
    testWidgets('opening a panel without masterId creates a master entry', (tester) async {
      final context = await pumpPanelAppAndGetContext(tester);
      final controller = PanelController(initialConstraints: testConstraints());

      controller.open(context, buildPanel(id: 'master-1', text: 'Master 1'));
      await tester.pumpAndSettle();

      final entry = controller.panels.single;
      expect(entry, isA<MasterPanelEntry>());
      expect((entry as MasterPanelEntry).slaves, isEmpty);
      expect(controller.focusedPanel, 'master-1');

      controller.dispose();
    });

    testWidgets('masters are independent and closing one does not close others', (tester) async {
      final context = await pumpPanelAppAndGetContext(tester);
      final controller = PanelController(initialConstraints: testConstraints());

      controller.open(context, buildPanel(id: 'master-a', text: 'Master A'));
      controller.open(context, buildPanel(id: 'master-b', text: 'Master B'));
      await tester.pumpAndSettle();

      controller.close('master-a');
      await tester.pumpAndSettle();

      expect(controller.panels.map((entry) => entry.id).toList(), ['master-b']);
      expect(controller.hasPanels, isTrue);
      expect(find.text('Master A'), findsNothing);
      expect(find.text('Master B'), findsOneWidget);

      controller.dispose();
    });
  });
}
