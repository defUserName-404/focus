import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/date_time_utils.dart';
import '../../../tasks/domain/entities/habit_strip_item.dart';
import '../../../tasks/domain/entities/task_completion.dart';
import '../../../tasks/domain/services/today_agenda_builder.dart';
import '../../../tasks/presentation/providers/task_provider.dart';

Map<int, List<TaskCompletion>> _groupCompletions(List<TaskCompletion> completions) {
  final map = <int, List<TaskCompletion>>{};
  for (final c in completions) {
    map.putIfAbsent(c.taskId, () => []).add(c);
  }
  return map;
}

/// Horizontally scrolling habits strip: today's completion + current streak.
final habitsStripProvider = StreamProvider<List<HabitStripItem>>((ref) {
  final repository = ref.watch(taskRepositoryProvider);
  return repository.watchTasksWithDeadlines().asyncExpand((tasks) {
    return repository.watchAllCompletions().map((completions) {
      return TodayAgendaBuilder.buildHabitStrip(
        tasks: tasks,
        completionsByTaskId: _groupCompletions(completions),
        today: DateTimeUtils.now(),
      );
    });
  });
});
