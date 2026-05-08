import 'package:flutter/widgets.dart';
import 'package:simple_floating_panel/simple_floating_panel.dart';

typedef PanelWidgetBuilder = Widget Function(BuildContext context, PanelViewController controller);

sealed class PanelEntry {
  final Object id;
  final bool useBuiltInView;
  final bool addRepaintBoundary;
  final PanelWidgetBuilder builder;
  final PanelViewController controller;

  const PanelEntry({
    required this.id,
    required this.builder,
    required this.controller,
    required this.useBuiltInView,
    required this.addRepaintBoundary,
  });
}

final class AttachedPanelEntry extends PanelEntry {
  final Object masterId;

  const AttachedPanelEntry({
    required super.id,
    required super.builder,
    required super.controller,
    required super.useBuiltInView,
    required super.addRepaintBoundary,
    required this.masterId,
  });
}

final class MasterPanelEntry extends PanelEntry {
  final List<Object> attachedPanels;

  const MasterPanelEntry({
    required super.id,
    required super.builder,
    required super.controller,
    required super.useBuiltInView,
    required super.addRepaintBoundary,
    this.attachedPanels = const [],
  });

  MasterPanelEntry attach(Object attachedPanelId) {
    if (attachedPanels.contains(attachedPanelId)) {
      return this;
    }

    return MasterPanelEntry(
      id: id,
      builder: builder,
      controller: controller,
      useBuiltInView: useBuiltInView,
      addRepaintBoundary: addRepaintBoundary,
      attachedPanels: [...attachedPanels, attachedPanelId],
    );
  }

  MasterPanelEntry detach(Object attachedPanelId) {
    if (!attachedPanels.contains(attachedPanelId)) {
      return this;
    }

    return MasterPanelEntry(
      id: id,
      builder: builder,
      controller: controller,
      useBuiltInView: useBuiltInView,
      addRepaintBoundary: addRepaintBoundary,
      attachedPanels: attachedPanels.where((id) => id != attachedPanelId).toList(),
    );
  }
}
