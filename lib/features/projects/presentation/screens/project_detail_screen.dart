import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:focus/core/config/theme/app_theme.dart';
import 'package:focus/core/constants/layout_constants.dart';
import 'package:focus/features/tasks/domain/entities/task.dart';
import 'package:focus/features/tasks/presentation/providers/task_provider.dart';
import 'package:focus/features/tasks/presentation/widgets/create_task_modal_content.dart';
import 'package:forui/forui.dart' as fu;

import '../providers/project_provider.dart';
import '../widgets/project_detail_header.dart';
import '../widgets/project_search_bar.dart';
import '../widgets/task_card.dart';
import '../widgets/task_sort_filter_chips.dart';

class ProjectDetailScreen extends ConsumerStatefulWidget {
  final BigInt projectId;

  const ProjectDetailScreen({super.key, required this.projectId});

  @override
  ConsumerState<ProjectDetailScreen> createState() => _ProjectDetailScreenState();
}

class _ProjectDetailScreenState extends ConsumerState<ProjectDetailScreen> {
  final TextEditingController _searchController = TextEditingController();
  TaskSortCriteria _sortCriteria = TaskSortCriteria.recentlyModified;
  bool _showSearch = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String get _projectIdString => widget.projectId.toString();

  @override
  Widget build(BuildContext context) {
    final tasksAsync = ref.watch(tasksByProjectProvider(_projectIdString));
    final projectsAsync = ref.watch(projectListProvider);

    return fu.FScaffold(
      header: fu.FHeader.nested(
        prefixes: [fu.FHeaderAction.back(onPress: () => Navigator.pop(context))],
        title: projectsAsync.maybeWhen(
          data: (projects) {
            final project = projects.firstWhere((p) => p.id == widget.projectId, orElse: () => projects.first);
            return Text(project.title, style: context.typography.lg);
          },
          orElse: () => const Text('Project'),
        ),
      ),
      footer: Padding(
        padding: EdgeInsets.all(LayoutConstants.spacing.paddingLarge),
        child: fu.FButton(
          child: const Text('Create New Task'),
          onPress: () async {
            await fu.showFSheet<Task>(
              context: context,
              side: fu.FLayout.btt,
              builder: (context) => CreateTaskModalContent(projectId: widget.projectId),
            );
          },
        ),
      ),
      child: tasksAsync.when(
        loading: () => const Center(child: fu.FCircularProgress()),
        error: (err, _) => Center(child: Text('Error: $err')),
        data: (tasks) => projectsAsync.when(
          loading: () => const Center(child: fu.FCircularProgress()),
          error: (err, _) => Center(child: Text('Error: $err')),
          data: (projects) {
            final project = projects.firstWhere((p) => p.id == widget.projectId);
            final rootTasks = tasks.where((t) => t.parentTaskId == null).toList();
            final filtered = _applySearchAndSort(rootTasks);

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Project header (title, desc, progress, meta) ──
                ProjectDetailHeader(project: project, tasks: rootTasks),

                // ── Search bar
                Padding(
                  padding: EdgeInsets.only(
                    left: LayoutConstants.spacing.paddingRegular,
                    right: LayoutConstants.spacing.paddingRegular,
                    bottom: 4,
                  ),
                  child: ProjectSearchBar(controller: _searchController, onChanged: (_) => setState(() {})),
                ),

                // ── Sort chips (same pattern as ProjectListScreen) ──
                TaskSortFilterChips(
                  selectedCriteria: _sortCriteria,
                  onChanged: (c) => setState(() => _sortCriteria = c),
                ),

                // ── Task list ──
                Expanded(
                  child: filtered.isEmpty
                      ? const Center(
                          child: Text('No tasks. Create one!', style: TextStyle(color: Color(0xFF555555))),
                        )
                      : ListView.builder(
                          padding: EdgeInsets.symmetric(
                            horizontal: LayoutConstants.spacing.paddingRegular,
                            vertical: 4,
                          ),
                          itemCount: filtered.length,
                          itemBuilder: (context, index) {
                            final task = filtered[index];
                            final subtasks = tasks.where((t) => t.parentTaskId == task.id).toList();
                            return TaskCard(
                              task: task,
                              subtasks: subtasks,
                              projectIdString: _projectIdString,
                              onTaskTap: task.id != null ? () => _openTaskDetail(task) : null,
                              onSubtaskTap: (st) => _openTaskDetail(st),
                            );
                          },
                        ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  List<Task> _applySearchAndSort(List<Task> tasks) {
    var result = tasks;

    // Search
    final q = _searchController.text.trim().toLowerCase();
    if (q.isNotEmpty) {
      result = result
          .where((t) => t.title.toLowerCase().contains(q) || (t.description?.toLowerCase().contains(q) ?? false))
          .toList();
    }

    // Sort
    result = List.of(result);
    result.sort((a, b) {
      switch (_sortCriteria) {
        case TaskSortCriteria.recentlyModified:
          return b.updatedAt.compareTo(a.updatedAt);
        case TaskSortCriteria.deadline:
          if (a.endDate == null && b.endDate == null) return 0;
          if (a.endDate == null) return 1;
          if (b.endDate == null) return -1;
          return a.endDate!.compareTo(b.endDate!);
        case TaskSortCriteria.priority:
          return a.priority.index.compareTo(b.priority.index);
        case TaskSortCriteria.title:
          return a.title.compareTo(b.title);
        case TaskSortCriteria.createdDate:
          return b.createdAt.compareTo(a.createdAt);
      }
    });

    return result;
  }

  void _openTaskDetail(Task task) {
    // Navigator.of(context).push(
    //   MaterialPageRoute(
    //     builder: (_) => TaskDetailScreen(taskId: task.id!, projectId: widget.projectId),
    //   ),
    // );
  }
}
