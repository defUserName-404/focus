import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/filter_select.dart';
import '../../domain/entities/project_list_filter_state.dart';
import '../providers/project_provider.dart';

class ProjectFilterPanel extends ConsumerWidget {
  const ProjectFilterPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(projectListFilterProvider);
    final notifier = ref.read(projectListFilterProvider.notifier);

    return Column(
      mainAxisSize: .min,
      crossAxisAlignment: .stretch,
      spacing: AppConstants.spacing.small,
      children: [
        FilterSelect<ProjectSortCriteria>(
          selected: filter.sortCriteria,
          onChanged: (criteria) => notifier.updateFilter(sortCriteria: criteria),
          options: ProjectSortCriteria.values,
          hint: 'Sort by',
        ),
        FilterSelect<ProjectSortOrder>(
          selected: filter.sortOrder,
          onChanged: (order) => notifier.updateFilter(sortOrder: order),
          options: ProjectSortOrder.values,
          hint: 'Order',
        ),
      ],
    );
  }
}
