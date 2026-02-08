part of '../app_theme.dart';

/// Typography scale constants based on Tailwind CSS
/// 
/// Provides font sizes (xs → xl6) and line heights for consistent typography.
final class _ThemeScale {
  const _ThemeScale();

  // Font sizes (pixels)
  final double xs = 12;
  final double sm = 14;
  final double base = 16;
  final double lg = 18;
  final double xl = 20;
  final double xl2 = 24;
  final double xl3 = 30;
  final double xl4 = 36;
  final double xl5 = 48;
  final double xl6 = 60;

  // Line heights (as multipliers)
  final double lineHeightTight = 1.0;
  final double lineHeightTighter = 1.0;
  final double lineHeightNormal = 1.25;
  final double lineHeightRelaxed = 1.5;
  final double lineHeightLoose = 1.75;
  final double lineHeightLoosest = 2.0;
  final double lineHeightWide = 1.33;
  final double lineHeightWider = 1.11;
}
