import 'dart:async';

import 'package:flutter/material.dart';
import 'package:simple_floating_panel/simple_floating_panel.dart';
import 'package:simple_floating_panel/panel_dock.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(colorScheme: .fromSeed(seedColor: Colors.deepPurple)),
      home: const FloatingPanelExample(),
    );
  }
}

class FloatingPanelExample extends StatefulWidget {
  const FloatingPanelExample({super.key});

  @override
  State<FloatingPanelExample> createState() => _FloatingPanelExampleState();
}

class _FloatingPanelExampleState extends State<FloatingPanelExample> {
  PanelController? _panelController;

  @override
  void dispose() {
    _panelController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Floating Panel Example')),
      body: Center(
        child: Column(
          spacing: 20,
          children: [
            ElevatedButton(
              onPressed: () {
                _showPanel();
              },
              child: const Text('Show Panel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (Navigator.canPop(context)) {
                  Navigator.pop(context);
                }
              },
              child: const Text('Pop route'),
            ),
            ElevatedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text('Dialog'),
                    content: const Text('This is a dialog.'),
                    actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close'))],
                  ),
                );
              },
              child: const Text('Show dialog'),
            ),
            ElevatedButton(
              onPressed: () {
                _panelController?.closeAll();
              },
              child: Text("Close all panels"),
            ),
            const Spacer(),
            if (_panelController != null)
              Align(
                alignment: Alignment.centerLeft,
                child: FloatingPanelDock(controller: _panelController!),
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (_panelController == null) return;

          if (_panelController?.mode == PanelMode.window) {
            _panelController!.mode = PanelMode.preview;
          } else {
            _panelController!.mode = PanelMode.window;
          }
        },
        child: const Icon(Icons.fullscreen),
      ),
    );
  }

  void _showPanel() {
    final screenSize = MediaQuery.sizeOf(context);

    _panelController ??= PanelController(
      // initialConstraints: PanelConstraints.fromPadding(
      //   screenSize,
      //   padding: EdgeInsets.symmetric(horizontal: 40, vertical: 80),
      // ),
      initialConstraints: PanelConstraints.scale(screenSize, maxSizeRatio: 0.8),
    );

    _panelController!.open(
      context,
      Panel(
        id: 'main_panel',
        title: 'Main Panel',
        initialSize: const Size(400, 400),
        builder: (_, c) => _PanelWidget(controller: c),
      ),
    );

    setState(() {});
  }
}

class _PanelWidget extends StatefulWidget {
  final PanelViewController controller;
  const _PanelWidget({required this.controller});

  @override
  State<_PanelWidget> createState() => _PanelWidgetState();
}

class _PanelWidgetState extends State<_PanelWidget> {
  Timer? _timer;

  int _counter = 0;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _counter++;
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: widget.controller,
      builder: (_, settings, _) {
        return Material(
          child: Container(
            color: Colors.white,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      onPressed: () {
                        if (settings.mode == PanelViewMode.maximized) {
                          widget.controller.restore();
                        } else {
                          widget.controller.maximize();
                        }
                      },
                      icon: const Icon(Icons.fullscreen),
                    ),
                    Expanded(child: Text(settings.title ?? "Untitled Panel")),
                    IconButton(onPressed: widget.controller.close, icon: const Icon(Icons.close)),
                  ],
                ),
                ElevatedButton(onPressed: () => _open(context), child: const Text('Open sub panel')),
                Text('Counter: $_counter'),
              ],
            ),
          ),
        );
      },
    );
  }

  void _open(BuildContext context) {
    final key = UniqueKey();

    PanelMasterScope.open(context, (masterId) {
      return Panel(
        id: key,
        title: "Sub Panel - $key",
        masterId: masterId,
        maintainState: false,
        builder: (_, c) => _PanelWidget(controller: c),
      );
    });
  }
}
