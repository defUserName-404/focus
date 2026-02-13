import 'package:drift/drift.dart';

/// Pre-aggregated daily session statistics.
///
/// Each row summarises all focus sessions for a single calendar date.
/// The [date] column stores an ISO-8601 date string (`YYYY-MM-DD`) in the
/// user's **local** timezone, enabling simple range queries for lazy-loaded
/// month/year graphs (e.g. `WHERE date >= '2026-01' AND date < '2026-02'`).
@DataClassName('DailySessionStatsData')
@TableIndex(name: 'daily_stats_date_idx', columns: {#date})
class DailySessionStatsTable extends Table {
  /// ISO-8601 local date, e.g. `'2026-02-12'`. Acts as the primary key.
  TextColumn get date => text()();
  IntColumn get completedSessions => integer().withDefault(const Constant(0))();
  IntColumn get totalSessions => integer().withDefault(const Constant(0))();
  IntColumn get focusSeconds => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {date};
}
