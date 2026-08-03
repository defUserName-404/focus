import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

import '../../constants/app_constants.dart';
import 'card_style.dart';

part 'theme_builder.dart';

part 'typography/scale.dart';

part 'typography/typography.dart';

part 'typography/weight.dart';

/// Main theme configuration class following the pattern of [LayoutConstants]
///
/// Contains all ForUI theme configuration with Manrope variable font.
/// Access through static instances:
/// - AppTheme.typography - Typography configuration (scales and weights)
/// - AppTheme.builder - Theme building utilities
abstract final class AppTheme {
  const AppTheme._();

  static const builder = _ThemeBuilder();
}

/// Theme extensions for easy access in widgets
extension AppThemeX on BuildContext {
  /// Resolves to the body typeface. ForUI splits [FTypography] into `display`
  /// and `body` typefaces; the app's scale tokens all come from `body`.
  FTypeface get typography => theme.typography.body;

  FColors get colors => theme.colors;

  FStyle get style => theme.style;

  /// Content inset for [FCard] children (ForUI 0.24 no longer pads automatically).
  EdgeInsetsGeometry get cardPadding => theme.cardStyle.padding;
}
