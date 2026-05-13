import 'package:flutter/widgets.dart';
import 'package:simple_floating_panel/simple_floating_panel.dart';

/// An [InheritedWidget] that provides access to the [PanelController] for descendant widgets within a panel.
///
/// If the widget is a showing [Panel], it could use [PanelScope.of] to access the master [PanelController]
/// to open new panels or switch modes.
///
/// You could wrap your widget tree with [PanelScope] and provide a [PanelController] to it.
class PanelScope extends InheritedWidget {
  final PanelController controller;

  const PanelScope({
    super.key,
    required this.controller,
    required super.child,
  });

  @override
  bool updateShouldNotify(covariant PanelScope oldWidget) {
    return oldWidget.controller != controller;
  }

  static PanelController of(BuildContext context) {
    final controller = maybeOf(context);

    if (controller == null) {
      throw FlutterError(
        'PanelScope.of() called with a context that does not contain a PanelScope.\n'
        'Make sure the widget is a descendant of [MultiFloatingPanel] that is created when you call PanelController.open().',
      );
    }

    return controller;
  }

  static PanelController? maybeOf(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<PanelScope>();
    return scope?.controller;
  }
}

/// An [InheritedWidget] that provides access to the master panel's id for descendant widgets within a panel.
///
/// This is useful for slave panels to know which master panel they belong to,
/// so that they can interact with the master panel or other slave panels of the same master.
///
/// You should not use this scope directly, as it is an implementation detail of the built-in panel view.
///
/// Instead, you can use [PanelMasterScope.open] to open a new panel that may be a slave panel of the current master panel;
/// however, make sure the context you use to call [PanelMasterScope.open] is a descendant of a showing panel.
///
///
/// Example usage:
/// ```dart
/// final key = UniqueKey();

/// PanelMasterScope.open(context, (masterId) {
///   return Panel(
///     id: key,
///     title: "Sub Panel - $key",
///     masterId: masterId,
///     maintainState: false,
///     builder: (_, c) => _PanelWidget(controller: c),
///   );
/// });
/// ```
class PanelMasterScope extends InheritedWidget {
  final Object masterId;

  const PanelMasterScope({
    super.key,
    required this.masterId,
    required super.child,
  });

  @override
  bool updateShouldNotify(covariant PanelMasterScope oldWidget) {
    return oldWidget.masterId != masterId;
  }

  static Object of(BuildContext context) {
    final id = maybeOf(context);

    if (id == null) {
      throw FlutterError(
        'PanelMasterScope.of() called with a context that does not contain a PanelMasterScope.\n'
        'Make sure the widget is a descendant of [PanelMasterScope] that is created for a panel.',
      );
    }

    return id;
  }

  static Object? maybeOf(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<PanelMasterScope>();
    return scope?.masterId;
  }

  /// A helper method to open a new panel that may be a slave panel of the current master panel,
  /// depending on the returned panel from the [panelBuilder].
  static void open(BuildContext context, Panel Function(Object masterId) panelBuilder) {
    final controller = PanelScope.of(context);
    final masterId = PanelMasterScope.of(context);
    controller.open(context, panelBuilder(masterId));
  }
}

class PanelEntryScope extends InheritedWidget {
  final PanelEntry entry;

  const PanelEntryScope({super.key, required this.entry, required super.child});

  @override
  bool updateShouldNotify(covariant PanelEntryScope oldWidget) {
    return oldWidget.entry != entry;
  }

  static PanelEntry of(BuildContext context) {
    final entry = maybeOf(context);

    if (entry == null) {
      throw FlutterError(
        'PanelEntryScope.of() called with a context that does not contain a PanelEntryScope.\n'
        'Make sure the widget is a descendant of [PanelEntryScope] that is created for a panel.',
      );
    }

    return entry;
  }

  static PanelEntry? maybeOf(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<PanelEntryScope>();
    return scope?.entry;
  }

  static Object? ofId(BuildContext context) {
    final entry = of(context);
    return entry.id;
  }

  static Object? maybeOfId(BuildContext context) {
    final entry = maybeOf(context);
    return entry?.id;
  }
}
