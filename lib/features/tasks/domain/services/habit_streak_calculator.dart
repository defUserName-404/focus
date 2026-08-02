import '../entities/recurrence_rule.dart';
import 'recurrence_expander.dart';

/// Result of evaluating habit consistency against a scheduled series.
class HabitStreakResult {
  /// Consecutive completed scheduled occurrences ending at the most recent
  /// due occurrence (skips "today" when it is still open and incomplete).
  final int currentStreak;

  /// Longest run of consecutive completed scheduled occurrences in the window.
  final int longestStreak;

  /// `completed / scheduled` for occurrences in `[from, to]` (0 when none).
  final double completionRate;

  /// Scheduled occurrence count in the evaluated window.
  final int scheduledCount;

  /// Completed occurrence count overlapping the scheduled set.
  final int completedCount;

  const HabitStreakResult({
    required this.currentStreak,
    required this.longestStreak,
    required this.completionRate,
    required this.scheduledCount,
    required this.completedCount,
  });
}

/// Pure streak / consistency calculator for habit-style recurring tasks.
class HabitStreakCalculator {
  const HabitStreakCalculator._();

  /// Computes streak metrics from [completionDates] and the expanded schedule.
  ///
  /// Only days the habit was scheduled count — gaps where the rule did not
  /// fire do not break the streak.
  static HabitStreakResult calculate({
    required RecurrenceRule rule,
    required DateTime anchor,
    required Iterable<DateTime> completionDates,
    required DateTime from,
    required DateTime to,
    DateTime? now,
  }) {
    final effectiveNow = _dateOnly(now ?? DateTime.now());
    final windowFrom = _dateOnly(from);
    final windowTo = _dateOnly(to);

    final scheduled = RecurrenceExpander.expandRule(rule: rule, anchor: anchor, from: windowFrom, to: windowTo);

    final completedKeys = {for (final c in completionDates) _dateKey(_dateOnly(c))};

    final scheduledKeys = scheduled.map(_dateKey).toList();
    final completedScheduled = scheduledKeys.where(completedKeys.contains).length;
    final rate = scheduledKeys.isEmpty ? 0.0 : completedScheduled / scheduledKeys.length;

    final longest = _longestStreak(scheduledKeys, completedKeys);
    final current = _currentStreak(scheduledKeys: scheduledKeys, completedKeys: completedKeys, today: effectiveNow);

    return HabitStreakResult(
      currentStreak: current,
      longestStreak: longest,
      completionRate: rate,
      scheduledCount: scheduledKeys.length,
      completedCount: completedScheduled,
    );
  }

  static int _longestStreak(List<String> scheduledKeys, Set<String> completedKeys) {
    var best = 0;
    var run = 0;
    for (final key in scheduledKeys) {
      if (completedKeys.contains(key)) {
        run++;
        if (run > best) best = run;
      } else {
        run = 0;
      }
    }
    return best;
  }

  static int _currentStreak({
    required List<String> scheduledKeys,
    required Set<String> completedKeys,
    required DateTime today,
  }) {
    if (scheduledKeys.isEmpty) return 0;

    final todayKey = _dateKey(today);
    var endIndex = scheduledKeys.lastIndexWhere((k) => k.compareTo(todayKey) <= 0);
    if (endIndex < 0) return 0;

    // If today is scheduled but not yet completed, start from the prior occurrence.
    if (scheduledKeys[endIndex] == todayKey && !completedKeys.contains(todayKey)) {
      endIndex--;
    }
    if (endIndex < 0) return 0;

    var streak = 0;
    for (var i = endIndex; i >= 0; i--) {
      if (completedKeys.contains(scheduledKeys[i])) {
        streak++;
      } else {
        break;
      }
    }
    return streak;
  }

  static DateTime _dateOnly(DateTime dt) => DateTime(dt.year, dt.month, dt.day);

  static String _dateKey(DateTime dt) =>
      '${dt.year.toString().padLeft(4, '0')}-'
      '${dt.month.toString().padLeft(2, '0')}-'
      '${dt.day.toString().padLeft(2, '0')}';
}
