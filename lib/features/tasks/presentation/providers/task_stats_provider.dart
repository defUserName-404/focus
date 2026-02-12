import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/injection.dart';
import '../../../focus/domain/entities/focus_session.dart';
import '../../domain/entities/task_stats.dart';
import '../../domain/repositories/i_task_stats_repository.dart';

/// Provides the [ITaskStatsRepository] singleton from DI.
final taskStatsRepositoryProvider = Provider<ITaskStatsRepository>((ref) {
  return getIt<ITaskStatsRepository>();
});

/// Watches aggregated stats for a single task.
final taskStatsProvider = StreamProvider.family<TaskStats, String>((ref, taskIdString) {
  final repository = ref.watch(taskStatsRepositoryProvider);
  return repository.watchTaskStats(BigInt.parse(taskIdString));
});

/// Watches the most recent focus sessions for a task (max 10).
final recentSessionsProvider = StreamProvider.family<List<FocusSession>, String>((ref, taskIdString) {
  final repository = ref.watch(taskStatsRepositoryProvider);
  return repository.watchRecentSessions(BigInt.parse(taskIdString));
});
