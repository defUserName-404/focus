import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart' as fu;

import '../../../../core/constants/layout_constants.dart';
import '../../domain/entities/project.dart';
import '../providers/project_provider.dart';
import '../widgets/project_card.dart';
import '../widgets/project_search_bar.dart';
import '../widgets/project_sort_dropdown.dart';
import 'project_detail_screen.dart';

class ProjectListScreen extends ConsumerStatefulWidget {
  const ProjectListScreen({super.key});

  @override
  ConsumerState<ProjectListScreen> createState() => _ProjectListScreenState();
}

class _ProjectListScreenState extends ConsumerState<ProjectListScreen> {
  final TextEditingController _searchController = TextEditingController();
  ProjectSortOrder _sortOrder = ProjectSortOrder.createdDate;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final projectsAsync = ref.watch(projectListProvider);

    return fu.FScaffold(
      header: const fu.FHeader(title: Text('Projects')),
      child: projectsAsync.when(
        data: (projects) {
          final filtered = _applyFiltersAndSort(projects, _searchController.text, _sortOrder);

          return Column(
            children: [
              Padding(
                padding: EdgeInsets.all(LayoutConstants.spacing.paddingRegular),
                child: Row(
                  spacing: LayoutConstants.spacing.paddingSmall,
                  children: [
                    Expanded(
                      child: ProjectSearchBar(controller: _searchController, onChanged: (s) => setState(() {})),
                    ),
                    SizedBox(
                      width: 200,
                      child: ProjectSortDropdown(
                        selectedSort: _sortOrder,
                        onChanged: (order) => setState(() => _sortOrder = order),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: filtered.isEmpty
                    ? Center(child: Text('No projects. Create one!'))
                    : ListView.builder(
                        padding: EdgeInsets.all(LayoutConstants.spacing.paddingRegular),
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final Project project = filtered[index];
                          return ProjectCard(
                            project: project,
                            onTap: () => project.id != null ? _openDetail(project.id!) : null,
                            onEdit: () {},
                            onDelete: () {},
                          );
                        },
                      ),
              ),
            ],
          );
        },
        loading: () => const Center(child: fu.FCircularProgress()),
        error: (err, _) => Center(child: Text('Error: $err')),
      ),
      // floatingAction: fu.FButton.icon(
      //   icon: fu.FIcon.add,
      //   child: const Text('New'),
      //   onPress: () => _showCreateProjectDialog(),
      // ),
    );
  }

  List<Project> _applyFiltersAndSort(List<Project> all, String query, ProjectSortOrder sortOrder) {
    var result = all;

    // Apply search filter
    final q = query.trim().toLowerCase();
    if (q.isNotEmpty) {
      result = result
          .where((p) => p.title.toLowerCase().contains(q) || (p.description?.toLowerCase().contains(q) ?? false))
          .toList();
    }

    // Apply sorting
    result.sort((a, b) {
      switch (sortOrder) {
        case ProjectSortOrder.createdDate:
          return b.createdAt.compareTo(a.createdAt); // Most recent first
        case ProjectSortOrder.deadline:
          // Projects without deadline go to end
          if (a.deadline == null && b.deadline == null) return 0;
          if (a.deadline == null) return 1;
          if (b.deadline == null) return -1;
          return a.deadline!.compareTo(b.deadline!); // Earliest deadline first
      }
    });

    return result;
  }

  void _openDetail(BigInt projectId) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => ProjectDetailScreen(projectId: projectId)));
  }
}
