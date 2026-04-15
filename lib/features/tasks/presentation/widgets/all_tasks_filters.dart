import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart' as fu;

import '../../../../core/config/theme/app_theme.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/filter_select.dart';
import '../../../../core/widgets/sort_filter_chips.dart';
import '../../../../core/widgets/sort_order_selector.dart';
import '../../domain/entities/all_tasks_filter_state.dart';
import '../../domain/entities/task_priority.dart';
import '../providers/all_tasks_provider.dart';

class AllTasksFilters extends ConsumerWidget {
  final bool isCompact;

  const AllTasksFilters({super.key, required this.isCompact});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(allTasksFilterProvider);

    return Column(
      children: [
        if (isCompact)
          Row(
            children: [
              SizedBox(
                width: 120.0,
                child: SortOrderSelector<AllTasksSortOrder>(
                  selectedOrder: filter.sortOrder,
                  onChanged: (order) {
                    ref.read(allTasksFilterProvider.notifier).updateFilter(sortOrder: order);
                  },
                  orderOptions: AllTasksSortOrder.values,
                ),
              ),
              Expanded(
                child: SortFilterChips<AllTasksSortCriteria>(
                  selectedCriteria: filter.sortCriteria,
                  onChanged: (criteria) {
                    ref.read(allTasksFilterProvider.notifier).updateFilter(sortCriteria: criteria);
                  },
                  criteriaOptions: AllTasksSortCriteria.values,
                ),
              ),
            ],
          )
        else
          Row(
            children: [
              Expanded(
                child: FilterSelect<AllTasksSortCriteria>(
                  selected: filter.sortCriteria,
                  onChanged: (criteria) {
                    ref.read(allTasksFilterProvider.notifier).updateFilter(sortCriteria: criteria);
                  },
                  options: AllTasksSortCriteria.values,
                  hint: 'Sort by',
                ),
              ),
              SizedBox(width: AppConstants.spacing.regular),
              Expanded(
                child: FilterSelect<AllTasksSortOrder>(
                  selected: filter.sortOrder,
                  onChanged: (order) {
                    ref.read(allTasksFilterProvider.notifier).updateFilter(sortOrder: order);
                  },
                  options: AllTasksSortOrder.values,
                  hint: 'Order',
                ),
              ),
            ],
          ),
        Row(
          children: [
            SizedBox(
              width: 120.0,
              child: FilterSelect<TaskPriority?>(
                selected: filter.priorityFilter,
                onChanged: (value) {
                  ref.read(allTasksFilterProvider.notifier).updateFilter(priorityFilter: value);
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
                  style: filter.completionFilter == f ? fu.FButtonStyle.secondary() : fu.FButtonStyle.outline(),
                  onPress: () {
                    ref.read(allTasksFilterProvider.notifier).updateFilter(completionFilter: f);
                  },
                  child: Text(f.label, style: context.typography.xs),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
