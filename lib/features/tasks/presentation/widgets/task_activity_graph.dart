import 'package:flutter/material.dart';

import '../../../../core/config/theme/app_theme.dart';
import '../../../../core/constants/app_constants.dart';

/// GitHub-style activity heatmap showing daily focus minutes.
///
/// Each cell represents one day. Color intensity reflects the amount
/// of focus time logged on that day. Shows the last [weeksToShow] weeks.
class TaskActivityGraph extends StatelessWidget {
  final Map<DateTime, int> dailyFocusMinutes;
  final int weeksToShow;

  const TaskActivityGraph({
    super.key,
    required this.dailyFocusMinutes,
    this.weeksToShow = 16,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Activity',
          style: context.typography.sm.copyWith(
            fontWeight: FontWeight.w600,
            color: context.colors.foreground,
          ),
        ),
        SizedBox(height: AppConstants.spacing.regular),
        _buildLegend(context),
        SizedBox(height: AppConstants.spacing.small),
        SizedBox(
          height: _graphHeight,
          child: LayoutBuilder(
            builder: (context, constraints) {
              return CustomPaint(
                size: Size(constraints.maxWidth, _graphHeight),
                painter: _ActivityGraphPainter(
                  data: dailyFocusMinutes,
                  weeksToShow: weeksToShow,
                  cellColor: context.colors.primary,
                  emptyColor:
                      context.colors.mutedForeground.withValues(alpha: 0.12),
                  textColor: context.colors.mutedForeground,
                  textStyle: context.typography.xs,
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  double get _graphHeight => 7 * (_cellSize + _cellGap) - _cellGap;
  static const double _cellSize = 12;
  static const double _cellGap = 3;

  Widget _buildLegend(BuildContext context) {
    final emptyColor = context.colors.mutedForeground.withValues(alpha: 0.12);
    final cellColor = context.colors.primary;
    final levels = [
      emptyColor,
      cellColor.withValues(alpha: 0.25),
      cellColor.withValues(alpha: 0.50),
      cellColor.withValues(alpha: 0.75),
      cellColor,
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(
          'Less',
          style: context.typography.xs
              .copyWith(color: context.colors.mutedForeground),
        ),
        SizedBox(width: AppConstants.spacing.small),
        ...levels.map(
          (color) => Container(
            width: 10,
            height: 10,
            margin: const EdgeInsets.only(right: 2),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
        SizedBox(width: AppConstants.spacing.small),
        Text(
          'More',
          style: context.typography.xs
              .copyWith(color: context.colors.mutedForeground),
        ),
      ],
    );
  }
}

// ── Custom Painter ──────────────────────────────────────────────────────────

class _ActivityGraphPainter extends CustomPainter {
  final Map<DateTime, int> data;
  final int weeksToShow;
  final Color cellColor;
  final Color emptyColor;
  final Color textColor;
  final TextStyle textStyle;

  static const double cellSize = 12;
  static const double cellGap = 3;
  static const double cellRadius = 2;
  static const double labelWidth = 24;

  _ActivityGraphPainter({
    required this.data,
    required this.weeksToShow,
    required this.cellColor,
    required this.emptyColor,
    required this.textColor,
    required this.textStyle,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Start from the beginning of the week containing (today - weeksToShow*7)
    final rawStart = today.subtract(Duration(days: weeksToShow * 7 - 1));
    final daysToMonday = (rawStart.weekday - 1) % 7;
    final startDate = rawStart.subtract(Duration(days: daysToMonday));

    // Draw day labels (M, W, F)
    const dayLabels = {1: 'M', 3: 'W', 5: 'F'};
    for (final entry in dayLabels.entries) {
      final tp = TextPainter(
        text: TextSpan(
          text: entry.value,
          style: textStyle.copyWith(
            color: textColor,
            fontSize: 9,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      final y = entry.key * (cellSize + cellGap) + (cellSize - tp.height) / 2;
      tp.paint(canvas, Offset(0, y));
    }

    // Draw cells
    for (int week = 0; week < weeksToShow; week++) {
      for (int day = 0; day < 7; day++) {
        final date = startDate.add(Duration(days: week * 7 + day));

        // Don't draw future dates
        if (date.isAfter(today)) continue;

        final dayKey =
            DateTime(date.year, date.month, date.day);
        final minutes = data[dayKey] ?? 0;

        final x = labelWidth + week * (cellSize + cellGap);
        final y = day * (cellSize + cellGap);

        final color = minutes == 0
            ? emptyColor
            : cellColor.withValues(alpha: _intensityForMinutes(minutes));

        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(x, y, cellSize, cellSize),
            const Radius.circular(cellRadius),
          ),
          Paint()..color = color,
        );
      }
    }
  }

  double _intensityForMinutes(int minutes) {
    if (minutes <= 0) return 0;
    if (minutes <= 15) return 0.25;
    if (minutes <= 30) return 0.50;
    if (minutes <= 60) return 0.75;
    return 1.0;
  }

  @override
  bool shouldRepaint(covariant _ActivityGraphPainter old) =>
      data != old.data || weeksToShow != old.weeksToShow;
}
