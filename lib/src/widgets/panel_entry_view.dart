import 'package:flutter/material.dart';
import 'package:simple_floating_panel/simple_floating_panel.dart';

class PanelEntryView extends StatefulWidget {
  final double resizeThreshold;
  final bool enabled;
  final PanelEntry entry;

  const PanelEntryView({
    super.key,
    this.enabled = true,
    required this.entry,
    this.resizeThreshold = 5,
  });

  @override
  State<PanelEntryView> createState() => _PanelEntryViewState();
}

class _PanelEntryViewState extends State<PanelEntryView> {
  @override
  Widget build(BuildContext context) {
    Widget view = PanelMasterScope(
      masterId: switch (widget.entry) {
        MasterPanelEntry m => m.id,
        SlavePanelEntry s => s.masterId,
      },
      child: PanelEntryScope(
        entry: widget.entry,
        child: Builder(
          builder: (inner) {
            return widget.entry.builder(inner, widget.entry.controller);
          },
        ),
      ),
    );

    if (widget.entry.useBuiltInView) {
      view = PanelGestureDetector(
        enabled: widget.enabled,
        resizeThreshold: widget.resizeThreshold,
        onTap: () {
          widget.entry.controller.bringToFront();
        },
        onInteractionStart: () {
          widget.entry.controller.bringToFront();
        },
        onMoveUpdate: (delta) {
          if (widget.entry.controller.value.mode != PanelViewMode.normal) return;
          widget.entry.controller.move(delta.dx, delta.dy);
        },
        onResizeUpdate: (delta, direction) {
          if (widget.entry.controller.value.mode != PanelViewMode.normal) return;
          widget.entry.controller.resize(delta, direction);
        },
        child: view,
      );
    } else {
      view = IgnorePointer(
        ignoring: !widget.enabled,
        child: view,
      );
    }

    return view;
  }
}
