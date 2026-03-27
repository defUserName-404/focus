import 'package:flutter/widgets.dart';

enum WindowSizeClass { compact, medium, expanded }

abstract final class LayoutBreakpoints {
  static const double compact = 600;
  static const double medium = 840;
  static const double expanded = 1200;

  static WindowSizeClass getWindowSizeClass(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width < compact) return WindowSizeClass.compact;
    if (width < medium) return WindowSizeClass.medium;
    return WindowSizeClass.expanded;
  }
}

abstract final class ResponsiveSpacing {
  static double small(WindowSizeClass size) => switch (size) {
    WindowSizeClass.compact => 8,
    WindowSizeClass.medium => 12,
    WindowSizeClass.expanded => 16,
  };

  static double medium(WindowSizeClass size) => switch (size) {
    WindowSizeClass.compact => 16,
    WindowSizeClass.medium => 20,
    WindowSizeClass.expanded => 24,
  };

  static double large(WindowSizeClass size) => switch (size) {
    WindowSizeClass.compact => 24,
    WindowSizeClass.medium => 32,
    WindowSizeClass.expanded => 48,
  };
}
