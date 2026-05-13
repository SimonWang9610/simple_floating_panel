import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:simple_floating_panel/simple_floating_panel.dart';
import 'package:simple_floating_panel/src/widgets/panel_entry_view.dart';

import '../panel_test_helpers.dart';

void main() {
  group('PanelEntryView + scopes', () {
    testWidgets('master entry exposes matching PanelEntryScope and PanelMasterScope', (tester) async {
      final entry = _buildEntry('master-1');

      Object? seenMasterId;
      Object? seenEntryId;
      PanelEntry? seenEntry;
      PanelViewController? seenController;

      final viewEntry = PanelEntry(
        id: entry.id,
        controller: entry.controller,
        builder: (context, controller) {
          seenMasterId = PanelMasterScope.of(context);
          seenEntryId = PanelEntryScope.ofId(context);
          seenEntry = PanelEntryScope.of(context);
          seenController = controller;
          return const Text('master');
        },
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 300,
              height: 200,
              child: PanelEntryView(entry: viewEntry),
            ),
          ),
        ),
      );

      expect(find.text('master'), findsOneWidget);
      expect(seenMasterId, 'master-1');
      expect(seenEntryId, 'master-1');
      expect(seenEntry, same(viewEntry));
      expect(seenController, same(viewEntry.controller));
    });

    testWidgets('slave entry exposes slave entry id and master id from scopes', (tester) async {
      final entry = _buildEntry('slave-1', masterId: 'master-1');

      Object? seenMasterId;
      Object? seenEntryId;

      final viewEntry = PanelEntry(
        id: entry.id,
        masterId: 'master-1',
        controller: entry.controller,
        builder: (context, _) {
          seenMasterId = PanelMasterScope.of(context);
          seenEntryId = PanelEntryScope.ofId(context);
          return const Text('slave');
        },
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 300,
              height: 200,
              child: PanelEntryView(entry: viewEntry),
            ),
          ),
        ),
      );

      expect(find.text('slave'), findsOneWidget);
      expect(seenMasterId, 'master-1');
      expect(seenEntryId, 'slave-1');
    });

    testWidgets('rebuilding with new entry updates PanelEntryScope values', (tester) async {
      final controller = _buildController('panel-a');

      PanelEntry makeEntry(Object id) {
        return PanelEntry(
          id: id,
          controller: controller,
          builder: (context, _) {
            final entryId = PanelEntryScope.ofId(context);
            final masterId = PanelMasterScope.of(context);
            return Text('entry:$entryId master:$masterId');
          },
        );
      }

      var entry = makeEntry('panel-a');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (_, setState) {
                return Column(
                  children: [
                    TextButton(
                      onPressed: () {
                        setState(() {
                          entry = makeEntry('panel-b');
                        });
                      },
                      child: const Text('swap'),
                    ),
                    SizedBox(
                      width: 300,
                      height: 200,
                      child: PanelEntryView(entry: entry),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      );

      expect(find.text('entry:panel-a master:panel-a'), findsOneWidget);

      await tester.tap(find.text('swap'));
      await tester.pumpAndSettle();

      expect(find.text('entry:panel-b master:panel-b'), findsOneWidget);
    });
  });
}

PanelEntry _buildEntry(Object id, {Object? masterId}) {
  return PanelEntry(
    id: id,
    masterId: masterId,
    controller: _buildController(id),
    builder: (_, __) => const SizedBox(),
  );
}

PanelViewController _buildController(Object id) {
  return PanelViewController(
    id,
    delegate: const _NoopDelegate(),
    initialState: const PanelViewState(
      title: 'Test Panel',
      geometry: PanelGeometry(origin: Offset.zero, size: Size(160, 120)),
    ),
    initialConstraints: testConstraints(),
  );
}

final class _NoopDelegate implements PanelViewDelegate {
  const _NoopDelegate();

  @override
  void onPanelClosed(Object panelId) {}

  @override
  void onPanelFocused(Object panelId) {}

  @override
  void onPanelMaximize(Object panelId) {}

  @override
  void onPanelMinimize(Object panelId) {}

  @override
  void onPanelRestore(Object panelId) {}

  @override
  PanelEntry? entryOf(Object panelId) => null;
}
