import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:simple_floating_panel/simple_floating_panel.dart';

import '../panel_test_helpers.dart';

void main() {
  group('Master and slave usage', () {
    testWidgets('opening a slave attaches it to master and updates master entry', (tester) async {
      final context = await pumpPanelAppAndGetContext(tester);
      final controller = PanelController(initialConstraints: testConstraints());

      controller.open(context, buildPanel(id: 'master-1', text: 'Master 1'));
      controller.open(context, Panel(id: 'slave-1', masterId: 'master-1', builder: (_, __) => const Text('Slave 1')));
      await tester.pumpAndSettle();

      final master = controller.panels.firstWhere((entry) => entry.id == 'master-1') as MasterPanelEntry;
      final slave = controller.panels.firstWhere((entry) => entry.id == 'slave-1') as SlavePanelEntry;

      expect(slave.masterId, 'master-1');
      expect(master.slaves, ['slave-1']);
      expect(find.text('Master 1'), findsOneWidget);
      expect(find.text('Slave 1'), findsOneWidget);

      controller.dispose();
    });

    testWidgets('closing a slave detaches it from master but keeps master alive', (tester) async {
      final context = await pumpPanelAppAndGetContext(tester);
      final controller = PanelController(initialConstraints: testConstraints());

      controller.open(context, buildPanel(id: 'master-1', text: 'Master 1'));
      controller.open(context, Panel(id: 'slave-1', masterId: 'master-1', builder: (_, __) => const Text('Slave 1')));
      await tester.pumpAndSettle();

      controller.close('slave-1');
      await tester.pumpAndSettle();

      final master = controller.panels.single as MasterPanelEntry;
      expect(master.id, 'master-1');
      expect(master.slaves, isEmpty);
      expect(find.text('Master 1'), findsOneWidget);
      expect(find.text('Slave 1'), findsNothing);

      controller.dispose();
    });

    testWidgets('closing a master cascades and closes all of its slaves', (tester) async {
      final context = await pumpPanelAppAndGetContext(tester);
      final controller = PanelController(initialConstraints: testConstraints());

      controller.open(context, buildPanel(id: 'master-1', text: 'Master 1'));
      controller.open(context, Panel(id: 'slave-1', masterId: 'master-1', builder: (_, __) => const Text('Slave 1')));
      controller.open(context, Panel(id: 'slave-2', masterId: 'master-1', builder: (_, __) => const Text('Slave 2')));
      await tester.pumpAndSettle();

      controller.close('master-1');
      await tester.pumpAndSettle();

      expect(controller.hasPanels, isFalse);
      expect(controller.panels, isEmpty);
      expect(find.text('Master 1'), findsNothing);
      expect(find.text('Slave 1'), findsNothing);
      expect(find.text('Slave 2'), findsNothing);

      controller.dispose();
    });

    testWidgets('PanelMasterScope.open creates slave using current master id', (tester) async {
      final context = await pumpPanelAppAndGetContext(tester);
      final controller = PanelController(initialConstraints: testConstraints());
      final seenMasterBySlave = ValueNotifier<Object?>(null);

      controller.open(
        context,
        Panel(
          id: 'master-with-button',
          builder: (ctx, __) {
            return TextButton(
              onPressed: () {
                PanelMasterScope.open(ctx, (masterId) {
                  return Panel(
                    id: 'slave-created-by-scope',
                    masterId: masterId,
                    builder: (_, __) {
                      return Builder(
                        builder: (scopeContext) {
                          seenMasterBySlave.value = PanelMasterScope.of(scopeContext);
                          return const Text('Slave From Scope');
                        },
                      );
                    },
                  );
                });
              },
              child: const Text('Open Slave'),
            );
          },
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Open Slave'));
      await tester.pumpAndSettle();

      final slaveEntry = controller.panels.firstWhere((entry) => entry.id == 'slave-created-by-scope');

      expect(slaveEntry, isA<SlavePanelEntry>());
      expect((slaveEntry as SlavePanelEntry).masterId, 'master-with-button');
      expect(seenMasterBySlave.value, 'master-with-button');
      expect(find.text('Slave From Scope'), findsOneWidget);

      seenMasterBySlave.dispose();
      controller.dispose();
    });
  });
}
