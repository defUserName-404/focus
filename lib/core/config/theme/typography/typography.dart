part of '../app_theme.dart';

/// Typography configuration containing scales and weights
/// 
/// Groups all typography-related constants including font sizes,
/// line heights, and font weights for the Manrope variable font.
final class _AppTypography {
  const _AppTypography();

  /// Typography scale constants based on Tailwind CSS
  /// 
  /// Provides font sizes (xs → xl6) and line heights for consistent typography.
  final scale = const _ThemeScale();

  /// Font weight constants for variable font (Manrope)
  /// 
  /// Standard font weight values from 100 (thin) to 900 (black).
  /// Used with [FontVariation] for dynamic weight control.
  final weight = const _ThemeWeight();
}
