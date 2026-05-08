# simple_floating_panel

A lightweight, desktop-style floating window system for Flutter.

Create draggable, resizable, minimizable, maximizable panels with built-in z-order management, preview mode, and dock support.

---

## Demo

### Multi-panel workflow
<img src="https://github.com/SimonWang9610/simple_floating_panel/blob/main/assets/multi-floating-panel-demo.gif?raw=true" width="320">

### Minimize / restore with dock
	<img src="https://github.com/SimonWang9610/simple_floating_panel/blob/main/assets/panel-minimize-restore-demo.gif?raw=true" width="320">

---

## Why this package

- **Desktop-like UX in Flutter**: movable and resizable windows inside your app.
- **Multi-panel orchestration**: open, close, focus, and reorder multiple panels.
- **Two display modes**:
	- `PanelMode.window`: freeform floating windows.
	- `PanelMode.preview`: grid-style overview for quick switching.
- **Minimize + dock pattern**: use `FloatingPanelDock` out of the box.
- **Flexible setup**: route-based or overlay-based mounting.
- **Customizable behavior**: pluggable sizing (`PanelSizer`), positioning (`PanelPositioner`), constraints, and decorations (`PanelConfig`).

---

## Installation

Add to `pubspec.yaml`:

```yaml
dependencies:
	simple_floating_panel: ^1.0.0
```

Then run:

```bash
flutter pub get
```

---

## Quick start

```dart
import 'package:flutter/material.dart';
import 'package:simple_floating_panel/simple_floating_panel.dart';

class FloatingPanelDemo extends StatefulWidget {
	const FloatingPanelDemo({super.key});

	@override
	State<FloatingPanelDemo> createState() => _FloatingPanelDemoState();
}

class _FloatingPanelDemoState extends State<FloatingPanelDemo> {
	PanelController? _panelController;

	@override
	void dispose() {
		_panelController?.dispose();
		super.dispose();
	}

	void _openMainPanel() {
		final screenSize = MediaQuery.sizeOf(context);

		_panelController ??= PanelController(
			initialConstraints: PanelConstraints.scale(screenSize, maxSizeRatio: 0.8),
		);

		_panelController!.open(
			context,
			Panel(
				id: 'main',
				title: 'Main Panel',
				initialSize: const Size(420, 320),
				builder: (_, panelViewController) {
					return Material(
						child: Column(
							children: [
								Row(
									children: [
										IconButton(
											onPressed: () {
												final mode = panelViewController.value.mode;
												if (mode == PanelViewMode.maximized) {
													panelViewController.restore();
												} else {
													panelViewController.maximize();
												}
											},
											icon: const Icon(Icons.fullscreen),
										),
										const Spacer(),
										IconButton(
											onPressed: panelViewController.close,
											icon: const Icon(Icons.close),
										),
									],
								),
								const Expanded(
									child: Center(child: Text('Hello from simple_floating_panel 👋')),
								),
							],
						),
					);
				},
			),
		);

		setState(() {});
	}

	@override
	Widget build(BuildContext context) {
		return Scaffold(
			appBar: AppBar(title: const Text('Floating Panel Demo')),
			body: Center(
				child: ElevatedButton(
					onPressed: _openMainPanel,
					child: const Text('Open panel'),
				),
			),
			bottomNavigationBar: _panelController == null
					? null
					: SafeArea(
							child: Align(
								alignment: Alignment.centerLeft,
								child: FloatingPanelDock(controller: _panelController!),
							),
						),
		);
	}
}
```

---

## Core concepts

### `PanelController`

Global manager for all panels:

- Open/close/focus panels: `open`, `close`, `closeAll`, `bringToFront`
- Query state: `panels`, `orderedPanels`, `focusedPanel`, `hasPanels`
- Runtime settings: `mode`, `constraints`, `config`

Use `useOverlay: true` to mount panels in an overlay above route transitions.

### `Panel`

Describes one window:

- Required: `id`, `builder`
- Optional: `title`, `initialPosition`, `initialSize`
- Behavior flags: `maintainState`, `useBuiltInView`, `addRepaintBoundary`

### `PanelViewController`

Controls a single panel instance from inside its view:

- `minimize()`, `maximize()`, `restore()`
- `move(dx, dy)` and `resize(delta, direction)`
- `bringToFront()`, `close()`, `title = ...`

---

## Open nested/sub panels

Inside any panel widget, use `PanelScope.of(context)` to access the same root controller and open additional panels:

```dart
void openSubPanel(BuildContext context) {
	final controller = PanelScope.of(context);

	controller.open(
		context,
		Panel(
			id: UniqueKey(),
			title: 'Sub Panel',
			builder: (_, viewController) {
				return Material(
					child: Center(
						child: ElevatedButton(
							onPressed: viewController.close,
							child: const Text('Close'),
						),
					),
				);
			},
		),
	);
}
```

---

## Layout and behavior customization

### Panel bounds

Use `PanelConstraints`:

- `PanelConstraints.scale(screenSize, minSizeRatio, maxSizeRatio, edgeVisibleThreshold)`
- `PanelConstraints.fromPadding(screenSize, padding: ...)`

### Initial position strategy

Use `PanelPositioner`:

- `PanelPositioner.cascade()`
- `PanelPositioner.alwaysOrigin()`
- `PanelPositioner.follow(panelAlignment: ..., screenAlignment: ..., offset: ...)`

### Initial size strategy

Use `PanelSizer`:

- `PanelSizer.scale(scale: ...)`
- `PanelSizer.aspectRatio(aspectRatio: ..., scale: ...)`
- `PanelSizer.fixed(size: ...)`

### Visual style

Use `PanelConfig` + `PanelPreviewStyle` to customize:

- panel decoration / focused decoration
- preview grid spacing
- preview barrier color and dismiss behavior

---

## Modes and dock UX

- Set controller `mode`:
	- `PanelMode.window`: normal draggable windows.
	- `PanelMode.preview`: panel overview grid.
- Use `FloatingPanelDock` to surface minimized panels and quick actions.

---

## Example app

A complete runnable sample is available in [example/lib/main.dart](example/lib/main.dart).

Run it with:

```bash
cd example
flutter run
```

---

## Roadmap ideas

- keyboard shortcuts for focus switching
- snapping / tiling layouts
- optional desktop title-bar presets

---

## Contributing

Issues and PRs are welcome: https://github.com/SimonWang9610/simple_floating_panel/issues

If this package helps your app, a ⭐ on the repository is appreciated.
