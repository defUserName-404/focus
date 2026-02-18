import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart' as fu;

import '../../../../core/common/widgets/app_search_bar.dart';
import '../../../../core/common/widgets/filter_select.dart';
import '../../../../core/common/widgets/sort_filter_chips.dart';
import '../../../../core/common/widgets/sort_order_selector.dart';
import '../../../../core/config/theme/app_theme.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/route_constants.dart';
import '../../../../core/common/providers/navigation_provider.dart';
import '../../domain/entities/task_priority.dart';
import '../../domain/entities/all_tasks_filter_state.dart';
import '../providers/all_tasks_provider.dart';
import '../widgets/all_task_card.dart';

/// Global all-tasks screen that shows tasks across all projects.
///
/// This is part of the tasks feature (not a standalone feature) and
/// serves as the Tasks tab root in the main shell.
class AllTasksScreen extends ConsumerWidget {
  const AllTasksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filteredAsync = ref.watch(filteredAllTasksProvider);
    final filter = ref.watch(allTasksFilterProvider);

    return fu.FScaffold(
      header: fu.FHeader.nested(
        prefixes: [
          fu.FHeaderAction.back(
            onPress: () {
              if (Navigator.of(context).canPop()) {
                Navigator.of(context).pop();
              } else {
                ref.read(bottomNavIndexProvider.notifier).goHome();
              }
            },
          ),
        ],
        title: Text(
          'Tasks',
          style: context.typography.xl2.copyWith(fontWeight: FontWeight.w700),
        ),
      ),
      footer: Padding(
        padding: EdgeInsets.all(AppConstants.spacing.large),
        child: fu.FButton(
          prefix: Icon(fu.FIcons.plus),
          child: const Text('Create New Task'),
          onPress: () => Navigator.of(
            context,
            rootNavigator: true,
          ).pushNamed(RouteConstants.createTaskWithProjectRoute),
        ),
      ),
      child: Column(
        children: [
          AppSearchBar(
            hint: 'Search tasks...',
            onChanged: (query) {
              ref
                  .read(allTasksFilterProvider.notifier)
                  .updateFilter(searchQuery: query);
            },
          ),
          Row(
            children: [
              SizedBox(
                width: 120.0,
                child: SortOrderSelector<AllTasksSortOrder>(
                  selectedOrder: filter.sortOrder,
                  onChanged: (order) {
                    ref
                        .read(allTasksFilterProvider.notifier)
                        .updateFilter(sortOrder: order);
                  },
                  orderOptions: AllTasksSortOrder.values,
                ),
              ),
              Expanded(
                child: SortFilterChips<AllTasksSortCriteria>(
                  selectedCriteria: filter.sortCriteria,
                  onChanged: (criteria) {
                    ref
                        .read(allTasksFilterProvider.notifier)
                        .updateFilter(sortCriteria: criteria);
                  },
                  criteriaOptions: AllTasksSortCriteria.values,
                ),
              ),
            ],
          ),
          // Priority & completion filter row
          Row(
            children: [
              SizedBox(
                width: 120.0,
                child: FilterSelect<TaskPriority?>(
                  selected: filter.priorityFilter,
                  onChanged: (value) {
                    ref
                        .read(allTasksFilterProvider.notifier)
                        .updateFilter(priorityFilter: value);
                  },
                  options: TaskPriority.values,
                  hint: 'Priority',
                  allLabel: 'All',
                ),
              ),
              SizedBox(width: AppConstants.spacing.small),
              ...TaskCompletionFilter.values.map(
                (f) => Padding(
                  padding: EdgeInsets.only(right: AppConstants.spacing.small),
                  child: fu.FButton(
                    style: filter.completionFilter == f
                        ? fu.FButtonStyle.secondary()
                        : fu.FButtonStyle.outline(),
                    onPress: () {
                      ref
                          .read(allTasksFilterProvider.notifier)
                          .updateFilter(completionFilter: f);
                    },
                    child: Text(f.label),
                  ),
                ),
              ),
            ],
          ),
          Expanded(
            child: filteredAsync.when(
              loading: () => const Center(child: fu.FCircularProgress()),
              error: (err, _) => Center(child: Text('Error: $err')),
              data: (tasks) {
                if (tasks.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      spacing: AppConstants.spacing.regular,
                      children: [
                        Icon(
                          fu.FIcons.squareCheck,
                          size: AppConstants.size.icon.extraExtraLarge,
                          color: Theme.of(context).disabledColor,
                        ),
                        Text(
                          'No tasks found',
                          style: context.typography.sm.copyWith(
                            color: context.colors.mutedForeground,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: EdgeInsets.symmetric(
                    vertical: AppConstants.spacing.regular,
                  ),
                  itemCount: tasks.length,
                  itemBuilder: (context, index) {
                    final task = tasks[index];
                    return AllTaskCard(
                      task: task,
                      onTap: () => task.id != null
                          ? Navigator.of(context).pushNamed(
                              RouteConstants.taskDetailRoute,
                              arguments: {
                                'taskId': task.id!,
                                'projectId': task.projectId,
                              },
                            )
                          : null,
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
