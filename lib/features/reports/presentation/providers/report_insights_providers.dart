import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/datetime_formatter.dart';
import '../../../tasks/domain/entities/estimate_accuracy_stat.dart';
import '../../../tasks/domain/entities/habit_consistency_stat.dart';
import '../../../tasks/domain/entities/task_throughput_stats.dart';
import '../../../tasks/domain/entities/time_breakdown_item.dart';
import '../../../tasks/presentation/providers/task_stats_provider.dart';
import '../utils/productivity_insights_utils.dart';
import 'reports_insights_window_provider.dart';

String _rangeKeyForWindow(InsightsWindowMode window) {
  final range = ProductivityInsightsUtils.dateRangeForWindow(window);
  return '${range.start.toShortDateKey()}|${range.end.toShortDateKey()}';
}

({String start, String end, bool weekly}) _parseRange(String rangeKey, InsightsWindowMode window) {
  final parts = rangeKey.split('|');
  return (start: parts[0], end: parts[1], weekly: window == InsightsWindowMode.weekly);
}

/// Habit consistency for the selected insights window.
final habitConsistencyProvider = StreamProvider.autoDispose<List<HabitConsistencyStat>>((ref) {
  final window = ref.watch(reportsInsightsWindowProvider).value ?? InsightsWindowMode.weekly;
  final rangeKey = _rangeKeyForWindow(window);
  final parsed = _parseRange(rangeKey, window);
  final repository = ref.watch(taskStatsRepositoryProvider);
  return repository.watchHabitConsistency(parsed.start, parsed.end);
});

/// Habit completion heatmap for the current calendar year.
final habitHeatmapProvider = StreamProvider.autoDispose<Map<String, int>>((ref) {
  final year = DateTime.now().year;
  final repository = ref.watch(taskStatsRepositoryProvider);
  return repository.watchHabitCompletionHeatmap('$year-01-01', '$year-12-31');
});

/// Estimate accuracy for the selected insights window.
final estimateAccuracyProvider = StreamProvider.autoDispose<EstimateAccuracySummary>((ref) {
  final window = ref.watch(reportsInsightsWindowProvider).value ?? InsightsWindowMode.weekly;
  final rangeKey = _rangeKeyForWindow(window);
  final parsed = _parseRange(rangeKey, window);
  final repository = ref.watch(taskStatsRepositoryProvider);
  return repository.watchEstimateAccuracy(parsed.start, parsed.end);
});

/// Focus time by project for the selected insights window.
final timeByProjectProvider = StreamProvider.autoDispose<List<TimeBreakdownItem>>((ref) {
  final window = ref.watch(reportsInsightsWindowProvider).value ?? InsightsWindowMode.weekly;
  final rangeKey = _rangeKeyForWindow(window);
  final parsed = _parseRange(rangeKey, window);
  final repository = ref.watch(taskStatsRepositoryProvider);
  return repository.watchTimeByProject(parsed.start, parsed.end);
});

/// Focus time by tag for the selected insights window.
final timeByTagProvider = StreamProvider.autoDispose<List<TimeBreakdownItem>>((ref) {
  final window = ref.watch(reportsInsightsWindowProvider).value ?? InsightsWindowMode.weekly;
  final rangeKey = _rangeKeyForWindow(window);
  final parsed = _parseRange(rangeKey, window);
  final repository = ref.watch(taskStatsRepositoryProvider);
  return repository.watchTimeByTag(parsed.start, parsed.end);
});

/// Task throughput for the selected insights window.
final taskThroughputProvider = StreamProvider.autoDispose<TaskThroughputStats>((ref) {
  final window = ref.watch(reportsInsightsWindowProvider).value ?? InsightsWindowMode.weekly;
  final rangeKey = _rangeKeyForWindow(window);
  final parsed = _parseRange(rangeKey, window);
  final repository = ref.watch(taskStatsRepositoryProvider);
  return repository.watchTaskThroughput(startDate: parsed.start, endDate: parsed.end, weeklyWindow: parsed.weekly);
});
