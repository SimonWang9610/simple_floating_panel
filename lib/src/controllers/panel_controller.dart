import 'package:flutter/widgets.dart';
import 'package:simple_floating_panel/simple_floating_panel.dart';

import '../components/z_index_manager.dart';
import '../components/panel_registrar.dart';
import 'mixins.dart';

abstract base class PanelController extends ChangeNotifier {
  /// Whether this controller uses an overlay to display panels.
  /// If false, the panels are expected to be displayed in a [Route] above the current context.
  /// If true, the controller will ensure that panels are displayed in an [Overlay] above the current context,
  /// which will ensure panels are not overridden by other routes.
  ///
  /// Default to false.
  final bool useOverlay;

  PanelConstraints get constraints;
  set constraints(PanelConstraints newConstraints);

  PanelConfig get config;
  set config(PanelConfig newConfig);

  void open(BuildContext context, Panel panel);
  void close(Object panelId);
  void closeAll();
  void bringToFront(Object panelId);

  /// Checks if the panel with the given id is currently visible (i.e., not minimized).
  bool isVisible(Object panelId);

  PanelEntry? entryOf(Object panelId);

  PanelMode get mode;
  set mode(PanelMode newMode);

  /// Returns the id of the currently focused panel, or null if no panel is focused.
  Object? get focusedPanel;

  /// Returns panels in z-order (from back to front).
  Iterable<PanelEntry> get orderedPanels;

  /// Returns panels in the order they were added, regardless of z-order.
  Iterable<PanelEntry> get panels;

  /// Whether there is at least one panel currently open.
  bool get hasPanels;

  PanelController._(this.useOverlay);

  factory PanelController({
    /// [PanelConstraints] defines the boundary of the entire panel system,
    /// which is used for calculating/restricting panel positions and sizes.
    ///
    /// Sometimes, we do not want the panel to be same as the entire screen.
    /// For example, when the panel is used in a desktop-like app,
    /// we may want the panel to be constrained within the "window" of the app
    /// instead of the entire screen.
    ///
    /// if not given, the controller will use the screen size as the default constraints.
    PanelConstraints? initialConstraints,

    /// Initial UI decoration configuration for panels,
    ///
    /// See also:
    ///   - [PanelConfig] for what kind of configuration can be set.
    PanelConfig initialConfig,

    /// The strategy for determining the initial position of newly opened panels.
    /// If a [Panel] has no specific initial position, the controller will use this strategy to find a suitable position for it.
    ///
    /// There are several built-in positioners provided by the package,
    /// and you can also implement your own by implementing the [PanelPositioner] interface.
    ///
    /// See also:
    ///  - [PanelPositioner] for how to implement a custom positioner.
    PanelPositioner positioner,

    /// The strategy for determining how panels can be resized by dragging their edges.
    /// If a [Panel] has no specific sizer, the controller will use this strategy to determine how it can be resized.
    ///
    /// There are several built-in sizers provided by the package,
    /// and you can also implement your own by implementing the [PanelSizer] interface.
    ///
    /// See also:
    /// - [PanelSizer] for how to implement a custom sizer.
    PanelSizer sizer,

    /// The initial mode of the panel system.
    PanelMode initialMode,

    /// Whether this controller uses an overlay to display panels.
    /// If false, the panels are expected to be displayed in a [Route] above the current context.
    /// If true, the controller will ensure that panels are displayed in an [Overlay] above the current context,
    /// which will ensure panels are not overridden by other routes.
    bool useOverlay,
  }) = _PanelControllerImpl;
}

final class _PanelControllerImpl extends PanelController
    with PanelStateSetterMixin, PanelViewDelegateImpl, PanelShowerMixin {
  _PanelControllerImpl({
    PanelConstraints? initialConstraints,
    PanelConfig initialConfig = const PanelConfig(),
    PanelPositioner positioner = const PanelPositioner.cascade(),
    PanelSizer sizer = const PanelSizer.scale(),
    PanelMode initialMode = PanelMode.window,
    bool useOverlay = false,
  }) : super._(useOverlay) {
    setup(
      constraints: initialConstraints,
      mode: initialMode,
      config: initialConfig,
      positioner: positioner,
      sizer: sizer,
    );
  }

  final _zIndices = ZIndexManager();
  final _registrar = PanelRegistrar();

  @override
  Object? get focusedPanel {
    final topmost = _zIndices.ordered.lastOrNull;
    assert(
      topmost == null || _registrar.entryOf(topmost) != null,
      'ZIndexManager contains an id that does not exist in panels.',
    );

    return topmost;
  }

  @override
  bool isVisible(Object panelId) {
    assert(_registrar.entryOf(panelId) != null, 'No panel with id "$panelId" is registered.');
    return _zIndices.hasValidIndex(panelId);
  }

  @override
  bool get hasPanels => !_registrar.isEmpty;

  @override
  Iterable<PanelEntry> get orderedPanels {
    return _zIndices.ordered.map((id) => _registrar.entryOf(id)!);
  }

  @override
  Iterable<PanelEntry> get panels {
    return _registrar.panels;
  }

  @override
  void open(BuildContext context, Panel panel) {
    super.open(context, panel);

    final entry = _registrar.register(panel, viewControllerCreator: createViewController);

    if (entry.controller.value.mode == PanelViewMode.minimized) {
      _zIndices.downgrade(panel.id);
    } else {
      _zIndices.upgrade(panel.id);
    }

    notifyListeners();

    ensureOnstage(context, panel);
  }

  @override
  void close(Object panelId) {
    final unregistered = _registrar.unregister(panelId);

    if (unregistered.isEmpty) return;

    for (final id in unregistered) {
      _zIndices.remove(id);
    }

    notifyListeners();
  }

  @override
  void closeAll() {
    if (_registrar.isEmpty) return;

    _registrar.unregisterAll();
    _zIndices.reset();

    notifyListeners();
  }

  @override
  void bringToFront(Object panelId) {
    if (_registrar.entryOf(panelId) == null) return;

    if (!_zIndices.atTop(panelId)) {
      _zIndices.upgrade(panelId);
      notifyListeners();
    }
  }

  @override
  void dispose() {
    closeAll();
    super.dispose();
  }

  /// PanelViewDelegate methods

  @override
  PanelEntry? entryOf(Object panelId) {
    return _registrar.entryOf(panelId);
  }

  @override
  bool markPanelMinimized(Object panelId) {
    return _zIndices.downgrade(panelId);
  }
}
