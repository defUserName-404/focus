import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/injection.dart';
import '../../../session/domain/entities/focus_session.dart';
import '../../domain/entities/daily_session_stats.dart';
import '../../domain/entities/global_stats.dart';
import '../../domain/entities/task.dart';
import '../../domain/entities/task_stats.dart';
import '../../domain/repositories/i_task_stats_repository.dart';

part 'daily_stats_for_range_provider.part.dart';
part 'global_daily_completed_sessions_provider.part.dart';
part 'global_stats_provider.part.dart';
part 'recent_sessions_provider.part.dart';
part 'recent_tasks_provider.part.dart';
part 'task_stats_stream_provider.part.dart';

/// Provides the [ITaskStatsRepository] singleton from DI.
final taskStatsRepositoryProvider = Provider<ITaskStatsRepository>((ref) {
  return getIt<ITaskStatsRepository>();
});
