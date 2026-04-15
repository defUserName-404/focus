import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/widgets/app_search_bar.dart';
import '../models/task_selection.dart';
import '../providers/all_tasks_provider.dart';
import 'all_tasks_filters.dart';
import 'all_tasks_list.dart';
import 'embedded_create_task_button.dart';

class AllTasksContent extends ConsumerWidget {
  final bool isCompact;
  final bool isEmbedded;
  final int? selectedTaskId;
  final ValueChanged<TaskSelection>? onTaskSelected;

  const AllTasksContent({
    super.key,
    required this.isCompact,
    required this.isEmbedded,
    required this.selectedTaskId,
    required this.onTaskSelected,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        if (!isCompact && isEmbedded) const EmbeddedCreateTaskButton(),
        AppSearchBar(
          hint: 'Search tasks...',
          onChanged: (query) {
            ref.read(allTasksFilterProvider.notifier).updateFilter(searchQuery: query);
          },
        ),
        AllTasksFilters(isCompact: isCompact),
        Expanded(
          child: AllTasksList(selectedTaskId: selectedTaskId, onTaskSelected: onTaskSelected),
        ),
      ],
    );
  }
}
