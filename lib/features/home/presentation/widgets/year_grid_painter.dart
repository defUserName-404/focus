import 'package:flutter/material.dart';

import '../../../../core/common/utils/datetime_formatter.dart';
import '../../../../core/constants/date_time_constants.dart';
import '../utils/activity_graph_constants.dart';
import '../utils/activity_graph_utils.dart';

class YearGridPainter extends CustomPainter {
  final int year;
  final Map<String, int> lookup;
  final Color cellColor;
  final Color emptyColor;
  final Color textColor;
  final TextStyle textStyle;
  final String? highlightDateKey;
  final Color highlightColor;

  YearGridPainter({
    required this.year,
    required this.lookup,
    required this.cellColor,
    required this.emptyColor,
    required this.textColor,
    required this.textStyle,
    this.highlightDateKey,
    required this.highlightColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final jan1 = DateTime(year, 1, 1);
    final dec31 = DateTime(year, 12, 31);
    final totalWeeks = DateTimeExtensions.weekIndex(dec31, jan1) + 1;
    final firstMonday = DateTimeExtensions.getFirstMonday(year);

    _paintMonthLabels(canvas, jan1);
    _paintDayLabels(canvas);
    _paintCells(canvas, totalWeeks, firstMonday);
  }

  void _paintMonthLabels(Canvas canvas, DateTime jan1) {
    int lastLabelWeek = -3;
    for (int m = 1; m <= 12; m++) {
      final firstOfMonth = DateTime(year, m, 1);
      final week = DateTimeExtensions.weekIndex(firstOfMonth, jan1);
      if (week - lastLabelWeek < 2) continue;
      lastLabelWeek = week;
      final tp = TextPainter(
        text: TextSpan(
          text: DateTimeExtensions.shortMonth(m),
          style: textStyle.copyWith(color: textColor, fontSize: 9),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(ActivityGraphConstants.dayLabelWidth + week * ActivityGraphConstants.cellStep, 0));
    }
  }

  void _paintDayLabels(Canvas canvas) {
    for (final entry in DateTimeConstants.dayLabels.entries) {
      final tp = TextPainter(
        text: TextSpan(
          text: entry.value,
          style: textStyle.copyWith(color: textColor, fontSize: 9),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      final y =
          ActivityGraphConstants.monthLabelHeight +
          entry.key * ActivityGraphConstants.cellStep +
          (ActivityGraphConstants.cellSize - tp.height) / 2;
      tp.paint(canvas, Offset(0, y));
    }
  }

  void _paintCells(Canvas canvas, int totalWeeks, DateTime firstMonday) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final highlightPaint = Paint()
      ..color = highlightColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    for (int week = 0; week < totalWeeks; week++) {
      for (int dayRow = 0; dayRow < 7; dayRow++) {
        final date = firstMonday.add(Duration(days: week * 7 + dayRow));

        if (date.year != year) continue;
        if (date.isAfter(today)) continue;

        final dateKey = ActivityGraphUtils.dateKey(date);
        final sessions = lookup[dateKey] ?? 0;

        final x = ActivityGraphConstants.dayLabelWidth + week * ActivityGraphConstants.cellStep;
        final y = ActivityGraphConstants.monthLabelHeight + dayRow * ActivityGraphConstants.cellStep;

        final rect = RRect.fromRectAndRadius(
          Rect.fromLTWH(x, y, ActivityGraphConstants.cellSize, ActivityGraphConstants.cellSize),
          const Radius.circular(ActivityGraphConstants.legendCellRadius),
        );

        final color = sessions == 0
            ? emptyColor
            : cellColor.withValues(alpha: ActivityGraphUtils.getIntensity(sessions));
        canvas.drawRRect(rect, Paint()..color = color);

        if (dateKey == highlightDateKey) {
          canvas.drawRRect(rect, highlightPaint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant YearGridPainter old) =>
      lookup != old.lookup ||
      year != old.year ||
      highlightDateKey != old.highlightDateKey ||
      cellColor != old.cellColor ||
      emptyColor != old.emptyColor ||
      textColor != old.textColor ||
      highlightColor != old.highlightColor;
}
