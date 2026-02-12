abstract final class ActivityGraphConstants {
  static const double cellSize = 12;
  static const double cellGap = 3;
  static const double cellStep = cellSize + cellGap;
  static const double dayLabelWidth = 24;
  static const double monthLabelHeight = 16;
  static const double graphHeight = 7 * cellStep - cellGap;

  static const double tooltipWidth = 140.0;
  static const double tooltipHeight = 40.0;
  static const double tooltipHorizontalPadding = 8.0;
  static const double tooltipBottomMargin = 12.0;
  static const Duration tooltipDuration = Duration(seconds: 2);

  static const int startYear = 2020;
  static const double yearDropdownWidth = 100;
  static const double yearDropdownIconSize = 16;

  static const double legendCellSize = 10;
  static const double legendCellMargin = 2;
  static const double legendCellRadius = 2;

  static double getIntensity(int sessions) {
    if (sessions <= 0) return 0;
    if (sessions == 1) return 0.25;
    if (sessions == 2) return 0.50;
    if (sessions <= 4) return 0.75;
    return 1.0;
  }
}
