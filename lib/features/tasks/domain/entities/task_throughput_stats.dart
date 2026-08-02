import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

/// Completions counted for a single day or week bucket.
@immutable
class ThroughputBucket extends Equatable {
  final String label;
  final String periodKey;
  final int completedCount;

  const ThroughputBucket({required this.label, required this.periodKey, required this.completedCount});

  @override
  List<Object?> get props => [label, periodKey, completedCount];
}

/// Task throughput for a report window, including cycle-time insight.
@immutable
class TaskThroughputStats extends Equatable {
  final List<ThroughputBucket> buckets;

  /// Average seconds from work-start proxy to done. Null when no samples.
  final double? averageCycleSeconds;

  final int cycleSampleCount;

  const TaskThroughputStats({required this.buckets, required this.averageCycleSeconds, required this.cycleSampleCount});

  double? get averageCycleHours {
    final seconds = averageCycleSeconds;
    if (seconds == null) return null;
    return seconds / 3600;
  }

  int get totalCompleted => buckets.fold(0, (sum, b) => sum + b.completedCount);

  @override
  List<Object?> get props => [buckets, averageCycleSeconds, cycleSampleCount];
}
