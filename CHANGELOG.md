## 1.1.0

- feat: Add `PanelMasterScope` for opening slave panels from master panel context, enabling dynamic master-slave relationships and nested panel workflows.
- feat: support master-slave panel relationships without pre-defining master panel IDs, allowing more flexible panel orchestration.

## 1.0.0

Initial stable release of `simple_floating_panel`.

### Added

- Multi-panel floating window system for Flutter.
- Panel lifecycle and orchestration via `PanelController`:
	- open/close/closeAll
	- focus and z-order management
	- runtime mode switching
- Per-panel controls via `PanelViewController`:
	- minimize / maximize / restore
	- move and resize operations
- Display modes:
	- `PanelMode.window` for freeform desktop-style windows
	- `PanelMode.preview` for panel overview grid
- Built-in dock widget: `FloatingPanelDock` for minimized panel workflows.
- `PanelScope` to access the root controller from within panel content and open nested panels.
- Configurable constraints and layout behavior:
	- `PanelConstraints`
	- `PanelSizer`
	- `PanelPositioner`
- Visual customization with `PanelConfig` and `PanelPreviewStyle`.
- Route/overlay mounting support (`useOverlay`) for flexible integration.

### Docs

- Comprehensive README rewrite with:
	- feature overview and usage guidance
	- quick-start examples
	- customization reference
	- demo GIFs
