import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

/// Estimated versus actual focus minutes for a single task in a window.
@immutable
class EstimateAccuracyStat extends Equatable {
  final int taskId;
  final String title;
  final int estimatedMinutes;
  final int actualMinutes;

  const EstimateAccuracyStat({
    required this.taskId,
    required this.title,
    required this.estimatedMinutes,
    required this.actualMinutes,
  });

  /// Positive when actual exceeds estimate (underestimated).
  double get deltaRatio {
    if (estimatedMinutes <= 0) return 0;
    return (actualMinutes - estimatedMinutes) / estimatedMinutes;
  }

  @override
  List<Object?> get props => [taskId, title, estimatedMinutes, actualMinutes];
}

/// Aggregate estimate accuracy insight across tasks in a window.
@immutable
class EstimateAccuracySummary extends Equatable {
  final List<EstimateAccuracyStat> tasks;

  /// Typical bias as a fraction of estimate. Positive = underestimate.
  final double typicalBiasRatio;

  const EstimateAccuracySummary({required this.tasks, required this.typicalBiasRatio});

  bool get hasData => tasks.isNotEmpty;

  @override
  List<Object?> get props => [tasks, typicalBiasRatio];
}
