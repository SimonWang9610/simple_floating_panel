## 2.0.0

- breaking: Replace internal move/resize gesture recognizers with dedicated handle widgets to avoid gesture conflicts with panel body content.
- feat: Export `PanelMoveHandle`, `PanelResizeHandle`, and `PanelResizeEdgeHandle` so applications can compose explicit drag and resize affordances.
- docs: Update README usage examples to show wrapping panel chrome with dedicated move/resize handles.

## 1.1.2

- refactor: Rework panel entry view gesture handling for move and resize interactions.
- fix: Ensure panel resizing is correctly constrained by configured panel constraints.

## 1.1.1

- feat: Add `PanelEntryScope` helper APIs (`ofId` and `maybeOfId`) to simplify reading panel ids from panel context.

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
