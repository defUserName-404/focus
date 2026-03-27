import 'package:flutter/widgets.dart';

import '../constants/layout_breakpoints.dart';

class ResponsiveLayout extends StatelessWidget {
  final Widget compact;
  final Widget? medium;
  final Widget expanded;

  const ResponsiveLayout({super.key, required this.compact, this.medium, required this.expanded});

  @override
  Widget build(BuildContext context) {
    final sizeClass = LayoutBreakpoints.getWindowSizeClass(context);
    return switch (sizeClass) {
      WindowSizeClass.compact => compact,
      WindowSizeClass.medium => medium ?? expanded,
      WindowSizeClass.expanded => expanded,
    };
  }
}
