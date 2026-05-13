import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:simple_floating_panel/simple_floating_panel.dart';

import '../panel_test_helpers.dart';

void main() {
  group('PanelEntryScope', () {
    testWidgets('of/maybeOf/ofId/maybeOfId return values when scope exists', (tester) async {
      final entry = _buildEntry('panel-1');
      late BuildContext context;

      await tester.pumpWidget(
        MaterialApp(
          home: PanelEntryScope(
            entry: entry,
            child: Builder(
              builder: (ctx) {
                context = ctx;
                return const SizedBox();
              },
            ),
          ),
        ),
      );

      expect(PanelEntryScope.of(context), same(entry));
      expect(PanelEntryScope.maybeOf(context), same(entry));
      expect(PanelEntryScope.ofId(context), 'panel-1');
      expect(PanelEntryScope.maybeOfId(context), 'panel-1');
    });

    testWidgets('of and ofId throw, maybeOf and maybeOfId return null when scope is absent', (tester) async {
      late BuildContext context;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (ctx) {
              context = ctx;
              return const SizedBox();
            },
          ),
        ),
      );

      expect(() => PanelEntryScope.of(context), throwsA(isA<FlutterError>()));
      expect(() => PanelEntryScope.ofId(context), throwsA(isA<FlutterError>()));
      expect(PanelEntryScope.maybeOf(context), isNull);
      expect(PanelEntryScope.maybeOfId(context), isNull);
    });

    test('updateShouldNotify only when entry instance changes', () {
      final entry = _buildEntry('panel-1');
      final sameScope = PanelEntryScope(entry: entry, child: const SizedBox());
      final sameScopeAgain = PanelEntryScope(entry: entry, child: const SizedBox());
      final differentScope = PanelEntryScope(entry: _buildEntry('panel-1'), child: const SizedBox());

      expect(sameScopeAgain.updateShouldNotify(sameScope), isFalse);
      expect(differentScope.updateShouldNotify(sameScope), isTrue);
    });
  });
}

PanelEntry _buildEntry(Object id) {
  final controller = PanelViewController(
    id,
    delegate: const _NoopDelegate(),
    initialState: const PanelViewState(
      title: 'Test Panel',
      geometry: PanelGeometry(origin: Offset.zero, size: Size(160, 120)),
    ),
    initialConstraints: testConstraints(),
  );

  return PanelEntry(
    id: id,
    builder: (_, __) => const SizedBox(),
    controller: controller,
  );
}

final class _NoopDelegate implements PanelViewDelegate {
  const _NoopDelegate();

  @override
  void onPanelClosed(Object panelId) {}

  @override
  void onPanelFocused(Object panelId) {}

  @override
  void onPanelMaximize(Object panelId) {}

  @override
  void onPanelMinimize(Object panelId) {}

  @override
  void onPanelRestore(Object panelId) {}

  @override
  PanelEntry? entryOf(Object panelId) => null;
}
