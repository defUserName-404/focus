import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/injection.dart';
import '../../../tasks/domain/entities/task.dart';
import '../../../tasks/domain/repositories/i_task_repository.dart';

/// Watches all incomplete tasks that have a deadline (endDate), sorted by
/// deadline ascending. Used by the calendar view on the home screen.
final upcomingTasksProvider = StreamProvider<List<Task>>((ref) {
  final repository = ref.watch(Provider((ref) => getIt<ITaskRepository>()));
  return repository.watchTasksWithDeadlines();
});
