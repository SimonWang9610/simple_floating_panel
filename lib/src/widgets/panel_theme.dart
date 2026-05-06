import 'package:flutter/widgets.dart';

import '../models/config.dart';

class PanelTheme extends InheritedWidget {
  final PanelConfig config;

  const PanelTheme({
    super.key,
    required this.config,
    required super.child,
  });

  static PanelConfig of(BuildContext context) {
    final PanelTheme? theme = context.dependOnInheritedWidgetOfExactType<PanelTheme>();
    return theme?.config ?? const PanelConfig();
  }

  @override
  bool updateShouldNotify(covariant PanelTheme oldWidget) {
    return config != oldWidget.config;
  }
}
