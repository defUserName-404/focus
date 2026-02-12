part of 'app_theme.dart';

/// ForUI theme builder utilities
///
/// Provides methods for building typography and complete theme data.
final class _ThemeBuilder {
  const _ThemeBuilder();

  /// Builds a complete ForUI theme with Manrope variable font
  ///
  /// Uses [FThemes.zinc.dark] as base and applies custom typography.
  FThemeData build({String fontFamily = 'Manrope'}) {
    final baseTheme = FThemes.zinc.dark;
    return _buildCustomStyle(colors: baseTheme.colors, fontFamily: fontFamily);
  }

  /// Builds a custom theme with specified colors and font
  ///
  /// Combines:
  /// - Custom typography with Manrope variable font
  /// - ForUI style configuration
  /// - Provided color scheme
  FThemeData _buildCustomStyle({required FColors colors, String fontFamily = 'Manrope'}) {
    final typography = _AppTypography()._buildTypography(colors: colors, fontFamily: fontFamily);
    final style = FStyle(
      borderRadius: BorderRadius.all(Radius.circular(AppConstants.border.radius.regular)),
      borderWidth: AppConstants.border.width.regular,
      formFieldStyle: FFormFieldStyle.inherit(colors: colors, typography: typography),
      focusedOutlineStyle: FFocusedOutlineStyle(
        color: colors.primary,
        borderRadius: BorderRadius.all(Radius.circular(AppConstants.border.radius.regular)),
      ),
      iconStyle: IconThemeData(color: colors.primary, size: AppConstants.size.icon.regular),
      tappableStyle: FTappableStyle(),
    );

    return FThemeData(
      colors: colors,
      typography: typography,
      style: style,
      cardStyle: cardStyle(colors: colors, typography: typography, style: style),
    );
  }
}
