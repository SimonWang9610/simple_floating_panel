import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:simple_floating_panel/simple_floating_panel.dart';

import '../panel_test_helpers.dart';

void main() {
  group('Panel factory master/slave behavior', () {
    test('Panel() creates MasterPanel when masterId is not provided', () {
      final panel = Panel(id: 'm1', builder: (_, __) => const SizedBox());

      expect(panel, isA<MasterPanel>());
      expect(panel, isNot(isA<SlavePanel>()));
    });

    test('Panel() creates SlavePanel when masterId is provided', () {
      final panel = Panel(id: 's1', masterId: 'm1', builder: (_, __) => const SizedBox());

      expect(panel, isA<SlavePanel>());
      expect((panel as SlavePanel).masterId, 'm1');
    });
  });

  group('PanelEntry factory and relation operations', () {
    late _DelegateNoop delegate;
    late PanelViewController viewController;

    setUp(() {
      delegate = _DelegateNoop();
      viewController = PanelViewController(
        'panel',
        delegate: delegate,
        initialState: const PanelViewState(
          geometry: PanelGeometry(origin: Offset.zero, size: Size(120, 80)),
        ),
        initialConstraints: testConstraints(),
      );
    });

    test('PanelEntry() creates MasterPanelEntry when masterId is null', () {
      final entry = PanelEntry(id: 'm1', builder: (_, __) => const SizedBox(), controller: viewController);

      expect(entry, isA<MasterPanelEntry>());
      expect((entry as MasterPanelEntry).slaves, isEmpty);
    });

    test('PanelEntry() creates SlavePanelEntry when masterId is provided', () {
      final entry = PanelEntry(
        id: 's1',
        builder: (_, __) => const SizedBox(),
        controller: viewController,
        masterId: 'm1',
      );

      expect(entry, isA<SlavePanelEntry>());
      expect((entry as SlavePanelEntry).masterId, 'm1');
    });

    test('MasterPanelEntry.attach is immutable and idempotent', () {
      final master =
          PanelEntry(id: 'm1', builder: (_, __) => const SizedBox(), controller: viewController) as MasterPanelEntry;

      final withOne = master.attach('s1');
      final attachingDuplicate = withOne.attach('s1');

      expect(master.slaves, isEmpty);
      expect(withOne.slaves, ['s1']);
      expect(identical(attachingDuplicate, withOne), isTrue);
    });

    test('MasterPanelEntry.detach is immutable and idempotent', () {
      final master =
          (PanelEntry(id: 'm1', builder: (_, __) => const SizedBox(), controller: viewController) as MasterPanelEntry)
              .attach('s1')
              .attach('s2');

      final detached = master.detach('s1');
      final detachingUnknown = detached.detach('missing');

      expect(master.slaves, ['s1', 's2']);
      expect(detached.slaves, ['s2']);
      expect(identical(detachingUnknown, detached), isTrue);
    });

    tearDown(() {
      viewController.dispose();
    });
  });
}

final class _DelegateNoop implements PanelViewDelegate {
  @override
  PanelEntry? entryOf(Object panelId) => null;

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
}
