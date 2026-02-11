import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:focus/core/config/theme/app_theme.dart';
import 'package:focus/core/constants/app_constants.dart';
import 'package:focus/features/tasks/domain/entities/task_priority.dart';
import 'package:focus/features/tasks/presentation/providers/task_filter_state.dart';
import 'package:focus/features/tasks/presentation/providers/task_provider.dart';
import 'package:forui/forui.dart' as fu;

import '../../../../core/common/widgets/action_menu_button.dart';
import '../../../../core/common/widgets/filter_select.dart';
import '../../../../core/common/widgets/sort_filter_chips.dart';
import '../../../../core/common/widgets/sort_order_selector.dart';
import '../../../tasks/presentation/commands/task_commands.dart';
import '../commands/project_commands.dart';
import '../providers/project_provider.dart';
import '../widgets/project_detail_header.dart';
import '../widgets/project_search_bar.dart';
import '../widgets/task_card.dart';

class ProjectDetailScreen extends ConsumerStatefulWidget {
  final BigInt projectId;

  const ProjectDetailScreen({super.key, required this.projectId});

  @override
  ConsumerState<ProjectDetailScreen> createState() => _ProjectDetailScreenState();
}

class _ProjectDetailScreenState extends ConsumerState<ProjectDetailScreen> {
  final ScrollController _scrollController = ScrollController();
  final FocusNode _searchFocusNode = FocusNode();

  String get _projectIdString => widget.projectId.toString();
  BigInt get _projectId => widget.projectId;

  @override
  void dispose() {
    _scrollController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final projectsAsync = ref.watch(projectListProvider);
    final filteredAsync = ref.watch(filteredTasksProvider(_projectIdString));
    final allTasksAsync = ref.watch(tasksByProjectProvider(_projectIdString));
    final filter = ref.watch(taskListFilterProvider(_projectIdString));

    return fu.FScaffold(
      header: fu.FHeader.nested(
        prefixes: [fu.FHeaderAction.back(onPress: () => Navigator.pop(context))],
        title: projectsAsync.maybeWhen(
          data: (projects) {
            final project = projects.firstWhere((p) => p.id == _projectId, orElse: () => projects.first);
            return Text(project.title, style: context.typography.lg);
          },
          orElse: () => const Text('Project'),
        ),
        suffixes: [
          fu.FHeaderAction(
            icon: Icon(fu.FIcons.search),
            onPress: () {
              _scrollController.animateTo(0, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
              _searchFocusNode.requestFocus();
            },
          ),
          projectsAsync.maybeWhen(
            data: (projects) {
              final project = projects.firstWhere(
                (p) => p.id == _projectId,
                orElse: () => projects.first,
              );
              return ActionMenuButton(
                onEdit: () => ProjectCommands.edit(context, project),
                onDelete: () => ProjectCommands.delete(
                  context,
                  ref,
                  project,
                  onDeleted: () => Navigator.pop(context),
                ),
              );
            },
            orElse: () => const SizedBox.shrink(),
          ),
        ],
      ),
      footer: Padding(
        padding: EdgeInsets.all(AppConstants.spacing.large),
        child: fu.FButton(
          child: const Text('Create New Task'),
          onPress: () =>
              TaskCommands.create(context, ref, projectId: _projectId),
        ),
      ),
      child: projectsAsync.when(
        loading: () => const Center(child: fu.FCircularProgress()),
        error: (err, _) => Center(child: Text('Error: $err')),
        data: (projects) {
          final project = projects.firstWhere((p) => p.id == _projectId);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Project header ──
              allTasksAsync.when(
                data: (allTasks) {
                  final rootTasks = allTasks.where((t) => t.parentTaskId == null).toList();
                  return ProjectDetailHeader(project: project, tasks: rootTasks);
                },
                loading: () => const SizedBox.shrink(),
                error: (_, _) => const SizedBox.shrink(),
              ),

              // ── Search bar ──
              Padding(
                padding: EdgeInsets.symmetric(horizontal: AppConstants.spacing.regular),
                child: ProjectSearchBar(
                  focusNode: _searchFocusNode,
                  onChanged: (query) {
                    ref.read(taskListFilterProvider(_projectIdString).notifier).updateFilter(searchQuery: query);
                  },
                ),
              ),

              SizedBox(height: AppConstants.spacing.small),

              // ── Priority filter + Sort ──
              Padding(
                padding: EdgeInsets.symmetric(horizontal: AppConstants.spacing.regular),
                child: Row(
                  children: [
                    SizedBox(
                      width: 120,
                      child: FilterSelect<TaskPriority?>(
                        selected: filter.priorityFilter,
                        onChanged: (priority) {
                          ref
                              .read(taskListFilterProvider(_projectIdString).notifier)
                              .updateFilter(priorityFilter: priority);
                        },
                        options: TaskPriority.values,
                        hint: 'Priority',
                        allLabel: 'All',
                      ),
                    ),
                    SizedBox(width: AppConstants.spacing.small),
                    SizedBox(
                      width: 120,
                      child: SortOrderSelector<TaskSortOrder>(
                        selectedOrder: filter.sortOrder,
                        onChanged: (order) {
                          ref.read(taskListFilterProvider(_projectIdString).notifier).updateFilter(sortOrder: order);
                        },
                        orderOptions: TaskSortOrder.values,
                      ),
                    ),
                    Expanded(
                      child: SortFilterChips<TaskSortCriteria>(
                        selectedCriteria: filter.sortCriteria,
                        onChanged: (criteria) {
                          ref
                              .read(taskListFilterProvider(_projectIdString).notifier)
                              .updateFilter(sortCriteria: criteria);
                        },
                        criteriaOptions: TaskSortCriteria.values,
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
                      controller: _scrollController,
                      padding: EdgeInsets.symmetric(horizontal: AppConstants.spacing.regular, vertical: 4),
                      itemCount: rootTasks.length,
                      itemBuilder: (context, index) {
                        final task = rootTasks[index];
                        final subtasks = filteredTasks.where((t) => t.parentTaskId == task.id).toList();
                        return TaskCard(task: task, subtasks: subtasks, projectIdString: _projectIdString);
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
