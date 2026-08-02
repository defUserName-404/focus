import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart' as fu;
import 'package:go_router/go_router.dart';

import 'package:focus/core/config/theme/app_theme.dart';
import 'package:focus/core/constants/app_constants.dart';
import 'package:focus/features/tasks/domain/entities/task_priority.dart';
import 'package:focus/features/tasks/presentation/providers/task_filter_state.dart';
import 'package:focus/features/tasks/presentation/providers/task_provider.dart';

import '../../../../core/widgets/action_menu_button.dart';
import '../../../../core/widgets/app_search_bar.dart';
import '../../../../core/widgets/filter_select.dart';
import '../../../../core/widgets/sort_filter_chips.dart';
import '../../../../core/widgets/sort_order_selector.dart';
import '../../../tasks/domain/entities/task.dart';
import '../../../tasks/presentation/commands/task_commands.dart';
import '../../../tasks/presentation/widgets/task_card.dart';
import '../../../tasks/presentation/widgets/tasks_board_view.dart';
import '../commands/project_commands.dart';
import '../models/project_detail_tab.dart';
import '../providers/project_provider.dart';
import '../widgets/project_detail_header.dart';
import '../widgets/project_detail_tab_bar.dart';
import '../widgets/project_milestones_panel.dart';
import '../widgets/project_timeline_view.dart';

class ProjectDetailScreen extends ConsumerStatefulWidget {
  final int projectId;
  final bool isEmbedded;

  const ProjectDetailScreen({super.key, required this.projectId, this.isEmbedded = false});

  @override
  ConsumerState<ProjectDetailScreen> createState() => _ProjectDetailScreenState();
}

class _ProjectDetailScreenState extends ConsumerState<ProjectDetailScreen> {
  final ScrollController _scrollController = ScrollController();
  final FocusNode _searchFocusNode = FocusNode();
  ProjectDetailTab _tab = ProjectDetailTab.tasks;

  String get _projectIdString => widget.projectId.toString();

  @override
  void dispose() {
    _scrollController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  Widget _buildTasksFilters(TaskListFilterState filter) {
    return Column(
      children: [
        AppSearchBar(
          focusNode: _searchFocusNode,
          hint: 'Search tasks...',
          onChanged: (query) {
            ref.read(taskListFilterProvider(_projectIdString).notifier).updateFilter(searchQuery: query);
          },
        ),
        Row(
          children: [
            SizedBox(
              width: 120,
              child: FilterSelect<TaskPriority?>(
                selected: filter.priorityFilter,
                onChanged: (priority) {
                  ref.read(taskListFilterProvider(_projectIdString).notifier).updateFilter(priorityFilter: priority);
                },
                options: TaskPriority.values,
                hint: 'Priority',
                allLabel: 'All',
              ),
            ),
            SizedBox(
              width: 100,
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
                  ref.read(taskListFilterProvider(_projectIdString).notifier).updateFilter(sortCriteria: criteria);
                },
                criteriaOptions: TaskSortCriteria.values,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTasksList(List<Task> filteredTasks) {
    final rootTasks = filteredTasks.where((t) => t.parentTaskId == null).toList();

    if (rootTasks.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: AppConstants.spacing.regular,
          children: [
            Icon(
              fu.FLucideIcons.clipboardList,
              size: AppConstants.size.icon.extraExtraLarge,
              color: context.colors.mutedForeground,
            ),
            Text('No tasks yet', style: context.typography.md.copyWith(color: context.colors.mutedForeground)),
          ],
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: EdgeInsets.symmetric(vertical: AppConstants.spacing.small),
      itemCount: rootTasks.length,
      itemBuilder: (context, index) {
        final task = rootTasks[index];
        final subtasks = filteredTasks.where((t) => t.parentTaskId == task.id).toList();
        return TaskCard(task: task, subtasks: subtasks, projectIdString: _projectIdString);
      },
    );
  }

  Widget _buildTabBody({
    required List<Task> filteredTasks,
    required List<Task> allTasks,
    required TaskListFilterState filter,
  }) {
    return switch (_tab) {
      ProjectDetailTab.overview => ListView(
        padding: EdgeInsets.symmetric(vertical: AppConstants.spacing.small),
        children: [
          Text('Project overview', style: context.typography.sm.copyWith(fontWeight: FontWeight.w700)),
          SizedBox(height: AppConstants.spacing.small),
          Text(
            '${allTasks.where((t) => t.parentTaskId == null).length} root tasks · '
            '${allTasks.where((t) => t.isCompleted).length} completed',
            style: context.typography.sm.copyWith(color: context.colors.mutedForeground),
          ),
          SizedBox(height: AppConstants.spacing.regular),
          Text(
            'Use the tabs above to manage tasks on a board, track milestones, or review the timeline.',
            style: context.typography.sm.copyWith(color: context.colors.mutedForeground, height: 1.45),
          ),
        ],
      ),
      ProjectDetailTab.tasks => Column(
        children: [
          _buildTasksFilters(filter),
          Expanded(
            child: filteredTasks.isEmpty && filter.searchQuery.isEmpty && filter.priorityFilter == null
                ? _buildTasksList(const [])
                : _buildTasksList(filteredTasks),
          ),
        ],
      ),
      ProjectDetailTab.board => TasksBoardView(tasks: allTasks.where((t) => t.parentTaskId == null).toList()),
      ProjectDetailTab.milestones => ProjectMilestonesPanel(projectId: widget.projectId),
      ProjectDetailTab.timeline => ProjectTimelineView(projectId: widget.projectId, tasks: allTasks),
    };
  }

  @override
  Widget build(BuildContext context) {
    final projectById = projectByIdProvider(_projectIdString);
    final projectAsync = ref.watch(projectById);
    final filteredAsync = ref.watch(filteredTasksProvider(_projectIdString));
    final allTasksAsync = ref.watch(tasksByProjectProvider(_projectIdString));
    final filter = ref.watch(taskListFilterProvider(_projectIdString));

    final content = projectAsync.when(
      loading: () => const Center(child: fu.FCircularProgress()),
      error: (err, _) => Center(child: Text('Error: $err')),
      data: (project) {
        if (project == null) {
          return const Center(child: Text('Project not found'));
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            allTasksAsync.when(
              data: (allTasks) {
                final rootTasks = allTasks.where((t) => t.parentTaskId == null).toList();
                return ProjectDetailHeader(project: project, tasks: rootTasks);
              },
              loading: () => const SizedBox.shrink(),
              error: (_, _) => const SizedBox.shrink(),
            ),
            ProjectDetailTabBar(selected: _tab, onChanged: (tab) => setState(() => _tab = tab)),
            SizedBox(height: AppConstants.spacing.small),
            Expanded(
              child: filteredAsync.when(
                loading: () => const Center(child: fu.FCircularProgress()),
                error: (err, _) => Center(child: Text('Error: $err')),
                data: (filteredTasks) {
                  return allTasksAsync.when(
                    loading: () => const Center(child: fu.FCircularProgress()),
                    error: (err, _) => Center(child: Text('Error: $err')),
                    data: (allTasks) => _buildTabBody(filteredTasks: filteredTasks, allTasks: allTasks, filter: filter),
                  );
                },
              ),
            ),
          ],
        );
      },
    );

    if (widget.isEmbedded) {
      return Column(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(
              AppConstants.spacing.large,
              AppConstants.spacing.large,
              AppConstants.spacing.large,
              AppConstants.spacing.small,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Project Details',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                  ),
                ),
                projectAsync.maybeWhen(
                  data: (project) {
                    if (project == null) return const SizedBox.shrink();
                    return ActionMenuButton(
                      onEdit: () => ProjectCommands.edit(context, project),
                      onSaveAsTemplate: () => ProjectCommands.saveAsTemplate(context, ref, project),
                      onDelete: () => ProjectCommands.delete(context, ref, project),
                    );
                  },
                  orElse: () => const SizedBox.shrink(),
                ),
                SizedBox(width: AppConstants.spacing.small),
                fu.FButton.icon(
                  onPress: () => TaskCommands.create(context, projectId: widget.projectId),
                  child: Icon(fu.FLucideIcons.plus),
                ),
              ],
            ),
          ),
          Expanded(child: content),
        ],
      );
    }

    return fu.FScaffold(
      header: fu.FHeader.nested(
        prefixes: [fu.FHeaderAction.back(onPress: () => context.pop())],
        title: Text('Project Details'),
        suffixes: [
          fu.FHeaderAction(
            icon: Icon(fu.FLucideIcons.search),
            onPress: () {
              _scrollController.animateTo(0, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
              setState(() => _tab = ProjectDetailTab.tasks);
              _searchFocusNode.requestFocus();
            },
          ),
          fu.FHeaderAction(
            icon: const Icon(fu.FLucideIcons.plus),
            onPress: () => TaskCommands.create(context, projectId: widget.projectId),
          ),
          projectAsync.maybeWhen(
            data: (project) {
              if (project == null) return const SizedBox.shrink();
              return ActionMenuButton(
                onEdit: () => ProjectCommands.edit(context, project),
                onSaveAsTemplate: () => ProjectCommands.saveAsTemplate(context, ref, project),
                onDelete: () => ProjectCommands.delete(context, ref, project, onDeleted: () => context.pop()),
              );
            },
            orElse: () => const SizedBox.shrink(),
          ),
        ],
      ),
      child: content,
    );
  }
}
