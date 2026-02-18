/// Pre-aggregated daily focus session statistics.
///
/// [date] is an ISO-8601 date string (`YYYY-MM-DD`) in the user's local
/// timezone. This format enables trivial range queries for lazy-loaded
/// month/year activity graphs.
class DailySessionStats {
  final String date;
  final int completedSessions;
  final int totalSessions;
  final int focusSeconds;

  const DailySessionStats({
    required this.date,
    required this.completedSessions,
    required this.totalSessions,
    required this.focusSeconds,
  });

  int get focusMinutes => focusSeconds ~/ 60;

  static const empty = DailySessionStats(date: '', completedSessions: 0, totalSessions: 0, focusSeconds: 0);
}
