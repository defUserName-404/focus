import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

part 'typography/typography.dart';
part 'typography/scale.dart';
part 'typography/weight.dart';
part 'theme_builder.dart';

/// Main theme configuration class following the pattern of [LayoutConstants]
///
/// Contains all ForUI theme configuration with Manrope variable font.
/// Access through static instances:
/// - AppTheme.typography - Typography configuration (scales and weights)
/// - AppTheme.builder - Theme building utilities
abstract final class AppTheme {
  const AppTheme._();

  static const typography = _AppTypography();
  static const builder = _ThemeBuilder();
}

/// Theme extensions for easy access in widgets
extension AppThemeX on BuildContext {
  FTypography get typography => theme.typography;
  FColors get colors => theme.colors;
  FStyle get style => theme.style;
}
