import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:focus/core/config/theme/app_theme.dart';
import 'package:forui/forui.dart' as fu;

import '../../../../core/constants/layout_constants.dart';
import '../../domain/entities/project.dart';
import '../providers/project_provider.dart';
import '../widgets/project_card.dart';
import '../widgets/project_search_bar.dart';
import '../widgets/project_sort_filter_chips.dart';
import '../widgets/project_sort_order_selector.dart';
import 'project_detail_screen.dart';

class ProjectListScreen extends ConsumerStatefulWidget {
  const ProjectListScreen({super.key});

  @override
  ConsumerState<ProjectListScreen> createState() => _ProjectListScreenState();
}

class _ProjectListScreenState extends ConsumerState<ProjectListScreen> {
  final TextEditingController _searchController = TextEditingController();
  SortOrder _sortOrder = SortOrder.none;
  SortCriteria _selectedCriteria = SortCriteria.createdDate;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final projectsAsync = ref.watch(projectListProvider);

    return fu.FScaffold(
      header: fu.FHeader(title: Text('Projects', style: context.typography.lg)),
      child: projectsAsync.when(
        data: (projects) {
          final filtered = _applyFiltersAndSort(projects, _searchController.text, _sortOrder, _selectedCriteria);

          return Column(
            children: [
              ProjectSearchBar(controller: _searchController, onChanged: (s) => setState(() {})),
              Row(
                children: [
                  SizedBox(
                    width: 120.0, // Fixed width for the Sort Order Selector
                    child: ProjectSortOrderSelector(
                      selectedOrder: _sortOrder,
                      onChanged: (order) => setState(() => _sortOrder = order),
                    ),
                  ),
                  Expanded(
                    child: ProjectSortFilterChips(
                      selectedCriteria: _selectedCriteria,
                      onChanged: (criteria) => setState(() => _selectedCriteria = criteria),
                    ),
                  ),
                ],
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
    );
  }

  List<Project> _applyFiltersAndSort(List<Project> all, String query, SortOrder sortOrder, SortCriteria criteria) {
    var result = all;

    // Apply search filter
    final q = query.trim().toLowerCase();
    if (q.isNotEmpty) {
      result = result
          .where((p) => p.title.toLowerCase().contains(q) || (p.description?.toLowerCase().contains(q) ?? false))
          .toList();
    }

    // Apply multi-criteria sorting if order is not 'none'
    if (sortOrder != SortOrder.none) {
      result.sort((a, b) {
        int comparison = 0;

        switch (criteria) {
          case SortCriteria.createdDate:
            comparison = a.createdAt.compareTo(b.createdAt);
            break;
          case SortCriteria.recentlyModified:
            comparison = a.updatedAt.compareTo(b.updatedAt);
            break;
          case SortCriteria.startDate:
            if (a.startDate == null && b.startDate == null) {
              comparison = 0;
            } else if (a.startDate == null) {
              comparison = 1;
            } else if (b.startDate == null) {
              comparison = -1;
            } else {
              comparison = a.startDate!.compareTo(b.startDate!);
            }
            break;
          case SortCriteria.deadline:
            if (a.deadline == null && b.deadline == null) {
              comparison = 0;
            } else if (a.deadline == null) {
              comparison = 1;
            } else if (b.deadline == null) {
              comparison = -1;
            } else {
              comparison = a.deadline!.compareTo(b.deadline!);
            }
            break;
          case SortCriteria.title:
            comparison = a.title.compareTo(b.title);
            break;
        }

        return sortOrder == SortOrder.ascending ? comparison : -comparison;
      });
    }

    return result;
  }

  void _openDetail(BigInt projectId) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => ProjectDetailScreen(projectId: projectId)));
  }
}
