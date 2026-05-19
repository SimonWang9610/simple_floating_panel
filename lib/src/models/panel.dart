import 'package:flutter/widgets.dart';
import 'package:simple_floating_panel/simple_floating_panel.dart';

sealed class Panel {
  final Object id;

  /// Whether the panel's state should be maintained when it's not visible,
  /// or switching to a different mode.
  ///
  /// If false, the panel view state will not be maintained internally,
  /// it is the developer's responsibility to maintain the state externally if needed.
  final bool maintainState;

  /// Whether to add a RepaintBoundary around the panel content.
  /// If true, it can improve performance when the panel content is complex and does not need to repaint frequently;
  /// if false, it can reduce memory usage and improve performance when the panel content is simple and needs to repaint frequently.
  ///
  /// Defaults to true;
  final bool addRepaintBoundary;

  /// Optional title for the panel, which can be used to build the panel item in the dock when the panel is minimized.
  final String? title;

  /// The initial position of the panel when it's first opened.
  /// If null, [PanelController] will determine the initial position based on the current open panels
  /// and the available space.
  ///
  /// [PanelConstraints]  will still apply to the initial position,
  /// so if the provided position is out of bounds,
  /// it will be adjusted to fit within the constraints.
  ///
  /// If not provided, [PanelPositioner] will attempt to find the initial position
  final Offset? initialPosition;

  /// The initial size of the panel when it's first opened.
  ///
  /// [PanelConstraints] will still apply to the initial size,
  /// so if the provided size is out of bounds,
  /// it will be adjusted to fit within the constraints.
  ///
  /// If not provided, [PanelSizer] will attempt to find the initial size.
  final Size? initialSize;

  /// The builder function for the panel's content.  ///
  /// All widgets built by this builder will be provided with a [PanelViewController]
  /// that can be used to control the panel's state and geometry.
  ///
  /// All Widgets can also use [PanelScope.of] to access the master [PanelController] to open new panels or switch modes.
  final PanelWidgetBuilder builder;

  const Panel._({
    required this.id,
    required this.builder,
    this.title,
    this.initialPosition,
    this.initialSize,
    this.maintainState = true,
    this.addRepaintBoundary = true,
  });

  /// Creates a new panel with the given parameters.
  ///
  /// If [masterId] is provided, the panel will be attached to the master panel with the corresponding id,
  /// and will be automatically closed when the master panel is closed.
  factory Panel({
    required Object id,
    required PanelWidgetBuilder builder,
    String? title,
    Offset? initialPosition,
    Size? initialSize,
    bool maintainState = true,
    bool addRepaintBoundary = true,
    Object? masterId,
  }) {
    if (masterId != null) {
      return SlavePanel._(
        id: id,
        builder: builder,
        title: title,
        initialPosition: initialPosition,
        initialSize: initialSize,
        maintainState: maintainState,
        addRepaintBoundary: addRepaintBoundary,
        masterId: masterId,
      );
    } else {
      return MasterPanel._(
        id: id,
        builder: builder,
        title: title,
        initialPosition: initialPosition,
        initialSize: initialSize,
        maintainState: maintainState,
        addRepaintBoundary: addRepaintBoundary,
      );
    }
  }
}

/// A panel that is attached to a specific parent panel,
/// and will be automatically closed when the parent panel is closed.
///
/// Given [masterId], the [PanelController] will try to find the master panel with the corresponding id,
/// and attach this panel to it.
///
/// If the master panel is not found, it will throws an exception and the attached panel will not be opened.
final class SlavePanel extends Panel {
  /// The id of the master panel to which this panel is attached.
  final Object masterId;

  const SlavePanel._({
    required this.masterId,
    required super.id,
    required super.builder,
    super.title,
    super.initialPosition,
    super.initialSize,
    super.maintainState,
    super.addRepaintBoundary,
  }) : super._();
}

/// A master panel is not managed by other panels, will have its own lifecycle,
/// [SlavePanel]s can be attached to it, but it will not be automatically closed when the attached panels are closed.
final class MasterPanel extends Panel {
  const MasterPanel._({
    required super.id,
    required super.builder,
    super.title,
    super.initialPosition,
    super.initialSize,
    super.maintainState,
    super.addRepaintBoundary,
  }) : super._();
}
