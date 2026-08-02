import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart' as fu;
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/routing/routes.dart';
import '../../../../core/widgets/list_toolbar.dart';
import '../../domain/entities/all_tasks_filter_state.dart';
import '../models/task_selection.dart';
import '../providers/all_tasks_provider.dart';
import '../providers/tasks_view_mode_provider.dart';
import 'all_tasks_filter_panel.dart';
import 'all_tasks_list.dart';
import 'tasks_board_view.dart';
import 'tasks_calendar_view.dart';
import 'tasks_view_mode_toggle.dart';

class AllTasksContent extends ConsumerWidget {
  final bool isEmbedded;
  final int? selectedTaskId;
  final ValueChanged<TaskSelection>? onTaskSelected;

  const AllTasksContent({
    super.key,
    required this.isEmbedded,
    required this.selectedTaskId,
    required this.onTaskSelected,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(allTasksFilterProvider);
    final activeCount = _activeFilterCount(filter);
    final viewModeAsync = ref.watch(tasksViewModeProvider);
    final viewMode = viewModeAsync.value ?? TasksViewMode.list;
    final filteredAsync = ref.watch(filteredAllTasksProvider);

    return Column(
      children: [
        ListToolbar(
          searchHint: 'Search tasks...',
          onSearchChanged: (query) {
            ref.read(allTasksFilterProvider.notifier).updateFilter(searchQuery: query);
          },
          viewModeControl: TasksViewModeToggle(
            mode: viewMode,
            onChanged: (mode) => ref.read(tasksViewModeProvider.notifier).setMode(mode),
          ),
          filterPanel: const AllTasksFilterPanel(),
          activeFilterCount: activeCount,
          activeFilters: [
            if (filter.priorityFilter != null)
              fu.FButton(
                size: .xs,
                mainAxisSize: .min,
                variant: .secondary,
                suffix: const Icon(fu.FLucideIcons.x),
                onPress: () => ref.read(allTasksFilterProvider.notifier).updateFilter(priorityFilter: null),
                child: Text(filter.priorityFilter!.label),
              ),
            if (filter.completionFilter != TaskCompletionFilter.all)
              fu.FButton(
                size: .xs,
                mainAxisSize: .min,
                variant: .secondary,
                suffix: const Icon(fu.FLucideIcons.x),
                onPress: () =>
                    ref.read(allTasksFilterProvider.notifier).updateFilter(completionFilter: TaskCompletionFilter.all),
                child: Text(filter.completionFilter.label),
              ),
          ],
          onCreate: isEmbedded ? () => context.push(AppRoutes.createTaskWithProject.path) : null,
          createLabel: 'Create Task',
        ),
        SizedBox(height: AppConstants.spacing.small),
        Expanded(
          child: switch (viewMode) {
            TasksViewMode.list => AllTasksList(selectedTaskId: selectedTaskId, onTaskSelected: onTaskSelected),
            TasksViewMode.board => filteredAsync.when(
              loading: () => const Center(child: fu.FCircularProgress()),
              error: (err, _) => Center(child: Text('Error: $err')),
              data: (tasks) =>
                  TasksBoardView(tasks: tasks, selectedTaskId: selectedTaskId, onTaskSelected: onTaskSelected),
            ),
            TasksViewMode.calendar => filteredAsync.when(
              loading: () => const Center(child: fu.FCircularProgress()),
              error: (err, _) => Center(child: Text('Error: $err')),
              data: (tasks) =>
                  TasksCalendarView(tasks: tasks, selectedTaskId: selectedTaskId, onTaskSelected: onTaskSelected),
            ),
          },
        ),
      ],
    );
  }

  int _activeFilterCount(AllTasksFilterState filter) {
    var count = 0;
    if (filter.priorityFilter != null) count++;
    if (filter.completionFilter != TaskCompletionFilter.all) count++;
    return count;
  }
}
