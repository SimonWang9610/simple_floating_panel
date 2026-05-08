import 'package:flutter/material.dart';
import 'package:simple_floating_panel/simple_floating_panel.dart';

class PanelScopeProvidedControllerPage extends StatefulWidget {
  final PanelController controller;

  const PanelScopeProvidedControllerPage({super.key, required this.controller});

  @override
  State<PanelScopeProvidedControllerPage> createState() => _PanelScopeProvidedControllerPageState();
}

class _PanelScopeProvidedControllerPageState extends State<PanelScopeProvidedControllerPage> {
  int _panelCount = 0;

  @override
  Widget build(BuildContext context) {
    return PanelScope(
      controller: widget.controller,
      child: Scaffold(
        appBar: AppBar(title: const Text('PanelScope + Provided Controller')),
        body: Builder(
          builder: (scopeContext) {
            return Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 12,
                children: [
                  const Text(
                    'This page is wrapped with PanelScope and uses PanelScope.of(context)\n'
                    'with a PanelController provided by the parent page.',
                  ),
                  ElevatedButton(
                    onPressed: () {
                      final controller = PanelScope.of(scopeContext);
                      final id = 'provided-panel-${_panelCount++}';

                      controller.open(
                        scopeContext,
                        Panel(
                          id: id,
                          title: id,
                          initialSize: const Size(320, 220),
                          builder: (_, c) => _SimplePanelCard(controller: c, label: id),
                        ),
                      );
                    },
                    child: const Text('Open panel via PanelScope.of(context)'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      final controller = PanelScope.of(scopeContext);
                      controller.closeAll();
                    },
                    child: const Text('Close all panels'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      final controller = PanelScope.of(scopeContext);
                      controller.mode = controller.mode == PanelMode.window ? PanelMode.preview : PanelMode.window;
                    },
                    child: const Text('Toggle preview/window mode'),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _SimplePanelCard extends StatelessWidget {
  final PanelViewController controller;
  final String label;

  const _SimplePanelCard({required this.controller, required this.label});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            const Text('Controller comes from parent-provided PanelScope.'),
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
