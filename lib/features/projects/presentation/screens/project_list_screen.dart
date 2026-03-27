import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:focus/core/constants/app_constants.dart';
import 'package:forui/forui.dart' as fu;
import 'package:go_router/go_router.dart';

import '../../../../core/config/theme/app_theme.dart';
import '../../../../core/routing/routes.dart';
import '../../../../core/widgets/app_search_bar.dart';
import '../../../../core/widgets/constrained_content.dart';
import '../../../../core/widgets/sort_filter_chips.dart';
import '../../../../core/widgets/sort_order_selector.dart';
import '../../domain/entities/project_list_filter_state.dart';
import '../commands/project_commands.dart';
import '../providers/project_provider.dart';
import '../widgets/project_card.dart';

class ProjectListScreen extends ConsumerWidget {
  final int? selectedId;
  final ValueChanged<int>? onProjectSelected;

  const ProjectListScreen({super.key, this.selectedId, this.onProjectSelected});

  bool get _isEmbedded => onProjectSelected != null;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filteredAsync = ref.watch(filteredProjectListProvider);
    final filter = ref.watch(projectListFilterProvider);

    final content = ConstrainedContent(
      maxWidth: 980,
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
                  padding: EdgeInsets.symmetric(vertical: AppConstants.spacing.regular),
                  itemCount: projects.length,
                  itemBuilder: (context, index) {
                    final project = projects[index];
                    return ProjectCard(
                      project: project,
                      isSelected: selectedId != null && selectedId == project.id,
                      onTap: () {
                        if (project.id == null) return;
                        if (onProjectSelected != null) {
                          onProjectSelected!(project.id!);
                          return;
                        }
                        context.push(AppRoutes.projectDetailPath(project.id!));
                      },
                      onEdit: () => ProjectCommands.edit(context, project),
                      onDelete: () => ProjectCommands.delete(context, ref, project),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );

    if (_isEmbedded) {
      return content;
    }

    return fu.FScaffold(
      header: fu.FHeader.nested(
        prefixes: [
          fu.FHeaderAction.back(
            onPress: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go(AppRoutes.home);
              }
            },
          ),
        ],
        title: Text('Projects', style: context.typography.xl2.copyWith(fontWeight: FontWeight.w700)),
      ),
      footer: Padding(
        padding: EdgeInsets.all(AppConstants.spacing.large),
        child: fu.FButton(
          prefix: Icon(fu.FIcons.plus),
          child: const Text('Create New Project'),
          onPress: () => ProjectCommands.create(context),
        ),
      ),
      child: content,
    );
  }
}
