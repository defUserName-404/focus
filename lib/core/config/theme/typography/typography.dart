part of '../app_theme.dart';

/// Typography configuration containing scales and weights
///
/// Groups all typography-related constants including font sizes,
/// line heights, and font weights for the Manrope variable font.
final class _AppTypography {
  const _AppTypography();

  /// Builds typography scales with Manrope variable font
  ///
  /// Creates 10 text styles (xs → xl6) following Tailwind CSS conventions.
  /// Each style includes:
  /// - Font family (Manrope)
  /// - Font size and line height
  /// - Appropriate font weight variation
  /// - Theme foreground color
  FTypography _buildTypography({required FColors colors, String fontFamily = 'Manrope'}) {
    final scale = _AppTypographyScale();
    final weight = _AppTypographyWeight();

    final base = TextStyle(
      color: colors.foreground,
      fontFamily: fontFamily,
      fontSize: scale.base,
      height: scale.lineHeightRelaxed,
      fontVariations: [FontVariation('wght', weight.normal)],
    );

    return FTypography(
      // Extra small - 12px
      xs: base.copyWith(fontSize: scale.xs, height: scale.lineHeightTight),

      // Small - 14px
      sm: base.copyWith(fontSize: scale.sm, height: scale.lineHeightNormal),

      // Base - 16px (default)
      base: base.copyWith(fontSize: scale.base, height: scale.lineHeightRelaxed),

      // Large - 18px
      lg: base.copyWith(fontSize: scale.lg, height: scale.lineHeightLoose),

      // Extra Large - 20px (medium weight)
      xl: base.copyWith(
        fontSize: scale.xl,
        height: scale.lineHeightLoose,
        fontVariations: [FontVariation('wght', weight.medium)],
      ),

      // 2XL - 24px (semibold)
      xl2: base.copyWith(
        fontSize: scale.xl2,
        height: scale.lineHeightLoosest,
        fontVariations: [FontVariation('wght', weight.semibold)],
      ),

      // 3XL - 30px (semibold)
      xl3: base.copyWith(
        fontSize: scale.xl3,
        height: scale.lineHeightWide,
        fontVariations: [FontVariation('wght', weight.semibold)],
      ),

      // 4XL - 36px (bold)
      xl4: base.copyWith(
        fontSize: scale.xl4,
        height: scale.lineHeightWider,
        fontVariations: [FontVariation('wght', weight.bold)],
      ),

      // 5XL - 48px (bold)
      xl5: base.copyWith(
        fontSize: scale.xl5,
        height: scale.lineHeightTighter,
        fontVariations: [FontVariation('wght', weight.bold)],
      ),

      // 6XL - 60px (bold)
      xl6: base.copyWith(
        fontSize: scale.xl6,
        height: scale.lineHeightTighter,
        fontVariations: [FontVariation('wght', weight.bold)],
      ),
    );
  }
}
