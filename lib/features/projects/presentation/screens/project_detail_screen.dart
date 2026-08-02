import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart' as fu;
import 'package:go_router/go_router.dart';

import 'package:focus/core/config/theme/app_theme.dart';
import 'package:focus/core/constants/app_constants.dart';
import 'package:focus/features/tasks/presentation/providers/task_filter_state.dart';
import 'package:focus/features/tasks/presentation/providers/task_provider.dart';

import '../../../../core/widgets/action_menu_button.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../../../core/widgets/list_toolbar.dart';
import '../../../tasks/domain/entities/task.dart';
import '../../../tasks/presentation/commands/task_commands.dart';
import '../../../tasks/presentation/widgets/project_tasks_filter_panel.dart';
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

  int _activeFilterCount(TaskListFilterState filter) {
    var count = 0;
    if (filter.priorityFilter != null) count++;
    if (filter.completionFilter != TaskCompletionFilter.all) count++;
    if (filter.sortCriteria != TaskSortCriteria.recentlyModified) count++;
    if (filter.sortOrder != TaskSortOrder.none) count++;
    return count;
  }

  Widget _buildTasksToolbar(TaskListFilterState filter) {
    final notifier = ref.read(taskListFilterProvider(_projectIdString).notifier);
    return ListToolbar(
      searchHint: 'Search tasks...',
      searchFocusNode: _searchFocusNode,
      onSearchChanged: (query) => notifier.updateFilter(searchQuery: query),
      filterPanel: ProjectTasksFilterPanel(projectIdString: _projectIdString),
      activeFilterCount: _activeFilterCount(filter),
      onReset: () => notifier.reset(),
      activeFilters: [
        if (filter.priorityFilter != null)
          ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 44),
            child: fu.FButton(
              size: .xs,
              mainAxisSize: .min,
              variant: .secondary,
              suffix: const Icon(fu.FLucideIcons.x),
              onPress: () => notifier.updateFilter(priorityFilter: null),
              child: Text(filter.priorityFilter!.label),
            ),
          ),
        if (filter.completionFilter != TaskCompletionFilter.all)
          ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 44),
            child: fu.FButton(
              size: .xs,
              mainAxisSize: .min,
              variant: .secondary,
              suffix: const Icon(fu.FLucideIcons.x),
              onPress: () => notifier.updateFilter(completionFilter: TaskCompletionFilter.all),
              child: Text(filter.completionFilter.label),
            ),
          ),
        if (filter.sortCriteria != TaskSortCriteria.recentlyModified)
          ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 44),
            child: fu.FButton(
              size: .xs,
              mainAxisSize: .min,
              variant: .secondary,
              suffix: const Icon(fu.FLucideIcons.x),
              onPress: () => notifier.updateFilter(sortCriteria: TaskSortCriteria.recentlyModified),
              child: Text(filter.sortCriteria.label),
            ),
          ),
        if (filter.sortOrder != TaskSortOrder.none)
          ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 44),
            child: fu.FButton(
              size: .xs,
              mainAxisSize: .min,
              variant: .secondary,
              suffix: const Icon(fu.FLucideIcons.x),
              onPress: () => notifier.updateFilter(sortOrder: TaskSortOrder.none),
              child: Text(filter.sortOrder.label),
            ),
          ),
      ],
    );
  }

  Widget _buildTasksList(List<Task> filteredTasks) {
    final rootTasks = filteredTasks.where((t) => t.parentTaskId == null).toList();

    if (rootTasks.isEmpty) {
      return const AppEmptyState(
        icon: fu.FLucideIcons.clipboardList,
        message: 'No tasks yet',
        detail: 'Create a task to get started on this project.',
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: EdgeInsets.symmetric(vertical: AppConstants.spacing.regular),
      itemCount: rootTasks.length,
      itemBuilder: (context, index) {
        final task = rootTasks[index];
        final subtasks = filteredTasks.where((t) => t.parentTaskId == task.id).toList();
        return TaskCard(task: task, subtasks: subtasks, projectIdString: _projectIdString);
      },
    );
  }

  List<Task> _boardTasks(List<Task> filteredTasks) {
    return filteredTasks.where((t) => t.parentTaskId == null).toList();
  }

  Widget _buildTabBody({
    required List<Task> filteredTasks,
    required List<Task> allTasks,
    required TaskListFilterState filter,
  }) {
    return switch (_tab) {
      ProjectDetailTab.overview => ListView(
        padding: EdgeInsets.symmetric(vertical: AppConstants.spacing.regular),
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
          _buildTasksToolbar(filter),
          SizedBox(height: AppConstants.spacing.small),
          Expanded(child: _buildTasksList(filteredTasks)),
        ],
      ),
      ProjectDetailTab.board => Column(
        children: [
          _buildTasksToolbar(filter),
          SizedBox(height: AppConstants.spacing.small),
          Expanded(child: TasksBoardView(tasks: _boardTasks(filteredTasks))),
        ],
      ),
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
          fu.FTooltip(
            tipBuilder: (context, _) => const Text('Search tasks'),
            child: fu.FHeaderAction(
              icon: Icon(fu.FLucideIcons.search),
              semanticsLabel: 'Search tasks',
              onPress: () {
                _scrollController.animateTo(0, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
                setState(() => _tab = ProjectDetailTab.tasks);
                _searchFocusNode.requestFocus();
              },
            ),
          ),
          fu.FTooltip(
            tipBuilder: (context, _) => const Text('Create task'),
            child: fu.FHeaderAction(
              icon: const Icon(fu.FLucideIcons.plus),
              semanticsLabel: 'Create task',
              onPress: () => TaskCommands.create(context, projectId: widget.projectId),
            ),
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
