part of 'app_theme.dart';

/// ForUI theme builder utilities
///
/// Provides methods for building typography and complete theme data.
final class _ThemeBuilder {
  const _ThemeBuilder();

  /// Builds a complete ForUI theme with Manrope variable font
  ///
  /// [touch] selects ForUI's touch or desktop sizing ramp and must reflect the
  /// host platform, since it drives default control sizes and hit targets.
  FThemeData build({required bool touch, String fontFamily = 'Manrope'}) {
    return _buildCustomStyle(colors: FColors.neutralDark, touch: touch, fontFamily: fontFamily);
  }

  /// Builds a custom theme with specified colors and font
  ///
  /// Combines:
  /// - Custom typography with Manrope variable font
  /// - ForUI style configuration
  /// - Provided color scheme
  FThemeData _buildCustomStyle({required FColors colors, required bool touch, String fontFamily = 'Manrope'}) {
    final typography = _AppTypography()._buildTypography(colors: colors, fontFamily: fontFamily);
    // ForUI exposes a ramp of radii rather than a single value. Only `md`, the
    // default most widgets resolve, is overridden with the app's radius; the
    // remaining tokens (notably `pill`) keep their ForUI defaults.
    final borderRadius = FBorderRadius(md: BorderRadius.all(Radius.circular(AppConstants.border.radius.regular)));
    final style = FStyle(
      borderRadius: borderRadius,
      borderWidth: AppConstants.border.width.regular,
      formFieldStyle: FFormFieldStyle.inherit(colors: colors, typography: typography, touch: touch),
      focusedOutlineStyle: FFocusedOutlineStyle(color: colors.primary, borderRadius: borderRadius.md),
      iconStyle: IconThemeData(color: colors.primary, size: AppConstants.size.icon.regular),
      sizes: FSizes.inherit(touch: touch),
      tappableStyle: FTappableStyle(),
    );

    return FThemeData(
      colors: colors,
      touch: touch,
      typography: typography,
      style: style,
      cardStyle: cardStyle(colors: colors, typography: typography, style: style),
    );
  }
}
