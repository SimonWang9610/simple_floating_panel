import 'package:flutter/material.dart';
import 'package:simple_floating_panel/simple_floating_panel.dart';

class MasterSlavePanelsPage extends StatefulWidget {
  const MasterSlavePanelsPage({super.key});

  @override
  State<MasterSlavePanelsPage> createState() => _MasterSlavePanelsPageState();
}

class _MasterSlavePanelsPageState extends State<MasterSlavePanelsPage> {
  late final PanelController _controller;

  final focusedMaster = ValueNotifier<Object?>(null);

  int _masterCount = 0;
  int _slaveCount = 0;

  @override
  void initState() {
    super.initState();
    _controller = PanelController();

    _controller.addListener(() {
      final focused = _controller.focusedPanel;

      if (focused != null && _controller.entryOf(focused) is MasterPanelEntry) {
        focusedMaster.value = focused;
      } else {
        focusedMaster.value = null;
      }
    });
  }

  @override
  void dispose() {
    focusedMaster.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Master-Slave Panels')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 12,
          children: [
            ValueListenableBuilder(
              valueListenable: focusedMaster,
              builder: (context, masterId, child) {
                return Text(masterId == null ? 'No master panel focused' : 'Focused master panel: $masterId');
              },
            ),

            ElevatedButton(
              onPressed: () {
                final masterId = 'master-${_masterCount++}';

                _controller.open(
                  context,
                  Panel(
                    id: masterId,
                    title: masterId,
                    initialSize: const Size(360, 240),
                    builder: (_, c) => _MasterPanelCard(controller: c, id: masterId),
                  ),
                );

                setState(() {});
              },
              child: const Text('Open master panel'),
            ),
            ValueListenableBuilder(
              valueListenable: focusedMaster,
              builder: (context, masterId, child) {
                return ElevatedButton(
                  onPressed: masterId == null
                      ? null
                      : () {
                          final slaveId = 'slave-${_slaveCount++}';

                          _controller.open(
                            context,
                            Panel(
                              id: slaveId,
                              title: slaveId,
                              masterId: masterId,
                              initialSize: const Size(300, 180),
                              builder: (_, c) =>
                                  _SlavePanelCard(controller: c, id: slaveId, masterId: masterId.toString()),
                            ),
                          );
                        },
                  child: const Text('Open slave for current master'),
                );
              },
            ),
            ValueListenableBuilder(
              valueListenable: focusedMaster,
              builder: (context, masterId, child) {
                return ElevatedButton(
                  onPressed: masterId == null
                      ? null
                      : () {
                          _controller.close(masterId);
                        },
                  child: const Text('Close current master (and its slaves)'),
                );
              },
            ),
            ElevatedButton(
              onPressed: () {
                _controller.closeAll();
                focusedMaster.value = null;
              },
              child: const Text('Close all panels'),
            ),
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

class _MasterPanelCard extends StatelessWidget {
  final PanelViewController controller;
  final String id;

  const _MasterPanelCard({required this.controller, required this.id});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Master: $id', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () {
                final slaveId = 'slave-from-$id-${DateTime.now().microsecondsSinceEpoch}';
                PanelMasterScope.open(context, (masterId) {
                  return Panel(
                    id: slaveId,
                    masterId: masterId,
                    title: slaveId,
                    initialSize: const Size(280, 170),
                    builder: (_, c) => _SlavePanelCard(controller: c, id: slaveId, masterId: masterId.toString()),
                  );
                });
              },
              child: const Text('Open slave from panel via PanelMasterScope.open'),
            ),
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

class _SlavePanelCard extends StatelessWidget {
  final PanelViewController controller;
  final String id;
  final String masterId;

  const _SlavePanelCard({required this.controller, required this.id, required this.masterId});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Slave: $id', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text('Attached to master: $masterId'),
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
