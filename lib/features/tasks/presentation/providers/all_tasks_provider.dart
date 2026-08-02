import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/entities/task.dart';
import '../../domain/entities/task_priority.dart';
import '../../domain/entities/task_status.dart';
import '../../domain/entities/all_tasks_filter_state.dart';
import 'task_provider.dart';

part 'all_tasks_provider.g.dart';
part 'filtered_all_tasks_provider.part.dart';

//  Filter state provider

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
    TaskStatus? statusFilter,
    TaskCompletionFilter? completionFilter,
  }) {
    state = state.copyWith(
      searchQuery: searchQuery,
      sortCriteria: sortCriteria,
      sortOrder: sortOrder,
      priorityFilter: priorityFilter,
      statusFilter: statusFilter,
      completionFilter: completionFilter,
    );
  }

  void clearPriorityFilter() {
    state = state.copyWith(priorityFilter: null);
  }

  void clearStatusFilter() {
    state = state.copyWith(statusFilter: null);
  }
}
