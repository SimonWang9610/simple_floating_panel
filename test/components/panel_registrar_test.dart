import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:simple_floating_panel/simple_floating_panel.dart';
import 'package:simple_floating_panel/src/components/panel_registrar.dart';

void main() {
  group('PanelRegistrar', () {
    late PanelRegistrar registrar;
    late _DelegateSpy delegate;

    setUp(() {
      registrar = PanelRegistrar();
      delegate = _DelegateSpy();
    });

    test('registers master panel as MasterPanelEntry', () {
      final panel = Panel(id: 'master-1', builder: (_, __) => const SizedBox());

      final entry = registrar.register(panel, viewControllerCreator: (p) => _controllerFor(p.id, delegate));

      expect(entry, isA<MasterPanelEntry>());
      expect(registrar.entryOf('master-1'), isA<MasterPanelEntry>());
      expect(registrar.masterOf('master-1'), isNull);
      expect(registrar.slavesOf('master-1'), isEmpty);
      expect(registrar.panels.map((entry) => entry.id), ['master-1']);
      expect(registrar.isEmpty, isFalse);
    });

    test('registering duplicate panel id throws StateError', () {
      final panel = Panel(id: 'dup', builder: (_, __) => const SizedBox());

      registrar.register(panel, viewControllerCreator: (p) => _controllerFor(p.id, delegate));

      expect(
        () => registrar.register(panel, viewControllerCreator: (p) => _controllerFor(p.id, delegate)),
        throwsA(isA<StateError>()),
      );
    });

    test('registering slave without existing master throws StateError', () {
      final slave = Panel(id: 'slave-orphan', masterId: 'missing-master', builder: (_, __) => const SizedBox());

      expect(
        () => registrar.register(slave, viewControllerCreator: (p) => _controllerFor(p.id, delegate)),
        throwsA(isA<StateError>()),
      );
    });

    test('registering slave using another slave as master throws StateError', () {
      final master = Panel(id: 'master-1', builder: (_, __) => const SizedBox());
      final slaveA = Panel(id: 'slave-a', masterId: 'master-1', builder: (_, __) => const SizedBox());
      final slaveB = Panel(id: 'slave-b', masterId: 'slave-a', builder: (_, __) => const SizedBox());

      registrar.register(master, viewControllerCreator: (p) => _controllerFor(p.id, delegate));
      registrar.register(slaveA, viewControllerCreator: (p) => _controllerFor(p.id, delegate));

      expect(
        () => registrar.register(slaveB, viewControllerCreator: (p) => _controllerFor(p.id, delegate)),
        throwsA(isA<StateError>()),
      );
    });

    test('registering slave attaches it to master and reflects relation lookups', () {
      final master = Panel(id: 'master-1', builder: (_, __) => const SizedBox());
      final slave = Panel(id: 'slave-1', masterId: 'master-1', builder: (_, __) => const SizedBox());

      registrar.register(master, viewControllerCreator: (p) => _controllerFor(p.id, delegate));
      final slaveEntry = registrar.register(slave, viewControllerCreator: (p) => _controllerFor(p.id, delegate));

      final masterEntry = registrar.entryOf('master-1') as MasterPanelEntry;

      expect(slaveEntry, isA<SlavePanelEntry>());
      expect((slaveEntry as SlavePanelEntry).masterId, 'master-1');
      expect(masterEntry.slaves, ['slave-1']);
      expect(registrar.masterOf('slave-1'), 'master-1');
      expect(registrar.slavesOf('master-1'), ['slave-1']);
    });

    test('unregistering slave detaches from master and disposes only slave', () {
      final master = Panel(id: 'master-1', builder: (_, __) => const SizedBox());
      final slave = Panel(id: 'slave-1', masterId: 'master-1', builder: (_, __) => const SizedBox());

      registrar.register(master, viewControllerCreator: (p) => _controllerFor(p.id, delegate));
      registrar.register(slave, viewControllerCreator: (p) => _controllerFor(p.id, delegate));

      final removed = registrar.unregister('slave-1');

      expect(removed, ['slave-1']);
      expect(registrar.entryOf('slave-1'), isNull);
      expect((registrar.entryOf('master-1') as MasterPanelEntry).slaves, isEmpty);
      expect(delegate.closed.where((id) => id == 'slave-1').length, 1);
      expect(delegate.closed.where((id) => id == 'master-1'), isEmpty);
    });

    test('unregistering master cascades to slaves and disposes all', () {
      final master = Panel(id: 'master-1', builder: (_, __) => const SizedBox());
      final slaveA = Panel(id: 'slave-a', masterId: 'master-1', builder: (_, __) => const SizedBox());
      final slaveB = Panel(id: 'slave-b', masterId: 'master-1', builder: (_, __) => const SizedBox());

      registrar.register(master, viewControllerCreator: (p) => _controllerFor(p.id, delegate));
      registrar.register(slaveA, viewControllerCreator: (p) => _controllerFor(p.id, delegate));
      registrar.register(slaveB, viewControllerCreator: (p) => _controllerFor(p.id, delegate));

      final removed = registrar.unregister('master-1');

      expect(removed, ['master-1', 'slave-a', 'slave-b']);
      expect(registrar.entryOf('master-1'), isNull);
      expect(registrar.entryOf('slave-a'), isNull);
      expect(registrar.entryOf('slave-b'), isNull);
      expect(registrar.isEmpty, isTrue);
      expect(delegate.closed.toSet(), {'master-1', 'slave-a', 'slave-b'});
    });

    test('unregister unknown id is no-op', () {
      expect(registrar.unregister('missing'), isEmpty);
    });

    test('unregisterAll clears all panels and disposes every controller', () {
      final masterA = Panel(id: 'master-a', builder: (_, __) => const SizedBox());
      final slaveA = Panel(id: 'slave-a', masterId: 'master-a', builder: (_, __) => const SizedBox());
      final masterB = Panel(id: 'master-b', builder: (_, __) => const SizedBox());

      registrar.register(masterA, viewControllerCreator: (p) => _controllerFor(p.id, delegate));
      registrar.register(slaveA, viewControllerCreator: (p) => _controllerFor(p.id, delegate));
      registrar.register(masterB, viewControllerCreator: (p) => _controllerFor(p.id, delegate));

      registrar.unregisterAll();

      expect(registrar.isEmpty, isTrue);
      expect(registrar.panels, isEmpty);
      expect(delegate.closed.toSet(), {'master-a', 'slave-a', 'master-b'});
    });
  });
}

PanelViewController _controllerFor(Object panelId, PanelViewDelegate delegate) {
  return PanelViewController(
    panelId,
    delegate: delegate,
    initialState: const PanelViewState(
      geometry: PanelGeometry(origin: Offset.zero, size: Size(120, 80)),
    ),
    initialConstraints: PanelConstraints(
      minSize: Size(80, 60),
      maxSize: Size(800, 600),
      origin: Offset.zero,
      edgeVisibleThreshold: 20,
    ),
  );
}

final class _DelegateSpy implements PanelViewDelegate {
  final List<Object> closed = [];

  @override
  PanelEntry? entryOf(Object panelId) => null;

  @override
  void onPanelClosed(Object panelId) {
    closed.add(panelId);
  }

  @override
  void onPanelFocused(Object panelId) {}

  @override
  void onPanelMaximize(Object panelId) {}

  @override
  void onPanelMinimize(Object panelId) {}

  @override
  void onPanelRestore(Object panelId) {}
}
