part of 'task_stats_provider.dart';

/// Watches pre-aggregated daily stats for a date range.
/// The argument is `'startDate|endDate'` in ISO format.
final dailyStatsForRangeProvider = StreamProvider.family<List<DailySessionStats>, String>((ref, rangeKey) {
  final parts = rangeKey.split('|');
  final repository = ref.watch(taskStatsRepositoryProvider);
  return repository.watchDailyStatsForRange(parts[0], parts[1]);
});
