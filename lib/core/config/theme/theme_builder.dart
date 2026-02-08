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
    return buildCustom(colors: baseTheme.colors, fontFamily: fontFamily);
  }

  /// Builds a custom theme with specified colors and font
  ///
  /// Combines:
  /// - Custom typography with Manrope variable font
  /// - ForUI style configuration
  /// - Provided color scheme
  FThemeData buildCustom({required FColors colors, String fontFamily = 'Manrope'}) {
    final typography = _buildTypography(colors: colors, fontFamily: fontFamily);
    final style = _buildStyle(colors: colors, typography: typography);

    return FThemeData(colors: colors, typography: typography, style: style);
  }

  /// Builds typography scales with Manrope variable font
  ///
  /// Creates 10 text styles (xs → xl6) following Tailwind CSS conventions.
  /// Each style includes:
  /// - Font family (Manrope)
  /// - Font size and line height
  /// - Appropriate font weight variation
  /// - Theme foreground color
  FTypography _buildTypography({required FColors colors, String fontFamily = 'Manrope'}) {
    final scale = AppTheme.typography.scale;
    final weight = AppTheme.typography.weight;

    return FTypography(
      // Extra small - 12px
      xs: TextStyle(
        color: colors.foreground,
        fontFamily: fontFamily,
        fontSize: scale.xs,
        height: scale.lineHeightTight,
        fontVariations: [FontVariation('wght', weight.normal)],
      ),

      // Small - 14px
      sm: TextStyle(
        color: colors.foreground,
        fontFamily: fontFamily,
        fontSize: scale.sm,
        height: scale.lineHeightNormal,
        fontVariations: [FontVariation('wght', weight.normal)],
      ),

      // Base - 16px (default)
      base: TextStyle(
        color: colors.foreground,
        fontFamily: fontFamily,
        fontSize: scale.base,
        height: scale.lineHeightRelaxed,
        fontVariations: [FontVariation('wght', weight.normal)],
      ),

      // Large - 18px
      lg: TextStyle(
        color: colors.foreground,
        fontFamily: fontFamily,
        fontSize: scale.lg,
        height: scale.lineHeightLoose,
        fontVariations: [FontVariation('wght', weight.normal)],
      ),

      // Extra Large - 20px (medium weight)
      xl: TextStyle(
        color: colors.foreground,
        fontFamily: fontFamily,
        fontSize: scale.xl,
        height: scale.lineHeightLoose,
        fontVariations: [FontVariation('wght', weight.medium)],
      ),

      // 2XL - 24px (semibold)
      xl2: TextStyle(
        color: colors.foreground,
        fontFamily: fontFamily,
        fontSize: scale.xl2,
        height: scale.lineHeightLoosest,
        fontVariations: [FontVariation('wght', weight.semibold)],
      ),

      // 3XL - 30px (semibold)
      xl3: TextStyle(
        color: colors.foreground,
        fontFamily: fontFamily,
        fontSize: scale.xl3,
        height: scale.lineHeightWide,
        fontVariations: [FontVariation('wght', weight.semibold)],
      ),

      // 4XL - 36px (bold)
      xl4: TextStyle(
        color: colors.foreground,
        fontFamily: fontFamily,
        fontSize: scale.xl4,
        height: scale.lineHeightWider,
        fontVariations: [FontVariation('wght', weight.bold)],
      ),

      // 5XL - 48px (bold)
      xl5: TextStyle(
        color: colors.foreground,
        fontFamily: fontFamily,
        fontSize: scale.xl5,
        height: scale.lineHeightTighter,
        fontVariations: [FontVariation('wght', weight.bold)],
      ),

      // 6XL - 60px (bold)
      xl6: TextStyle(
        color: colors.foreground,
        fontFamily: fontFamily,
        fontSize: scale.xl6,
        height: scale.lineHeightTighter,
        fontVariations: [FontVariation('wght', weight.bold)],
      ),
    );
  }

  /// Builds ForUI style configuration with defaults
  ///
  /// Includes:
  /// - Border radius and width
  /// - Form field styling
  /// - Focused outline styling
  /// - Icon configuration
  FStyle _buildStyle({required FColors colors, required FTypography typography}) => FStyle(
    borderRadius: const BorderRadius.all(Radius.circular(8)),
    borderWidth: 1,
    formFieldStyle: FFormFieldStyle.inherit(colors: colors, typography: typography),
    focusedOutlineStyle: FFocusedOutlineStyle(
      color: colors.primary,
      borderRadius: const BorderRadius.all(Radius.circular(8)),
    ),
    iconStyle: IconThemeData(color: colors.primary, size: 20),
    tappableStyle: FTappableStyle(),
  );
}
