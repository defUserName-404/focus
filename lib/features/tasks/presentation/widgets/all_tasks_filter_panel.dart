import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart' as fu;

import '../../../../core/config/theme/app_theme.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/filter_select.dart';
import '../../domain/entities/all_tasks_filter_state.dart';
import '../../domain/entities/task_priority.dart';
import '../providers/all_tasks_provider.dart';

/// Filter controls for the all-tasks list, designed to live inside a sheet or popover.
class AllTasksFilterPanel extends ConsumerWidget {
  const AllTasksFilterPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(allTasksFilterProvider);
    final notifier = ref.read(allTasksFilterProvider.notifier);

    return Column(
      mainAxisSize: .min,
      crossAxisAlignment: .stretch,
      spacing: AppConstants.spacing.small,
      children: [
        FilterSelect<AllTasksSortCriteria>(
          selected: filter.sortCriteria,
          onChanged: (criteria) => notifier.updateFilter(sortCriteria: criteria),
          options: AllTasksSortCriteria.values,
          hint: 'Sort by',
        ),
        FilterSelect<AllTasksSortOrder>(
          selected: filter.sortOrder,
          onChanged: (order) => notifier.updateFilter(sortOrder: order),
          options: AllTasksSortOrder.values,
          hint: 'Order',
        ),
        FilterSelect<TaskPriority?>(
          selected: filter.priorityFilter,
          onChanged: (value) => notifier.updateFilter(priorityFilter: value),
          options: TaskPriority.values,
          hint: 'Priority',
          allLabel: 'All',
        ),
        Wrap(
          spacing: AppConstants.spacing.small,
          runSpacing: AppConstants.spacing.small,
          children: [
            for (final f in TaskCompletionFilter.values)
              ConstrainedBox(
                constraints: const BoxConstraints(minHeight: 44),
                child: fu.FButton(
                  size: .sm,
                  mainAxisSize: .min,
                  variant: filter.completionFilter == f ? .secondary : .outline,
                  onPress: () => notifier.updateFilter(completionFilter: f),
                  child: Text(f.label, style: context.typography.xs),
                ),
              ),
          ],
        ),
      ],
    );
  }
}
