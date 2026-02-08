import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart' as fu;

import '../../../../core/constants/layout_constants.dart';
import '../../domain/entities/project.dart';
import '../providers/project_provider.dart';
import '../widgets/project_card.dart';
import '../widgets/project_search_filter.dart';
import 'project_detail_screen.dart';

class ProjectListScreen extends ConsumerStatefulWidget {
  const ProjectListScreen({super.key});

  @override
  ConsumerState<ProjectListScreen> createState() => _ProjectListScreenState();
}

class _ProjectListScreenState extends ConsumerState<ProjectListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String? _selectedFilter;

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
          final filtered = _applyFilters(projects, _searchController.text, _selectedFilter);

          return Column(
            children: [
              ProjectSearchFilter(
                controller: _searchController,
                filters: const ['Active', 'Completed'],
                selectedFilter: _selectedFilter,
                onSearchChanged: (s) => setState(() {}),
                onFilterChanged: (v) => setState(() => _selectedFilter = v),
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

  List<Project> _applyFilters(List<Project> all, String query, String? filter) {
    var result = all;
    final q = query.trim().toLowerCase();
    if (q.isNotEmpty) {
      result = result
          .where((p) => p.title.toLowerCase().contains(q) || (p.description?.toLowerCase().contains(q) ?? false))
          .toList();
    }
    // simple filter placeholder (no status on Project domain yet)
    if (filter != null && filter.isNotEmpty) {
      if (filter == 'Completed') {
        result = result.where((p) => p.title.toLowerCase().contains('done')).toList();
      } else if (filter == 'Active') {
        result = result.where((p) => !p.title.toLowerCase().contains('done')).toList();
      }
    }
    return result;
  }

  void _openDetail(BigInt projectId) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => ProjectDetailScreen(projectId: projectId)));
  }
}
