# simple_floating_panel

A lightweight desktop-style floating panel system for Flutter.

Supports multi-panel orchestration with drag/resize, z-order, preview mode, minimize/restore, and master-slave panel relations.

---

## Installation

```yaml
dependencies:
  simple_floating_panel: ^1.0.0
```

```bash
flutter pub get
```

---

## Demo

<div style="display: flex; gap: 16px; flex-wrap: wrap;">
<img src="https://raw.githubusercontent.com/SimonWang9610/simple_floating_panel/blob/main/assets/multi-floating-panel-demo.gif" alt="Demo" width="600"/>

<img src="https://raw.githubusercontent.com/SimonWang9610/simple_floating_panel/blob/main/assets/panel-resize-move-demo.gif" alt="Demo" width="600"/>
</div>

## Core features

- Multi-panel orchestration with z-order management
- Built-in drag and resize panel interactions
- Window and preview modes (`PanelMode.window`, `PanelMode.preview`)
- Minimize/restore workflow and optional dock integration
- Master-slave relations with cascade close behavior
- Flexible initialization via `PanelConstraints`, `PanelSizer`, `PanelPositioner`
- Visual customization via `PanelConfig` and `PanelPreviewStyle`
- Optional overlay-based mounting (`useOverlay: true`)

### Customization highlights

You can independently customize panel placement strategy, initial sizing strategy, and visual style:

```dart
final controller = PanelController(
  initialConstraints: PanelConstraints.scale(MediaQuery.sizeOf(context), maxSizeRatio: 0.9),
  positioner: const PanelPositioner.cascade(offset: Offset(24, 24)),
  sizer: const PanelSizer.aspectRatio(aspectRatio: 16 / 10, scale: 0.35),
  initialConfig: const PanelConfig(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.all(Radius.circular(12)),
    ),
    focusedDecoration: BoxDecoration(
      color: Colors.white,
      border: Border.fromBorderSide(BorderSide(color: Colors.blue, width: 2)),
      borderRadius: BorderRadius.all(Radius.circular(12)),
    ),
  ),
);
```

This lets you tune behavior and style without changing panel business logic.

## Provider-style code snippets

### 1) Provide a shared `PanelController`

```dart
class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  final controller = PanelController();

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PanelScope(
      controller: controller,
      child: const MyPage(),
    );
  }
}
```

### 2) Consume the provided controller

```dart
final controller = PanelScope.of(context);
controller.open(
  context,
  Panel(id: 'panel-1', builder: (_, c) => MyPanelView(controller: c)),
);
```

### 3) Open a slave panel from current panel context
> `context` must be inside a panel view built by the `builder` of a master/slave panel.

```dart
PanelMasterScope.open(context, (masterId) {
  return Panel(
    id: 'slave-1',
    masterId: masterId,
    builder: (_, c) => MyPanelView(controller: c),
  );
});
```

---

## Code usage

### Quick start

```dart
final controller = PanelController(
  initialConstraints: PanelConstraints.scale(MediaQuery.sizeOf(context), maxSizeRatio: 0.8),
);

controller.open(
  context,
  Panel(
    id: 'main',
    title: 'Main Panel',
    initialSize: const Size(420, 320),
    builder: (_, c) => MyPanelView(controller: c),
  ),
);
```

### Master-only usage

```dart
controller.open(
  context,
  Panel(id: 'master-1', title: 'Master 1', builder: (_, c) => MyPanelView(controller: c)),
);
```

### Master + slave usage

```dart
controller.open(context, Panel(id: 'master-1', builder: (_, c) => MyPanelView(controller: c)));

controller.open(
  context,
  Panel(id: 'slave-1', masterId: 'master-1', builder: (_, c) => MyPanelView(controller: c)),
);
```

### Use inside panel view

```dart
class MyPanelView extends StatelessWidget {
  final PanelViewController controller;
  const MyPanelView({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(onPressed: controller.minimize, icon: const Icon(Icons.minimize)),
        IconButton(onPressed: controller.maximize, icon: const Icon(Icons.fullscreen)),
        IconButton(onPressed: controller.restore, icon: const Icon(Icons.filter_none)),
        IconButton(onPressed: controller.close, icon: const Icon(Icons.close)),
      ],
    );
  }
}
```

---

## Core concepts

### `PanelController`

Global panel manager.

| Parameter / API | Kind | Description |
|---|---|---|
| `open(context, panel)` | Method | Opens a panel and registers it into controller state. |
| `close(panelId)` | Method | Closes one panel by id. |
| `closeAll()` | Method | Closes all panels managed by this controller. |
| `bringToFront(panelId)` | Method | Brings a panel to top z-order and focuses it. |
| `isVisible(panelId)` | Method | Returns whether the panel is currently visible (not minimized). |
| `focusedPanel` | Getter | Id of the currently focused panel. |
| `orderedPanels` | Getter | Panels in z-order (back to front). |
| `panels` | Getter | Panels in registration order. |
| `mode` | Property | Display mode: `PanelMode.window` or `PanelMode.preview`. |
| `constraints` | Property | Runtime bounds and size constraints for panels. |
| `config` | Property | Runtime visual config (`PanelConfig`, preview style, decorations). |

### `Panel`

Panel descriptor used when opening a panel.

| Parameter | Type | Required | Description |
|---|---|---|---|
| `id` | `Object` | Yes | Unique identifier of the panel. |
| `builder` | `PanelWidgetBuilder` | Yes | Builds panel content with a `PanelViewController`. |
| `title` | `String?` | No | Optional title used by panel UI/dock representation. |
| `initialSize` | `Size?` | No | Initial panel size before constraints are applied. |
| `initialPosition` | `Offset?` | No | Initial origin before constraints are applied. |
| `maintainState` | `bool` | No | Keeps panel widget state when hidden/mode-switched. |
| `useBuiltInView` | `bool` | No | Enables built-in drag/resize view behavior. |
| `addRepaintBoundary` | `bool` | No | Wraps panel with `RepaintBoundary` for paint optimization. |
| `masterId` | `Object?` | No | When set, creates a slave panel attached to the master panel id. |

### `PanelViewController`

Controller for a single rendered panel.

| Parameter / API | Kind | Description |
|---|---|---|
| `value` | Getter | Current `PanelViewState` (title, mode, geometry). |
| `minimize()` | Method | Switches panel to minimized mode. |
| `maximize()` | Method | Switches panel to maximized mode. |
| `restore()` | Method | Restores panel from minimized/maximized mode. |
| `move(dx, dy)` | Method | Moves panel by delta offsets. |
| `resize(delta, direction)` | Method | Resizes panel from a specific edge/corner direction. |
| `bringToFront()` | Method | Requests focus/top z-order for the panel. |
| `close()` | Method | Closes this panel. |
| `title = ...` | Setter | Updates panel title at runtime. |

### `PanelScope` and `PanelMasterScope`

| Scope | Main API | Description |
|---|---|---|
| `PanelScope` | `of(context)`, `maybeOf(context)` | Reads a provided `PanelController` from widget tree. |
| `PanelMasterScope` | `of(context)`, `maybeOf(context)`, `open(context, panelBuilder)` | Reads current master id and opens slave panels attached to that master. |

---





## Example pages

- [example/lib/main.dart](example/lib/main.dart): example launcher.
- [example/lib/pages/panel_scope_provided_controller_page.dart](example/lib/pages/panel_scope_provided_controller_page.dart): shared controller via `PanelScope`.
- [example/lib/pages/master_only_panels_page.dart](example/lib/pages/master_only_panels_page.dart): master-only usage.
- [example/lib/pages/master_slave_panels_page.dart](example/lib/pages/master_slave_panels_page.dart): master-slave usage.

Run examples:

```bash
cd example
flutter run
```

## Contributing

Issues and PRs are welcome: https://github.com/SimonWang9610/simple_floating_panel/issues
