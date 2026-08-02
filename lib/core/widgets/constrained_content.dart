import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import '../utils/platform_utils.dart';

/// Centers content with a max width and padding.
///
/// When [maxWidth] is left at [defaultMaxWidth] (800), width is resolved from
/// form factor:
///  - compact: unconstrained (full parent width)
///  - expanded: `min(1120, viewportWidth * 0.72)`
///
/// Explicit [maxWidth] values (including [double.infinity] for embedded panes)
/// are honored as-is.
class ConstrainedContent extends StatelessWidget {
  static const double defaultMaxWidth = 800;

  final Widget child;
  final double maxWidth;
  final EdgeInsets padding;

  const ConstrainedContent({
    super.key,
    required this.child,
    this.maxWidth = defaultMaxWidth,
    this.padding = const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
  });

  double _resolveMaxWidth(BuildContext context) {
    if (maxWidth != defaultMaxWidth) return maxWidth;
    if (context.isCompact) return double.infinity;
    final viewportWidth = MediaQuery.sizeOf(context).width;
    return math.min(1120.0, viewportWidth * 0.72);
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: _resolveMaxWidth(context)),
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}
