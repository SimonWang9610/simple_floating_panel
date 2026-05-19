import 'package:simple_floating_panel/simple_floating_panel.dart';

typedef PanelViewControllerCreator = PanelViewController Function(Panel panel);

final class PanelRegistrar {
  final Map<Object, PanelEntry> _panels = {};

  PanelRegistrar();

  bool get isEmpty => _panels.isEmpty;

  Iterable<PanelEntry> get panels => _panels.values;

  PanelEntry register(Panel panel, {required PanelViewControllerCreator viewControllerCreator}) {
    switch (panel) {
      case MasterPanel m:
        return _registerMasterPanel(m, viewControllerCreator);
      case SlavePanel s:
        return _registerSlavePanel(s, viewControllerCreator);
    }
  }

  List<Object> unregister(Object panelId) {
    final entry = _panels.remove(panelId);
    if (entry == null) return [];

    return switch (entry) {
      MasterPanelEntry m => _unregisterMasterPanel(m),
      SlavePanelEntry s => _unregisterSlavePanel(s),
    };
  }

  void unregisterAll() {
    final entries = _panels.values.toList();
    _panels.clear();

    for (final entry in entries) {
      entry.controller.dispose();
    }
  }

  PanelEntry? entryOf(Object panelId) {
    return _panels[panelId];
  }

  Object? masterOf(Object attachedPanelId) {
    final entry = _panels[attachedPanelId];

    return switch (entry) {
      SlavePanelEntry s => s.masterId,
      _ => null,
    };
  }

  List<Object> slavesOf(Object masterPanelId) {
    final entry = _panels[masterPanelId];

    return switch (entry) {
      MasterPanelEntry m => m.slaves,
      _ => [],
    };
  }

  PanelEntry _registerMasterPanel(MasterPanel panel, PanelViewControllerCreator viewControllerCreator) {
    if (_panels.containsKey(panel.id)) {
      throw StateError('A panel with id "${panel.id}" is already registered.');
    }

    final entry = PanelEntry(
      id: panel.id,
      builder: panel.builder,
      controller: viewControllerCreator(panel),
      addRepaintBoundary: panel.addRepaintBoundary,
    );

    _panels[panel.id] = entry;

    return entry;
  }

  List<Object> _unregisterMasterPanel(MasterPanelEntry master) {
    final slaves = master.slaves;

    for (final slaveId in slaves) {
      _panels.remove(slaveId)?.controller.dispose();
    }

    master.controller.dispose();

    return [master.id, ...slaves];
  }

  PanelEntry _registerSlavePanel(SlavePanel panel, PanelViewControllerCreator viewControllerCreator) {
    if (_panels.containsKey(panel.id)) {
      throw StateError('A panel with id "${panel.id}" is already registered.');
    }

    final masterEntry = _panels[panel.masterId];

    if (masterEntry == null) {
      throw StateError('Master panel with id ${panel.masterId} not found for attached panel ${panel.id}');
    }

    if (masterEntry is! MasterPanelEntry) {
      throw StateError('Panel with id ${panel.masterId} is not a master panel for attached panel ${panel.id}');
    }

    final entry = PanelEntry(
      id: panel.id,
      builder: panel.builder,
      controller: viewControllerCreator(panel),
      addRepaintBoundary: panel.addRepaintBoundary,
      masterId: panel.masterId,
    );

    _panels[panel.id] = entry;
    _panels[panel.masterId] = masterEntry.attach(panel.id);

    return entry;
  }

  List<Object> _unregisterSlavePanel(SlavePanelEntry attached) {
    final masterEntry = _panels[attached.masterId];

    assert(
      masterEntry is MasterPanelEntry,
      'Master panel with id ${attached.masterId} not found for attached panel ${attached.id}',
    );

    if (masterEntry is MasterPanelEntry) {
      _panels[attached.masterId] = masterEntry.detach(attached.id);
    }

    attached.controller.dispose();

    return [attached.id];
  }
}
