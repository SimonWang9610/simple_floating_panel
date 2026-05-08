import 'package:flutter/material.dart';

import 'pages/master_only_panels_page.dart';
import 'pages/master_slave_panels_page.dart';
import 'pages/panel_scope_provided_controller_page.dart';
import 'package:simple_floating_panel/simple_floating_panel.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final PanelController _providedController = PanelController(
    positioner: PanelPositioner.follow(
      screenAlignment: Alignment.topRight,
      panelAlignment: Alignment.topRight,
      offset: const Offset(-20, 20),
    ),
  );

  @override
  void dispose() {
    _providedController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Simple Floating Panel Examples',
      theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple)),
      home: _ExampleMenuPage(providedController: _providedController),
    );
  }
}

class _ExampleMenuPage extends StatelessWidget {
  final PanelController providedController;

  const _ExampleMenuPage({required this.providedController});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Example Pages')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListTile(
            leading: const Icon(Icons.account_tree_outlined),
            title: const Text('1) PanelScope with provided PanelController'),
            subtitle: const Text('Page uses PanelScope.of(context) and a controller provided from parent.'),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => PanelScopeProvidedControllerPage(controller: providedController)),
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.dashboard_outlined),
            title: const Text('2) Master-only panels'),
            subtitle: const Text('Shows independent master panels only.'),
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (_) => const MasterOnlyPanelsPage()));
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.device_hub_outlined),
            title: const Text('3) Master-slave panels'),
            subtitle: const Text('Shows master panel and attached slave panels.'),
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (_) => const MasterSlavePanelsPage()));
            },
          ),
        ],
      ),
    );
  }
}
