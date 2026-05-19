import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class PanelPreviewStyle extends Equatable {
  final double horizontalSpacing;
  final double verticalSpacing;

  /// whether the last row should be expanded to fill the remaining horizontal space.
  /// If false, the horizontal space of the last row will be computed base don the maximum column count, just like other rows.
  /// If true, the horizontal space of the last row will be computed based on the actual item count in that row.
  final bool expandLastRow;
  final Color? barrierColor;
  final bool barrierDismissible;
  final BoxDecoration? decoration;
  final BoxDecoration? focusedDecoration;
  final EdgeInsets? padding;

  const PanelPreviewStyle({
    this.horizontalSpacing = 8,
    this.verticalSpacing = 8,
    this.expandLastRow = false,
    this.barrierColor,
    this.barrierDismissible = true,
    this.decoration,
    this.focusedDecoration,
    this.padding,
  });

  @override
  List<Object?> get props => [
    horizontalSpacing,
    verticalSpacing,
    expandLastRow,
    barrierColor,
    barrierDismissible,
    decoration,
    focusedDecoration,
    padding,
  ];
}

class PanelConfig extends Equatable {
  final PanelPreviewStyle previewStyle;
  final BoxDecoration focusedDecoration;
  final BoxDecoration decoration;

  const PanelConfig({
    this.previewStyle = const PanelPreviewStyle(barrierColor: Colors.black54, barrierDismissible: true),
    this.focusedDecoration = const BoxDecoration(
      borderRadius: BorderRadius.all(Radius.circular(8)),
      boxShadow: [BoxShadow(color: Colors.purple, blurRadius: 5, offset: Offset(0, 1))],
    ),
    this.decoration = const BoxDecoration(
      borderRadius: BorderRadius.all(Radius.circular(8)),
      boxShadow: [BoxShadow(color: Colors.purple, blurRadius: 5, offset: Offset(0, 1))],
    ),
  });

  @override
  List<Object?> get props => [previewStyle, focusedDecoration, decoration];

  Widget wrap(Widget panelView, {bool focused = false, bool preview = false}) {
    final d = switch ((preview, focused)) {
      (true, false) => previewStyle.decoration ?? decoration,
      (true, true) => previewStyle.focusedDecoration ?? focusedDecoration,
      (false, true) => focusedDecoration,
      (false, false) => decoration,
    };

    if (d.borderRadius != null) {
      panelView = ClipRRect(borderRadius: d.borderRadius!, child: panelView);
    }

    return DecoratedBox(decoration: d, child: panelView);
  }
}
