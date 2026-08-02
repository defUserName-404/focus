import '../entities/estimate_accuracy_stat.dart';
import '../entities/habit_consistency_stat.dart';
import '../entities/recurrence_rule.dart';
import '../entities/task_throughput_stats.dart';
import '../entities/time_breakdown_item.dart';
import 'habit_streak_calculator.dart';

/// Raw habit row used to compute [HabitConsistencyStat] for a window.
class HabitConsistencySource {
  final int taskId;
  final String title;
  final RecurrenceRule rule;
  final DateTime anchor;
  final List<DateTime> completionDates;

  const HabitConsistencySource({
    required this.taskId,
    required this.title,
    required this.rule,
    required this.anchor,
    required this.completionDates,
  });
}

/// Pure calculation helpers for Phase 6 report insights.
abstract final class ReportInsightsCalculator {
  /// Builds per-habit consistency stats via [HabitStreakCalculator].
  static List<HabitConsistencyStat> buildHabitConsistency({
    required List<HabitConsistencySource> sources,
    required DateTime from,
    required DateTime to,
    DateTime? now,
  }) {
    final effectiveNow = now ?? DateTime.now();
    final stats = <HabitConsistencyStat>[];
    for (final source in sources) {
      final result = HabitStreakCalculator.calculate(
        rule: source.rule,
        anchor: source.anchor,
        completionDates: source.completionDates,
        from: from,
        to: to,
        now: effectiveNow,
      );
      stats.add(
        HabitConsistencyStat(
          taskId: source.taskId,
          title: source.title,
          completionRate: result.completionRate,
          currentStreak: result.currentStreak,
          longestStreak: result.longestStreak,
          scheduledCount: result.scheduledCount,
          completedCount: result.completedCount,
        ),
      );
    }
    stats.sort((a, b) {
      final rateCmp = b.completionRate.compareTo(a.completionRate);
      if (rateCmp != 0) return rateCmp;
      return a.title.toLowerCase().compareTo(b.title.toLowerCase());
    });
    return stats;
  }

  /// Aggregates estimate bias: positive ratio means typical underestimate.
  static EstimateAccuracySummary buildEstimateAccuracy(List<EstimateAccuracyStat> tasks) {
    if (tasks.isEmpty) {
      return const EstimateAccuracySummary(tasks: [], typicalBiasRatio: 0);
    }
    var totalEstimated = 0;
    var totalActual = 0;
    for (final task in tasks) {
      totalEstimated += task.estimatedMinutes;
      totalActual += task.actualMinutes;
    }
    final bias = totalEstimated == 0 ? 0.0 : (totalActual - totalEstimated) / totalEstimated;
    final sorted = [...tasks]..sort((a, b) => b.deltaRatio.abs().compareTo(a.deltaRatio.abs()));
    return EstimateAccuracySummary(tasks: sorted, typicalBiasRatio: bias);
  }

  /// Groups daily completion counts into day or week buckets for the window.
  static List<ThroughputBucket> buildThroughputBuckets({
    required Map<String, int> completedByDate,
    required DateTime from,
    required DateTime to,
    required bool weeklyWindow,
  }) {
    if (weeklyWindow) {
      return _dailyBuckets(completedByDate: completedByDate, from: from, to: to);
    }
    return _weeklyBuckets(completedByDate: completedByDate, from: from, to: to);
  }

  static TaskThroughputStats buildThroughputStats({
    required Map<String, int> completedByDate,
    required DateTime from,
    required DateTime to,
    required bool weeklyWindow,
    required double? averageCycleSeconds,
    required int cycleSampleCount,
  }) {
    return TaskThroughputStats(
      buckets: buildThroughputBuckets(completedByDate: completedByDate, from: from, to: to, weeklyWindow: weeklyWindow),
      averageCycleSeconds: averageCycleSeconds,
      cycleSampleCount: cycleSampleCount,
    );
  }

  /// Normalizes breakdown items and drops zero-second rows.
  static List<TimeBreakdownItem> normalizeBreakdown(List<TimeBreakdownItem> items) {
    final filtered = items.where((item) => item.focusSeconds > 0).toList()
      ..sort((a, b) => b.focusSeconds.compareTo(a.focusSeconds));
    return filtered;
  }

  /// Builds a CSV document for the current report window.
  static String buildCsvExport({
    required String windowLabel,
    required String startDate,
    required String endDate,
    required List<HabitConsistencyStat> habits,
    required EstimateAccuracySummary estimates,
    required List<TimeBreakdownItem> byProject,
    required List<TimeBreakdownItem> byTag,
    required TaskThroughputStats throughput,
  }) {
    final buffer = StringBuffer();
    buffer.writeln('section,key,value,extra');
    buffer.writeln(_csvRow(['meta', 'window', windowLabel, '']));
    buffer.writeln(_csvRow(['meta', 'start_date', startDate, '']));
    buffer.writeln(_csvRow(['meta', 'end_date', endDate, '']));
    for (final habit in habits) {
      buffer.writeln(
        _csvRow([
          'habit_consistency',
          habit.title,
          (habit.completionRate * 100).toStringAsFixed(1),
          'streak=${habit.currentStreak};longest=${habit.longestStreak};completed=${habit.completedCount}/${habit.scheduledCount}',
        ]),
      );
    }
    buffer.writeln(
      _csvRow([
        'estimate_accuracy',
        'typical_bias_percent',
        (estimates.typicalBiasRatio * 100).toStringAsFixed(1),
        estimates.typicalBiasRatio >= 0 ? 'underestimate' : 'overestimate',
      ]),
    );
    for (final task in estimates.tasks) {
      buffer.writeln(
        _csvRow(['estimate_accuracy', task.title, task.actualMinutes.toString(), 'estimated=${task.estimatedMinutes}']),
      );
    }
    for (final item in byProject) {
      buffer.writeln(_csvRow(['time_by_project', item.name, item.focusMinutes.toString(), 'minutes']));
    }
    for (final item in byTag) {
      buffer.writeln(_csvRow(['time_by_tag', item.name, item.focusMinutes.toString(), 'minutes']));
    }
    for (final bucket in throughput.buckets) {
      buffer.writeln(_csvRow(['throughput', bucket.label, bucket.completedCount.toString(), bucket.periodKey]));
    }
    if (throughput.averageCycleHours != null) {
      buffer.writeln(
        _csvRow([
          'throughput',
          'average_cycle_hours',
          throughput.averageCycleHours!.toStringAsFixed(2),
          'samples=${throughput.cycleSampleCount}',
        ]),
      );
    }
    return buffer.toString();
  }

  static List<ThroughputBucket> _dailyBuckets({
    required Map<String, int> completedByDate,
    required DateTime from,
    required DateTime to,
  }) {
    const names = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final buckets = <ThroughputBucket>[];
    var cursor = DateTime(from.year, from.month, from.day);
    final end = DateTime(to.year, to.month, to.day);
    while (!cursor.isAfter(end)) {
      final key = _dateKey(cursor);
      buckets.add(
        ThroughputBucket(label: names[cursor.weekday - 1], periodKey: key, completedCount: completedByDate[key] ?? 0),
      );
      cursor = cursor.add(const Duration(days: 1));
    }
    return buckets;
  }

  static List<ThroughputBucket> _weeklyBuckets({
    required Map<String, int> completedByDate,
    required DateTime from,
    required DateTime to,
  }) {
    final monthStart = DateTime(from.year, from.month, 1);
    final daysInMonth = DateTime(from.year, from.month + 1, 0).day;
    final leadingOffset = monthStart.weekday - 1;
    final weekCount = ((leadingOffset + daysInMonth - 1) ~/ 7) + 1;
    final counts = List<int>.filled(weekCount, 0);
    final end = DateTime(to.year, to.month, to.day);
    var cursor = DateTime(from.year, from.month, from.day);
    while (!cursor.isAfter(end)) {
      if (cursor.month == from.month) {
        final weekIndex = (leadingOffset + cursor.day - 1) ~/ 7;
        counts[weekIndex] += completedByDate[_dateKey(cursor)] ?? 0;
      }
      cursor = cursor.add(const Duration(days: 1));
    }
    return List.generate(
      weekCount,
      (index) => ThroughputBucket(label: 'W${index + 1}', periodKey: 'W${index + 1}', completedCount: counts[index]),
    );
  }

  static String _dateKey(DateTime dt) =>
      '${dt.year.toString().padLeft(4, '0')}-'
      '${dt.month.toString().padLeft(2, '0')}-'
      '${dt.day.toString().padLeft(2, '0')}';

  static String _csvRow(List<String> cells) {
    return cells.map(_escapeCsv).join(',');
  }

  static String _escapeCsv(String value) {
    if (value.contains(',') || value.contains('"') || value.contains('\n')) {
      return '"${value.replaceAll('"', '""')}"';
    }
    return value;
  }
}
