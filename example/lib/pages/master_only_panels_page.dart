import 'package:flutter/material.dart';
import 'package:simple_floating_panel/simple_floating_panel.dart';

class MasterOnlyPanelsPage extends StatefulWidget {
  const MasterOnlyPanelsPage({super.key});

  @override
  State<MasterOnlyPanelsPage> createState() => _MasterOnlyPanelsPageState();
}

class _MasterOnlyPanelsPageState extends State<MasterOnlyPanelsPage> {
  late final PanelController _controller;
  int _nextId = 0;

  @override
  void initState() {
    super.initState();
    _controller = PanelController(
      positioner: PanelPositioner.follow(
        screenAlignment: Alignment.center,
        panelAlignment: Alignment.center,
        offset: const Offset(-20, 20),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Master-only Panels')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 12,
          children: [
            const Text('All panels opened on this page are master panels (no masterId).'),
            ElevatedButton(
              onPressed: () {
                final id = 'master-${_nextId++}';
                _controller.open(
                  context,
                  Panel(
                    id: id,
                    title: id,
                    initialSize: const Size(340, 220),
                    builder: (_, c) => _MasterOnlyPanelCard(controller: c, label: id),
                  ),
                );
              },
              child: const Text('Open master panel'),
            ),
            ElevatedButton(onPressed: _controller.closeAll, child: const Text('Close all panels')),
            ElevatedButton(
              onPressed: () {
                _controller.mode = _controller.mode == PanelMode.window ? PanelMode.preview : PanelMode.window;
              },
              child: const Text('Toggle preview/window mode'),
            ),
          ],
        ),
      ),
    );
  }
}

class _MasterOnlyPanelCard extends StatelessWidget {
  final PanelViewController controller;
  final String label;

  const _MasterOnlyPanelCard({required this.controller, required this.label});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Master: $label', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            const Text('This panel is independent from all other panels.'),
            const Spacer(),
            Align(
              alignment: Alignment.bottomRight,
              child: IconButton(onPressed: controller.close, icon: const Icon(Icons.close)),
            ),
          ],
        ),
      ),
    );
  }
}
