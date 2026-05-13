import 'dart:math' as math;
import 'package:flutter/widgets.dart';
import 'package:simple_floating_panel/simple_floating_panel.dart';

class PanelGridFlowDelegate extends FlowDelegate {
  final Animation<double>? animation;
  final List<PanelEntry> entries;
  final PanelPreviewStyle style;
  final PanelConstraints panelConstraints;

  PanelGridFlowDelegate({this.animation, required this.entries, required this.panelConstraints, required this.style})
      : super(repaint: animation) {
    _computePanelTargetGeometries(panelConstraints.maximumGeometry);
  }

  @override
  void paintChildren(FlowPaintingContext context) {
    _computePanelTargetGeometries(panelConstraints.maximumGeometry);

    for (int i = 0; i < context.childCount; i++) {
      final entry = entries[i];
      final from = entry.controller.value.geometry.rect;
      final to = _targetGeometries?[entry.id]?.rect ?? from;

      final topleft = Offset.lerp(from.topLeft, to.topLeft, animation?.value ?? 1)!;

      final transform = Matrix4.identity()..translateByDouble(topleft.dx, topleft.dy, 0, 1);

      context.paintChild(i, transform: transform);
    }
  }

  @override
  bool shouldRepaint(covariant PanelGridFlowDelegate oldDelegate) {
    return oldDelegate.animation != animation ||
        oldDelegate.entries != entries ||
        oldDelegate.panelConstraints != panelConstraints ||
        oldDelegate.style != style;
  }

  @override
  BoxConstraints getConstraintsForChild(int i, BoxConstraints constraints) {
    _computePanelTargetGeometries(panelConstraints.maximumGeometry);
    final entry = entries[i];
    final geometry = _targetGeometries?[entry.id] ?? entry.controller.value.geometry;

    return BoxConstraints.tight(geometry.size);
  }

  Map<Object, PanelGeometry>? _targetGeometries;

  void _computePanelTargetGeometries(PanelGeometry panelGeometry) {
    if (_targetGeometries != null) return;

    final availableSpace = Size(
      panelGeometry.size.width - (style.padding?.horizontal ?? 0),
      panelGeometry.size.height - (style.padding?.vertical ?? 0),
    );

    final column = entries.isNotEmpty ? math.sqrt(entries.length).ceil() : 0;
    final row = entries.isNotEmpty ? (entries.length / column).ceil() : 0;

    final panelGeometries = <Object, PanelGeometry>{};

    final itemHeight = (availableSpace.height - style.verticalSpacing * (row - 1)) / (row == 0 ? 1 : row);

    for (int h = 0; h < row; h++) {
      final totalWidth = availableSpace.width - style.horizontalSpacing * (column - 1);
      final itemCountInRow = style.expandLastRow ? math.min(column, entries.length - h * column) : column;

      final avgWidth = totalWidth / (itemCountInRow == 0 ? 1 : itemCountInRow);

      for (int w = 0; w < column; w++) {
        final index = h * column + w;
        if (index >= entries.length) {
          break;
        }

        final left = w * (style.horizontalSpacing + avgWidth);
        final top = h * (style.verticalSpacing + itemHeight);

        panelGeometries[entries[index].id] = PanelGeometry(
          origin: Offset(left, top) + (style.padding?.topLeft ?? Offset.zero),
          size: Size(avgWidth, itemHeight),
        );
      }
    }

    _targetGeometries = panelGeometries;
  }
}
