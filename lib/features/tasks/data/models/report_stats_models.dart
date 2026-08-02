/// Lightweight SQL row models for Phase 6 report aggregates.
library;

class HabitConsistencySourceRow {
  final int taskId;
  final String title;
  final String recurrenceRuleJson;
  final DateTime? recurrenceAnchorDate;
  final DateTime? startDate;
  final DateTime createdAt;
  final List<String> completionDateKeys;

  const HabitConsistencySourceRow({
    required this.taskId,
    required this.title,
    required this.recurrenceRuleJson,
    required this.recurrenceAnchorDate,
    required this.startDate,
    required this.createdAt,
    required this.completionDateKeys,
  });
}

class EstimateAccuracyRow {
  final int taskId;
  final String title;
  final int estimatedMinutes;
  final int actualMinutes;

  const EstimateAccuracyRow({
    required this.taskId,
    required this.title,
    required this.estimatedMinutes,
    required this.actualMinutes,
  });
}

class TimeBreakdownRow {
  final int id;
  final String name;
  final int focusSeconds;
  final int? color;

  const TimeBreakdownRow({required this.id, required this.name, required this.focusSeconds, this.color});
}

class CycleTimeAggregateRow {
  final double? averageCycleSeconds;
  final int sampleCount;

  const CycleTimeAggregateRow({required this.averageCycleSeconds, required this.sampleCount});

  static const empty = CycleTimeAggregateRow(averageCycleSeconds: null, sampleCount: 0);
}
