import '../entities/recurrence_rule.dart';
import '../entities/task.dart';

/// Pure expander: materialises occurrence datetimes for a recurring [Task]
/// inside an inclusive `[from, to]` window without writing to the database.
class RecurrenceExpander {
  const RecurrenceExpander._();

  /// Expands [task] occurrences whose calendar date falls in `[from, to]`
  /// (inclusive, compared at local date granularity).
  ///
  /// Returns an empty list when the task has no [Task.recurrenceRule].
  /// Each occurrence keeps the wall-clock time of [Task.recurrenceAnchorDate]
  /// (falling back to [Task.startDate], then midnight).
  static List<DateTime> expand(Task task, DateTime from, DateTime to) {
    final rule = task.recurrenceRule;
    if (rule == null) return const [];

    final anchor = _dateOnly(task.recurrenceAnchorDate ?? task.startDate ?? task.createdAt);
    final windowStart = _dateOnly(from);
    final windowEnd = _dateOnly(to);
    if (windowEnd.isBefore(windowStart)) return const [];

    final timeSource = task.recurrenceAnchorDate ?? task.startDate;
    final hour = timeSource?.hour ?? 0;
    final minute = timeSource?.minute ?? 0;
    final second = timeSource?.second ?? 0;

    final dates = expandRule(rule: rule, anchor: anchor, from: windowStart, to: windowEnd);
    return [
      for (final d in dates) DateTime(d.year, d.month, d.day, hour, minute, second),
    ];
  }

  /// Expands a bare [rule] + [anchor] into date-only occurrence datetimes.
  static List<DateTime> expandRule({
    required RecurrenceRule rule,
    required DateTime anchor,
    required DateTime from,
    required DateTime to,
  }) {
    final seriesAnchor = _dateOnly(anchor);
    final windowStart = _dateOnly(from);
    final windowEnd = _dateOnly(to);
    if (windowEnd.isBefore(windowStart)) return const [];

    final until = rule.until != null ? _dateOnly(rule.until!) : null;
    final maxCount = rule.count;
    final interval = rule.effectiveInterval;

    final all = <DateTime>[];

    switch (rule.frequency) {
      case RecurrenceFrequency.daily:
        all.addAll(_dailySeries(seriesAnchor, until, interval, maxCount, windowEnd));
      case RecurrenceFrequency.weekly:
        all.addAll(_weeklySeries(rule, seriesAnchor, until, interval, maxCount, windowEnd));
      case RecurrenceFrequency.monthly:
        all.addAll(_monthlySeries(rule, seriesAnchor, until, interval, maxCount, windowEnd));
    }

    return [
      for (final d in all)
        if (!d.isBefore(windowStart) && !d.isAfter(windowEnd)) d,
    ];
  }

  static List<DateTime> _dailySeries(
    DateTime anchor,
    DateTime? until,
    int interval,
    int? maxCount,
    DateTime windowEnd,
  ) {
    final out = <DateTime>[];
    var cursor = anchor;
    final hardEnd = until != null && until.isBefore(windowEnd) ? until : windowEnd;
    // Bound iteration even when until/count are open-ended.
    final maxSteps = maxCount ?? ((hardEnd.difference(anchor).inDays ~/ interval) + 2).clamp(1, 40000);

    for (var i = 0; i < maxSteps; i++) {
      if (until != null && cursor.isAfter(until)) break;
      out.add(cursor);
      if (maxCount != null && out.length >= maxCount) break;
      cursor = cursor.add(Duration(days: interval));
      if (cursor.isAfter(hardEnd) && (maxCount == null || out.length >= maxCount)) {
        // Still continue if we need more for count but hardEnd passed — count wins.
        if (maxCount == null) break;
      }
      if (maxCount == null && cursor.isAfter(hardEnd)) break;
    }
    return out;
  }

  static List<DateTime> _weeklySeries(
    RecurrenceRule rule,
    DateTime anchor,
    DateTime? until,
    int interval,
    int? maxCount,
    DateTime windowEnd,
  ) {
    final weekdays = (rule.byWeekday == null || rule.byWeekday!.isEmpty)
        ? <int>[anchor.weekday]
        : (List<int>.from(rule.byWeekday!)..sort());

    final anchorWeekStart = anchor.subtract(Duration(days: anchor.weekday - DateTime.monday));
    final hardEnd = until != null && until.isBefore(windowEnd) ? until : windowEnd;
    final weeksSpan = (hardEnd.difference(anchorWeekStart).inDays ~/ 7) + 2;
    final maxWeeks = maxCount != null ? (maxCount * interval + weekdays.length) : weeksSpan.clamp(1, 6000);

    final out = <DateTime>[];
    for (var weekOffset = 0; weekOffset < maxWeeks; weekOffset++) {
      if (weekOffset % interval != 0) continue;
      final weekStart = anchorWeekStart.add(Duration(days: weekOffset * 7));
      for (final weekday in weekdays) {
        final day = weekStart.add(Duration(days: weekday - DateTime.monday));
        if (day.isBefore(anchor)) continue;
        if (until != null && day.isAfter(until)) return out;
        out.add(day);
        if (maxCount != null && out.length >= maxCount) return out;
      }
      if (maxCount == null && weekStart.isAfter(hardEnd)) break;
    }
    return out;
  }

  static List<DateTime> _monthlySeries(
    RecurrenceRule rule,
    DateTime anchor,
    DateTime? until,
    int interval,
    int? maxCount,
    DateTime windowEnd,
  ) {
    final targetDay = rule.byMonthDay ?? anchor.day;
    final hardEnd = until != null && until.isBefore(windowEnd) ? until : windowEnd;
    final monthsSpan = (hardEnd.year - anchor.year) * 12 + (hardEnd.month - anchor.month) + 2;
    final maxMonths = maxCount != null ? maxCount * interval : monthsSpan.clamp(1, 2400);

    final out = <DateTime>[];
    for (var monthOffset = 0; monthOffset < maxMonths; monthOffset++) {
      if (monthOffset % interval != 0) continue;
      final candidate = _addMonthsClamped(anchor, monthOffset, targetDay);
      if (candidate.isBefore(anchor)) continue;
      if (until != null && candidate.isAfter(until)) break;
      out.add(candidate);
      if (maxCount != null && out.length >= maxCount) break;
      if (maxCount == null && candidate.isAfter(hardEnd)) break;
    }
    return out;
  }

  /// Adds [months] to [anchor]'s year/month, clamping day to [targetDay] or last day.
  static DateTime _addMonthsClamped(DateTime anchor, int months, int targetDay) {
    final totalMonths = anchor.year * 12 + (anchor.month - 1) + months;
    final year = totalMonths ~/ 12;
    final month = totalMonths % 12 + 1;
    final lastDay = DateTime(year, month + 1, 0).day;
    final day = targetDay.clamp(1, lastDay);
    return DateTime(year, month, day);
  }

  static DateTime _dateOnly(DateTime dt) => DateTime(dt.year, dt.month, dt.day);
}
