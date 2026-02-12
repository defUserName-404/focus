import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:focus/core/common/utils/widget_extensions.dart';
import 'package:focus/core/constants/app_constants.dart';

// Removed unused import: ProjectDetailScreen
import 'package:forui/forui.dart' as fu;

import '../../../../core/common/widgets/app_search_bar.dart';
import '../../../../core/common/widgets/sort_filter_chips.dart';
import '../../../../core/common/widgets/sort_order_selector.dart';
import '../../../../core/config/theme/app_theme.dart';
import '../../../../core/constants/route_constants.dart'; // Added import
import '../../domain/entities/project_list_filter_state.dart';
import '../commands/project_commands.dart';
import '../providers/project_provider.dart';
import '../widgets/project_card.dart';

class ProjectListScreen extends ConsumerWidget {
  const ProjectListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filteredAsync = ref.watch(filteredProjectListProvider);
    final filter = ref.watch(projectListFilterProvider);

    return fu.FScaffold(
      header: fu.FHeader.nested(
        prefixes: [fu.FHeaderAction.back(onPress: () => Navigator.pop(context))],
        title: Text('Projects', style: context.typography.lg),
      ),
      footer: Padding(
        padding: EdgeInsets.all(AppConstants.spacing.large),
        child: fu.FButton(
          prefix: Icon(fu.FIcons.plus),
          child: const Text('Create New Project'),
          onPress: () => ProjectCommands.create(context, ref),
        ),
      ),
      child: Column(
        children: [
          AppSearchBar(
            hint: 'Search projects...',
            onChanged: (query) {
              ref.read(projectListFilterProvider.notifier).updateFilter(searchQuery: query);
            },
          ),
          Row(
            children: [
              SizedBox(
                width: 120.0,
                child: SortOrderSelector<ProjectSortOrder>(
                  selectedOrder: filter.sortOrder,
                  onChanged: (order) {
                    ref.read(projectListFilterProvider.notifier).updateFilter(sortOrder: order);
                  },
                  orderOptions: ProjectSortOrder.values,
                ),
              ),
              Expanded(
                child: SortFilterChips<ProjectSortCriteria>(
                  selectedCriteria: filter.sortCriteria,
                  onChanged: (criteria) {
                    ref.read(projectListFilterProvider.notifier).updateFilter(sortCriteria: criteria);
                  },
                  criteriaOptions: ProjectSortCriteria.values,
                ),
              ),
            ],
          ),
          Expanded(
            child: filteredAsync.when(
              loading: () => const Center(child: fu.FCircularProgress()),
              error: (err, _) => Center(child: Text('Error: $err')),
              data: (projects) {
                if (projects.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      spacing: AppConstants.spacing.regular,
                      children: [
                        Icon(
                          fu.FIcons.folderOpen,
                          size: AppConstants.size.icon.extraExtraLarge,
                          color: Theme.of(context).disabledColor,
                        ),
                        Text(
                          'No projects found',
                          style: context.typography.sm.copyWith(color: context.colors.mutedForeground),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: EdgeInsets.all(AppConstants.spacing.regular),
                  itemCount: projects.length,
                  itemBuilder: (context, index) {
                    final project = projects[index];
                    return ProjectCard(
                      project: project,
                      onTap: () => project.id != null
                          ? Navigator.of(context).pushNamed(RouteConstants.projectDetailRoute, arguments: project.id!)
                          : null,
                      onEdit: () => ProjectCommands.edit(context, project),
                      onDelete: () => ProjectCommands.delete(context, ref, project),
                    );
                  },
                );
              },
            ),
          ),
        ].withSpacing(AppConstants.spacing.regular),
      ),
    );
  }
}
