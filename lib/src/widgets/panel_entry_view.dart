import 'package:flutter/material.dart';
import 'package:simple_floating_panel/simple_floating_panel.dart';

class PanelEntryView extends StatelessWidget {
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
  Widget build(BuildContext context) {
    Widget view = PanelMasterScope(
      masterId: switch (entry) {
        MasterPanelEntry m => m.id,
        SlavePanelEntry s => s.masterId,
      },
      child: PanelEntryScope(
        entry: entry,
        child: IgnorePointer(
          ignoring: !enabled,
          child: Listener(
            behavior: HitTestBehavior.translucent,
            onPointerDown: (_) => entry.controller.bringToFront(),
            child: Builder(
              builder: (inner) => entry.builder(inner, entry.controller),
            ),
          ),
        ),
      ),
    );

    return view;
  }
}
