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
        return _registerMasterPanel(m, viewControllerCreator(m));
      case AttachedPanel a:
        return _registerAttachedPanel(a, viewControllerCreator(a));
    }
  }

  List<Object> unregister(Object panelId) {
    final entry = _panels.remove(panelId);
    if (entry == null) return [];

    return switch (entry) {
      MasterPanelEntry m => _unregisterMasterPanel(m),
      AttachedPanelEntry a => _unregisterAttachedPanel(a),
    };
  }

  void unregisterAll() {
    for (final entry in _panels.values) {
      entry.controller.dispose();
    }

    _panels.clear();
  }

  PanelEntry? entryOf(Object panelId) {
    return _panels[panelId];
  }

  Object? masterOf(Object attachedPanelId) {
    final entry = _panels[attachedPanelId];

    return switch (entry) {
      AttachedPanelEntry a => a.masterId,
      _ => null,
    };
  }

  List<Object> attachedPanelsOf(Object masterPanelId) {
    final entry = _panels[masterPanelId];

    return switch (entry) {
      MasterPanelEntry m => m.attachedPanels,
      _ => [],
    };
  }

  PanelEntry _registerMasterPanel(MasterPanel panel, PanelViewController viewController) {
    if (_panels.containsKey(panel.id)) {
      throw StateError('A panel with id "${panel.id}" is already registered.');
    }

    final entry = MasterPanelEntry(
      id: panel.id,
      builder: panel.builder,
      controller: viewController,
      useBuiltInView: panel.useBuiltInView,
      addRepaintBoundary: panel.addRepaintBoundary,
    );

    _panels[panel.id] = entry;

    return entry;
  }

  List<Object> _unregisterMasterPanel(MasterPanelEntry master) {
    final attachedPanels = master.attachedPanels;

    for (final attachedPanelId in attachedPanels) {
      _panels.remove(attachedPanelId)?.controller.dispose();
    }

    master.controller.dispose();

    return [master.id, ...attachedPanels];
  }

  PanelEntry _registerAttachedPanel(AttachedPanel panel, PanelViewController viewController) {
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

    final entry = AttachedPanelEntry(
      id: panel.id,
      builder: panel.builder,
      controller: viewController,
      useBuiltInView: panel.useBuiltInView,
      addRepaintBoundary: panel.addRepaintBoundary,
      masterId: panel.masterId,
    );

    _panels[panel.id] = entry;
    _panels[panel.masterId] = masterEntry.attach(panel.id);

    return entry;
  }

  List<Object> _unregisterAttachedPanel(AttachedPanelEntry attached) {
    final masterEntry = _panels[attached.masterId];

    assert(masterEntry is MasterPanelEntry,
        'Master panel with id ${attached.masterId} not found for attached panel ${attached.id}');

    if (masterEntry is MasterPanelEntry) {
      _panels[attached.masterId] = masterEntry.detach(attached.id);
    }

    attached.controller.dispose();
    _panels.remove(attached.id);

    return [attached.id];
  }
}
