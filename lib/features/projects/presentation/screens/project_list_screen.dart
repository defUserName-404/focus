import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:focus/core/config/theme/app_theme.dart';
import 'package:forui/forui.dart' as fu;

import '../../../../core/constants/layout_constants.dart';
import '../../domain/entities/project.dart';
import '../providers/project_provider.dart';
import '../widgets/create_project_modal_content.dart';
import '../widgets/edit_project_modal_content.dart';
import '../widgets/project_card.dart';
import '../widgets/project_search_bar.dart';
import '../widgets/project_sort_filter_chips.dart';
import '../widgets/project_sort_order_selector.dart';
import 'project_detail_screen.dart';

class ProjectListScreen extends ConsumerWidget {
  const ProjectListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filteredAsync = ref.watch(filteredProjectListProvider);
    final filter = ref.watch(projectListFilterStateProvider);

    return fu.FScaffold(
      header: fu.FHeader.nested(
        prefixes: [fu.FHeaderAction.back(onPress: () => Navigator.pop(context))],
        title: Text('Projects', style: context.typography.lg),
      ),
      footer: Padding(
        padding: EdgeInsets.all(LayoutConstants.spacing.paddingLarge),
        child: fu.FButton(
          child: const Text('Create New Project'),
          onPress: () async {
            final newProject = await fu.showFSheet<Project>(
              context: context,
              side: fu.FLayout.btt,
              builder: (context) => const CreateProjectModalContent(),
            );

            if (newProject != null && newProject.id != null) {
              if (context.mounted) {
                _openDetail(context, newProject.id!);
              }
            }
          },
        ),
      ),
      child: Column(
        children: [
          ProjectSearchBar(
            onChanged: (query) {
              ref.read(projectListFilterStateProvider.notifier).state = filter.copyWith(searchQuery: query);
            },
          ),
          Row(
            children: [
              SizedBox(
                width: 120.0,
                child: ProjectSortOrderSelector(
                  selectedOrder: filter.sortOrder,
                  onChanged: (order) {
                    ref.read(projectListFilterStateProvider.notifier).state = filter.copyWith(sortOrder: order);
                  },
                ),
              ),
              Expanded(
                child: ProjectSortFilterChips(
                  selectedCriteria: filter.sortCriteria,
                  onChanged: (criteria) {
                    ref.read(projectListFilterStateProvider.notifier).state = filter.copyWith(sortCriteria: criteria);
                  },
                ),
              ),
            ],
          ),
          Expanded(
            child: filteredAsync.when(
              loading: () => const Center(child: fu.FCircularProgress()),
              error: (err, _) => Center(child: Text('Error: $err')),
              data: (projects) => projects.isEmpty
                  ? const Center(child: Text('No projects found'))
                  : ListView.builder(
                      padding: EdgeInsets.all(LayoutConstants.spacing.paddingRegular),
                      itemCount: projects.length,
                      itemBuilder: (context, index) {
                        final project = projects[index];
                        return ProjectCard(
                          project: project,
                          onTap: () => project.id != null ? _openDetail(context, project.id!) : null,
                          onEdit: () => _editProject(context, project),
                          onDelete: () => _confirmDelete(context, ref, project),
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }

  void _openDetail(BuildContext context, BigInt projectId) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => ProjectDetailScreen(projectId: projectId)));
  }

  void _editProject(BuildContext context, Project project) {
    fu.showFSheet(
      context: context,
      side: fu.FLayout.btt,
      builder: (context) => EditProjectModalContent(project: project),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, Project project) {
    showAdaptiveDialog(
      context: context,
      builder: (ctx) => AlertDialog.adaptive(
        title: const Text('Delete Project'),
        content: Text('Are you sure you want to delete "${project.title}"? All tasks will also be deleted.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              if (project.id != null) {
                ref.read(projectProvider.notifier).deleteProject(project.id!);
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
