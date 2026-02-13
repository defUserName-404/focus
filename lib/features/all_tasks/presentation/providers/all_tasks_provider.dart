import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../tasks/domain/entities/task.dart';
import '../../../tasks/domain/entities/task_priority.dart';
import '../../../tasks/presentation/providers/task_provider.dart';
import '../../domain/entities/all_tasks_filter_state.dart';

part 'all_tasks_provider.g.dart';

// ── Filter state provider ──────────────────────────────────────────────────

@Riverpod(keepAlive: true)
class AllTasksFilter extends _$AllTasksFilter {
  @override
  AllTasksFilterState build() {
    return const AllTasksFilterState();
  }

  void updateFilter({
    String? searchQuery,
    AllTasksSortCriteria? sortCriteria,
    AllTasksSortOrder? sortOrder,
    TaskPriority? priorityFilter,
    TaskCompletionFilter? completionFilter,
  }) {
    state = state.copyWith(
      searchQuery: searchQuery,
      sortCriteria: sortCriteria,
      sortOrder: sortOrder,
      priorityFilter: priorityFilter,
      completionFilter: completionFilter,
    );
  }

  void clearPriorityFilter() {
    state = state.copyWith(priorityFilter: null);
  }
}

// ── Filtered all-tasks list ────────────────────────────────────────────────

final filteredAllTasksProvider = StreamProvider<List<Task>>((ref) {
  final repository = ref.watch(taskRepositoryProvider);
  final filter = ref.watch(allTasksFilterProvider);

  return repository.watchAllFilteredTasks(
    searchQuery: filter.searchQuery,
    sortCriteria: filter.sortCriteria,
    sortOrder: filter.sortOrder,
    priorityFilter: filter.priorityFilter,
    completionFilter: filter.completionFilter,
  );
});
