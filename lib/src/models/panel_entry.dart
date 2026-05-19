import 'package:flutter/widgets.dart';
import 'package:simple_floating_panel/simple_floating_panel.dart';

typedef PanelWidgetBuilder = Widget Function(BuildContext context, PanelViewController controller);

sealed class PanelEntry {
  final Object id;
  final bool addRepaintBoundary;
  final PanelWidgetBuilder builder;
  final PanelViewController controller;

  const PanelEntry._({
    required this.id,
    required this.builder,
    required this.controller,
    required this.addRepaintBoundary,
  });

  factory PanelEntry({
    required Object id,
    required PanelWidgetBuilder builder,
    required PanelViewController controller,
    bool addRepaintBoundary = true,
    Object? masterId,
  }) {
    if (masterId != null) {
      return SlavePanelEntry._(
        id: id,
        builder: builder,
        controller: controller,
        addRepaintBoundary: addRepaintBoundary,
        masterId: masterId,
      );
    } else {
      return MasterPanelEntry._(
        id: id,
        builder: builder,
        controller: controller,
        addRepaintBoundary: addRepaintBoundary,
      );
    }
  }
}

final class SlavePanelEntry extends PanelEntry {
  final Object masterId;

  const SlavePanelEntry._({
    required super.id,
    required super.builder,
    required super.controller,
    required super.addRepaintBoundary,
    required this.masterId,
  }) : super._();
}

final class MasterPanelEntry extends PanelEntry {
  final List<Object> slaves;

  const MasterPanelEntry._({
    required super.id,
    required super.builder,
    required super.controller,
    required super.addRepaintBoundary,
    this.slaves = const [],
  }) : super._();

  MasterPanelEntry attach(Object attachedPanelId) {
    if (slaves.contains(attachedPanelId)) {
      return this;
    }

    return MasterPanelEntry._(
      id: id,
      builder: builder,
      controller: controller,
      addRepaintBoundary: addRepaintBoundary,
      slaves: [...slaves, attachedPanelId],
    );
  }

  MasterPanelEntry detach(Object attachedPanelId) {
    if (!slaves.contains(attachedPanelId)) {
      return this;
    }

    return MasterPanelEntry._(
      id: id,
      builder: builder,
      controller: controller,
      addRepaintBoundary: addRepaintBoundary,
      slaves: slaves.where((id) => id != attachedPanelId).toList(),
    );
  }
}
