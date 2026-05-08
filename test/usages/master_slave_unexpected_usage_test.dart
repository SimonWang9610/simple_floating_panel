import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:simple_floating_panel/simple_floating_panel.dart';

import '../panel_test_helpers.dart';

void main() {
  group('Master/slave unexpected usage', () {
    testWidgets('opening slave without master throws StateError', (tester) async {
      final context = await pumpPanelAppAndGetContext(tester);
      final controller = PanelController(initialConstraints: testConstraints());

      expect(
        () => controller.open(
          context,
          Panel(
            id: 'orphan-slave',
            masterId: 'missing-master',
            builder: (_, __) => const Text('Orphan'),
          ),
        ),
        throwsA(isA<StateError>()),
      );

      controller.dispose();
    });

    testWidgets('using a slave id as masterId throws StateError', (tester) async {
      final context = await pumpPanelAppAndGetContext(tester);
      final controller = PanelController(initialConstraints: testConstraints());

      controller.open(context, buildPanel(id: 'master', text: 'Master'));
      controller.open(
        context,
        Panel(
          id: 'slave-1',
          masterId: 'master',
          builder: (_, __) => const Text('Slave 1'),
        ),
      );

      expect(
        () => controller.open(
          context,
          Panel(
            id: 'slave-2',
            masterId: 'slave-1',
            builder: (_, __) => const Text('Slave 2'),
          ),
        ),
        throwsA(isA<StateError>()),
      );

      controller.dispose();
    });

    testWidgets('PanelMasterScope.open throws outside panel scope', (tester) async {
      late BuildContext context;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (ctx) {
                context = ctx;
                return const SizedBox();
              },
            ),
          ),
        ),
      );

      expect(
        () => PanelMasterScope.open(
          context,
          (masterId) => Panel(id: 'x', masterId: masterId, builder: (_, __) => const SizedBox()),
        ),
        throwsA(isA<FlutterError>()),
      );
    });

    testWidgets('PanelScope.of and PanelMasterScope.of throw when scopes are absent', (tester) async {
      late BuildContext context;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (ctx) {
                context = ctx;
                return const SizedBox();
              },
            ),
          ),
        ),
      );

      expect(() => PanelScope.of(context), throwsA(isA<FlutterError>()));
      expect(() => PanelMasterScope.of(context), throwsA(isA<FlutterError>()));
      expect(PanelScope.maybeOf(context), isNull);
      expect(PanelMasterScope.maybeOf(context), isNull);
    });
  });
}
