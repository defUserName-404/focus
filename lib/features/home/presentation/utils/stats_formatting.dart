import '../../../tasks/domain/entities/global_stats.dart';
import '../../../tasks/domain/entities/task_stats.dart';

/// Presentation-layer formatting for [GlobalStats].
///
/// Keeps the domain entity free of display logic.
extension GlobalStatsFormatting on GlobalStats {
  String get formattedTotalTime => _formatMinutes(totalFocusMinutes);

  String get formattedTodayTime => _formatMinutes(todayFocusMinutes);
}

/// Presentation-layer formatting for [TaskStats].
extension TaskStatsFormatting on TaskStats {
  String get formattedTotalTime => _formatMinutes(totalFocusMinutes);

  String get formattedAvgTime => '${avgSessionMinutes.round()}m';
}

String _formatMinutes(int minutes) {
  if (minutes < 60) return '${minutes}m';
  final hours = minutes ~/ 60;
  final mins = minutes % 60;
  return mins > 0 ? '${hours}h ${mins}m' : '${hours}h';
}
