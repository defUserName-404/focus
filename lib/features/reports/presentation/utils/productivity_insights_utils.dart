import 'dart:math' as math;

import '../../../../core/utils/date_time_utils.dart';
import '../../../../core/utils/datetime_formatter.dart';
import '../../../tasks/domain/entities/daily_session_stats.dart';
import '../providers/reports_insights_window_provider.dart';

class InsightsDateRange {
  final DateTime start;
  final DateTime end;

  const InsightsDateRange({required this.start, required this.end});
}

class InsightsBarDatum {
  final String label;
  final double focusHours;

  const InsightsBarDatum({required this.label, required this.focusHours});
}

class InsightsData {
  final List<InsightsBarDatum> bars;
  final double focusRatio;
  final double breakRatio;
  final String ratioLabel;

  const InsightsData({
    required this.bars,
    required this.focusRatio,
    required this.breakRatio,
    required this.ratioLabel,
  });
}

abstract final class ProductivityInsightsUtils {
  static InsightsDateRange dateRangeForWindow(InsightsWindowMode window) {
    final today = DateTimeUtils.dateOnly(DateTimeUtils.now());

    if (window == InsightsWindowMode.weekly) {
      final weekStart = today.subtract(Duration(days: today.weekday - DateTime.monday));
      return InsightsDateRange(start: weekStart, end: DateTimeUtils.addDays(weekStart, 6));
    }

    final monthStart = DateTime(today.year, today.month, 1);
    final monthEnd = DateTime(today.year, today.month + 1, 0);
    return InsightsDateRange(start: monthStart, end: monthEnd);
  }

  static InsightsData buildInsightsData({
    required List<DailySessionStats> stats,
    required InsightsWindowMode window,
    required InsightsDateRange range,
  }) {
    final byDate = <String, DailySessionStats>{for (final stat in stats) stat.date: stat};

    final totalSessions = stats.fold<int>(0, (sum, stat) => sum + stat.totalSessions);
    final completedSessions = stats.fold<int>(0, (sum, stat) => sum + stat.completedSessions);

    final focusRatio = totalSessions == 0 ? 0.0 : completedSessions / totalSessions;
    final breakSessions = math.max(totalSessions - completedSessions, 0);

    final bars = window == InsightsWindowMode.weekly
        ? weeklyBars(byDate: byDate, start: range.start)
        : monthlyBars(byDate: byDate, monthStart: range.start);

    return InsightsData(
      bars: bars,
      focusRatio: focusRatio,
      breakRatio: 1 - focusRatio,
      ratioLabel: formatRatio(completedSessions, breakSessions),
    );
  }

  static List<InsightsBarDatum> weeklyBars({required Map<String, DailySessionStats> byDate, required DateTime start}) {
    return List.generate(7, (index) {
      final date = DateTimeUtils.addDays(start, index);
      final dateKey = date.toShortDateKey();
      final focusSeconds = byDate[dateKey]?.focusSeconds ?? 0;
      return InsightsBarDatum(label: _shortWeekdayName(date.weekday), focusHours: focusSeconds / 3600);
    });
  }

  static List<InsightsBarDatum> monthlyBars({
    required Map<String, DailySessionStats> byDate,
    required DateTime monthStart,
  }) {
    final daysInMonth = DateTime(monthStart.year, monthStart.month + 1, 0).day;
    final leadingOffset = monthStart.weekday - 1;
    final weekCount = ((leadingOffset + daysInMonth - 1) ~/ 7) + 1;
    final weekHours = List<double>.filled(weekCount, 0);

    for (var day = 1; day <= daysInMonth; day++) {
      final date = DateTime(monthStart.year, monthStart.month, day);
      final weekIndex = (leadingOffset + day - 1) ~/ 7;
      final focusSeconds = byDate[date.toShortDateKey()]?.focusSeconds ?? 0;
      weekHours[weekIndex] += focusSeconds / 3600;
    }

    return List.generate(weekCount, (index) {
      return InsightsBarDatum(label: 'W${index + 1}', focusHours: weekHours[index]);
    });
  }

  static String formatRatio(int focusSessions, int breakSessions) {
    if (focusSessions == 0 && breakSessions == 0) return '0:0';
    if (focusSessions > 0 && breakSessions == 0) return '1:0';
    if (focusSessions == 0 && breakSessions > 0) return '0:1';

    final divisor = _gcd(focusSessions, breakSessions);
    return '${focusSessions ~/ divisor}:${breakSessions ~/ divisor}';
  }

  static int _gcd(int a, int b) {
    var x = a.abs();
    var y = b.abs();
    while (y != 0) {
      final temp = y;
      y = x % y;
      x = temp;
    }
    return x == 0 ? 1 : x;
  }

  static String _shortWeekdayName(int weekday) {
    const names = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return names[weekday - 1];
  }
}
