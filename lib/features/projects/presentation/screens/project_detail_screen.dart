import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:focus/core/config/theme/app_theme.dart';
import 'package:focus/core/constants/layout_constants.dart';
import 'package:focus/features/tasks/domain/entities/task.dart';
import 'package:focus/features/tasks/domain/entities/task_priority.dart';
import 'package:focus/features/tasks/presentation/providers/task_provider.dart';
import 'package:focus/features/tasks/presentation/widgets/create_task_modal_content.dart';
import 'package:focus/features/tasks/presentation/widgets/edit_task_modal_content.dart';
import 'package:forui/forui.dart' as fu;

import '../providers/project_provider.dart';
import '../widgets/project_detail_header.dart';
import '../widgets/project_search_bar.dart';
import '../widgets/task_card.dart';
import '../widgets/task_sort_filter_chips.dart';

class ProjectDetailScreen extends ConsumerWidget {
  final BigInt projectId;

  const ProjectDetailScreen({super.key, required this.projectId});

  String get _projectIdString => projectId.toString();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projectsAsync = ref.watch(projectListProvider);
    final filteredAsync = ref.watch(filteredTasksProvider(_projectIdString));
    final allTasksAsync = ref.watch(tasksByProjectProvider(_projectIdString));
    final filter = ref.watch(taskListFilterStateProvider(_projectIdString));

    return fu.FScaffold(
      header: fu.FHeader.nested(
        prefixes: [fu.FHeaderAction.back(onPress: () => Navigator.pop(context))],
        title: projectsAsync.maybeWhen(
          data: (projects) {
            final project = projects.firstWhere((p) => p.id == projectId, orElse: () => projects.first);
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
              builder: (context) => CreateTaskModalContent(projectId: projectId, depth: 0),
            );
          },
        ),
      ),
      child: projectsAsync.when(
        loading: () => const Center(child: fu.FCircularProgress()),
        error: (err, _) => Center(child: Text('Error: $err')),
        data: (projects) {
          final project = projects.firstWhere((p) => p.id == projectId);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Project header (description, progress, meta) ──
              allTasksAsync.when(
                data: (allTasks) {
                  final rootTasks = allTasks.where((t) => t.parentTaskId == null).toList();
                  return ProjectDetailHeader(project: project, tasks: rootTasks);
                },
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              ),

              // ── Search bar ──
              Padding(
                padding: EdgeInsets.symmetric(horizontal: LayoutConstants.spacing.paddingRegular),
                child: ProjectSearchBar(
                  onChanged: (query) {
                    ref.read(taskListFilterStateProvider(_projectIdString).notifier).state = filter.copyWith(
                      searchQuery: query,
                    );
                  },
                ),
              ),

              SizedBox(height: LayoutConstants.spacing.paddingSmall),

              // ── Priority filter (FSelect) + Sort chips ──
              Padding(
                padding: EdgeInsets.symmetric(horizontal: LayoutConstants.spacing.paddingRegular),
                child: Row(
                  children: [
                    // Priority filter as FSelect
                    SizedBox(
                      width: 120,
                      child: _PriorityFilterSelect(
                        selected: filter.priorityFilter,
                        onChanged: (priority) {
                          ref.read(taskListFilterStateProvider(_projectIdString).notifier).state = filter.copyWith(
                            priorityFilter: priority,
                          );
                        },
                      ),
                    ),
                    // Sort chips
                    Expanded(
                      child: TaskSortFilterChips(
                        selectedCriteria: filter.sortCriteria,
                        onChanged: (criteria) {
                          ref.read(taskListFilterStateProvider(_projectIdString).notifier).state = filter.copyWith(
                            sortCriteria: criteria,
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),

              // ── Task list ──
              Expanded(
                child: filteredAsync.when(
                  loading: () => const Center(child: fu.FCircularProgress()),
                  error: (err, _) => Center(child: Text('Error: $err')),
                  data: (filteredTasks) {
                    final rootTasks = filteredTasks.where((t) => t.parentTaskId == null).toList();

                    if (rootTasks.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(fu.FIcons.clipboardList, size: 48, color: context.colors.mutedForeground),
                            const SizedBox(height: 12),
                            Text(
                              'No tasks yet',
                              style: context.typography.base.copyWith(color: context.colors.mutedForeground),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Create one to get started',
                              style: context.typography.sm.copyWith(color: context.colors.mutedForeground),
                            ),
                          ],
                        ),
                      );
                    }

                    return ListView.builder(
                      padding: EdgeInsets.symmetric(horizontal: LayoutConstants.spacing.paddingRegular, vertical: 4),
                      itemCount: rootTasks.length,
                      itemBuilder: (context, index) {
                        final task = rootTasks[index];
                        final subtasks = filteredTasks.where((t) => t.parentTaskId == task.id).toList();
                        return TaskCard(
                          task: task,
                          subtasks: subtasks,
                          projectIdString: _projectIdString,
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ── Priority filter FSelect widget ──────────────────────────────────────────

class _PriorityFilterSelect extends StatelessWidget {
  final TaskPriority? selected;
  final ValueChanged<TaskPriority?> onChanged;

  const _PriorityFilterSelect({required this.selected, required this.onChanged});

  static final Map<String, TaskPriority?> _items = {'All': null, for (final p in TaskPriority.values) p.label: p};

  @override
  Widget build(BuildContext context) {
    return fu.FSelect<TaskPriority?>(
      items: _items,
      hint: 'Priority',
      control: fu.FSelectControl.managed(
        initial: selected,
        onChange: (value) => onChanged(value),
      ),
    );
  }
}
