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
import 'all_tasks_filter_panel.dart';
import 'all_tasks_list.dart';

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

    return Column(
      children: [
        ListToolbar(
          searchHint: 'Search tasks...',
          onSearchChanged: (query) {
            ref.read(allTasksFilterProvider.notifier).updateFilter(searchQuery: query);
          },
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
          child: AllTasksList(selectedTaskId: selectedTaskId, onTaskSelected: onTaskSelected),
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
