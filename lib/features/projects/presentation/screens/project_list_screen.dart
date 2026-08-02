import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart' as fu;
import 'package:go_router/go_router.dart';

import 'package:focus/core/constants/app_constants.dart';

import '../../../../core/config/theme/app_theme.dart';
import '../../../../core/routing/routes.dart';
import '../../../../core/widgets/constrained_content.dart';
import '../../../../core/widgets/list_toolbar.dart';
import '../commands/project_commands.dart';
import '../providers/project_provider.dart';
import '../widgets/project_card.dart';
import '../widgets/project_filter_panel.dart';

class ProjectListScreen extends ConsumerWidget {
  final int? selectedId;
  final ValueChanged<int>? onProjectSelected;

  const ProjectListScreen({super.key, this.selectedId, this.onProjectSelected});

  bool get _isEmbedded => onProjectSelected != null;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filteredAsync = ref.watch(filteredProjectListProvider);

    final content = ConstrainedContent(
      maxWidth: _isEmbedded ? double.infinity : 980,
      padding: EdgeInsets.symmetric(
        horizontal: _isEmbedded ? AppConstants.spacing.regular : AppConstants.spacing.large,
        vertical: AppConstants.spacing.regular,
      ),
      child: Column(
        children: [
          ListToolbar(
            searchHint: 'Search projects...',
            onSearchChanged: (query) {
              ref.read(projectListFilterProvider.notifier).updateFilter(searchQuery: query);
            },
            filterPanel: const ProjectFilterPanel(),
            onCreate: () => ProjectCommands.create(context),
            createLabel: 'Create Project',
          ),
          SizedBox(height: AppConstants.spacing.small),
          Expanded(
            child: filteredAsync.when(
              loading: () => const Center(child: fu.FCircularProgress()),
              error: (err, _) => Center(child: Text('Error: $err')),
              data: (projects) {
                if (projects.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: .min,
                      spacing: AppConstants.spacing.regular,
                      children: [
                        Icon(
                          fu.FLucideIcons.folderOpen,
                          size: AppConstants.size.icon.extraExtraLarge,
                          color: context.colors.mutedForeground,
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
                context.go(AppRoutes.home.path);
              }
            },
          ),
        ],
        title: Text('Projects', style: context.typography.xl2.copyWith(fontWeight: FontWeight.w700)),
        suffixes: [
          fu.FHeaderAction(icon: const Icon(fu.FLucideIcons.plus), onPress: () => ProjectCommands.create(context)),
        ],
      ),
      child: content,
    );
  }
}
