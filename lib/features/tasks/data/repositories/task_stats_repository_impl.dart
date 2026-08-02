import '../../../../core/services/log_service.dart';
import '../../../session/data/mappers/focus_session_mappers.dart';
import '../../../session/domain/entities/focus_session.dart';
import '../../domain/entities/daily_session_stats.dart';
import '../../domain/entities/estimate_accuracy_stat.dart';
import '../../domain/entities/global_stats.dart';
import '../../domain/entities/habit_consistency_stat.dart';
import '../../domain/entities/recurrence_rule.dart';
import '../../domain/entities/task.dart';
import '../../domain/entities/task_stats.dart';
import '../../domain/entities/task_throughput_stats.dart';
import '../../domain/entities/time_breakdown_item.dart';
import '../../domain/repositories/i_task_stats_repository.dart';
import '../../domain/services/report_insights_calculator.dart';
import '../datasources/task_stats_local_datasource.dart';
import '../mappers/global_stats_mappers.dart';
import '../mappers/task_extensions.dart';
import '../mappers/task_stats_mappers.dart';

final _log = LogService.instance;

class TaskStatsRepositoryImpl implements ITaskStatsRepository {
  final ITaskStatsLocalDataSource _local;

  TaskStatsRepositoryImpl(this._local);

  @override
  Stream<TaskStats> watchTaskStats(int taskId) {
    return _local.watchTaskStats(taskId).map((model) => model.toDomain()).handleError((e, st) {
      _log.error(
        'Error watching task stats for $taskId',
        tag: 'TaskStatsRepository',
        error: e,
        stackTrace: st as StackTrace?,
      );
      throw e;
    });
  }

  @override
  Stream<List<FocusSession>> watchRecentSessions(int taskId, {int limit = 10}) {
    return _local
        .watchRecentSessions(taskId, limit: limit)
        .map((rows) => rows.map((r) => r.toDomain()).toList())
        .handleError((e, st) {
          _log.error(
            'Error watching recent sessions for $taskId',
            tag: 'TaskStatsRepository',
            error: e,
            stackTrace: st as StackTrace?,
          );
          throw e;
        });
  }

  @override
  Stream<Map<String, int>> watchGlobalDailyCompletedSessions() {
    return _local.watchGlobalDailyCompletedSessions();
  }

  @override
  Stream<List<DailySessionStats>> watchDailyStatsForRange(String startDate, String endDate) {
    return _local
        .watchDailyStatsForRange(startDate, endDate)
        .map(
          (rows) => rows
              .map(
                (r) => DailySessionStats(
                  date: r.date,
                  completedSessions: r.completedSessions,
                  totalSessions: r.totalSessions,
                  focusSeconds: r.focusSeconds,
                ),
              )
              .toList(),
        );
  }

  @override
  Stream<GlobalStats> watchGlobalStats() {
    return _local.watchGlobalStats().map((model) => model.toDomain()).handleError((e, st) {
      _log.error('Error watching global stats', tag: 'TaskStatsRepository', error: e, stackTrace: st as StackTrace?);
      throw e;
    });
  }

  @override
  Stream<List<Task>> watchRecentTasks({int limit = 5}) {
    return _local.watchRecentTasks(limit: limit).map((rows) => rows.map((r) => r.toDomain()).toList()).handleError((
      e,
      st,
    ) {
      _log.error('Error watching recent tasks', tag: 'TaskStatsRepository', error: e, stackTrace: st as StackTrace?);
      throw e;
    });
  }

  @override
  Stream<List<HabitConsistencyStat>> watchHabitConsistency(String startDate, String endDate) {
    final from = DateTime.parse(startDate);
    final to = DateTime.parse(endDate);
    return _local
        .watchHabitConsistencySources(startDate, endDate)
        .map((rows) {
          final sources = <HabitConsistencySource>[];
          for (final row in rows) {
            final rule = RecurrenceRule.tryParseJson(row.recurrenceRuleJson);
            if (rule == null) continue;
            final anchor = row.recurrenceAnchorDate ?? row.startDate ?? row.createdAt;
            sources.add(
              HabitConsistencySource(
                taskId: row.taskId,
                title: row.title,
                rule: rule,
                anchor: anchor,
                completionDates: [for (final key in row.completionDateKeys) DateTime.parse(key)],
              ),
            );
          }
          return ReportInsightsCalculator.buildHabitConsistency(sources: sources, from: from, to: to);
        })
        .handleError((e, st) {
          _log.error(
            'Error watching habit consistency',
            tag: 'TaskStatsRepository',
            error: e,
            stackTrace: st as StackTrace?,
          );
          throw e;
        });
  }

  @override
  Stream<Map<String, int>> watchHabitCompletionHeatmap(String startDate, String endDate) {
    return _local.watchHabitCompletionHeatmap(startDate, endDate).handleError((e, st) {
      _log.error('Error watching habit heatmap', tag: 'TaskStatsRepository', error: e, stackTrace: st as StackTrace?);
      throw e;
    });
  }

  @override
  Stream<EstimateAccuracySummary> watchEstimateAccuracy(String startDate, String endDate) {
    return _local
        .watchEstimateAccuracy(startDate, endDate)
        .map(
          (rows) => ReportInsightsCalculator.buildEstimateAccuracy([
            for (final row in rows)
              EstimateAccuracyStat(
                taskId: row.taskId,
                title: row.title,
                estimatedMinutes: row.estimatedMinutes,
                actualMinutes: row.actualMinutes,
              ),
          ]),
        )
        .handleError((e, st) {
          _log.error(
            'Error watching estimate accuracy',
            tag: 'TaskStatsRepository',
            error: e,
            stackTrace: st as StackTrace?,
          );
          throw e;
        });
  }

  @override
  Stream<List<TimeBreakdownItem>> watchTimeByProject(String startDate, String endDate) {
    return _local
        .watchTimeByProject(startDate, endDate)
        .map(
          (rows) => ReportInsightsCalculator.normalizeBreakdown([
            for (final row in rows)
              TimeBreakdownItem(id: row.id, name: row.name, focusSeconds: row.focusSeconds, color: row.color),
          ]),
        )
        .handleError((e, st) {
          _log.error(
            'Error watching time by project',
            tag: 'TaskStatsRepository',
            error: e,
            stackTrace: st as StackTrace?,
          );
          throw e;
        });
  }

  @override
  Stream<List<TimeBreakdownItem>> watchTimeByTag(String startDate, String endDate) {
    return _local
        .watchTimeByTag(startDate, endDate)
        .map(
          (rows) => ReportInsightsCalculator.normalizeBreakdown([
            for (final row in rows)
              TimeBreakdownItem(id: row.id, name: row.name, focusSeconds: row.focusSeconds, color: row.color),
          ]),
        )
        .handleError((e, st) {
          _log.error('Error watching time by tag', tag: 'TaskStatsRepository', error: e, stackTrace: st as StackTrace?);
          throw e;
        });
  }

  @override
  Stream<TaskThroughputStats> watchTaskThroughput({
    required String startDate,
    required String endDate,
    required bool weeklyWindow,
  }) {
    final from = DateTime.parse(startDate);
    final to = DateTime.parse(endDate);
    return _local
        .watchTaskCompletionsByDate(startDate, endDate)
        .asyncExpand((byDate) {
          return _local.watchAverageCycleTime(startDate, endDate).map((cycle) {
            return ReportInsightsCalculator.buildThroughputStats(
              completedByDate: byDate,
              from: from,
              to: to,
              weeklyWindow: weeklyWindow,
              averageCycleSeconds: cycle.averageCycleSeconds,
              cycleSampleCount: cycle.sampleCount,
            );
          });
        })
        .handleError((e, st) {
          _log.error(
            'Error watching task throughput',
            tag: 'TaskStatsRepository',
            error: e,
            stackTrace: st as StackTrace?,
          );
          throw e;
        });
  }
}
