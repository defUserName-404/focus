import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:focus/core/config/theme/app_theme.dart';
import 'package:focus/core/constants/app_constants.dart';
import 'package:focus/features/tasks/domain/entities/task_priority.dart';
import 'package:focus/features/tasks/presentation/providers/task_filter_state.dart';
import 'package:focus/features/tasks/presentation/providers/task_provider.dart';
import 'package:forui/forui.dart' as fu;

import '../../../../core/common/widgets/action_menu_button.dart';
import '../../../../core/common/widgets/app_search_bar.dart';
import '../../../../core/common/widgets/filter_select.dart';
import '../../../../core/common/widgets/sort_filter_chips.dart';
import '../../../../core/common/widgets/sort_order_selector.dart';
import '../../../tasks/presentation/commands/task_commands.dart';
import '../../../tasks/presentation/widgets/task_card.dart';
import '../commands/project_commands.dart';
import '../providers/project_provider.dart';
import '../widgets/project_detail_header.dart';

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

  @override
  void dispose() {
    _scrollController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final projectById = projectByIdProvider(_projectIdString);
    final projectAsync = ref.watch(projectById);
    final filteredAsync = ref.watch(filteredTasksProvider(_projectIdString));
    final allTasksAsync = ref.watch(tasksByProjectProvider(_projectIdString));
    final filter = ref.watch(taskListFilterProvider(_projectIdString));

    return fu.FScaffold(
      header: fu.FHeader.nested(
        prefixes: [fu.FHeaderAction.back(onPress: () => Navigator.pop(context))],
        title: projectAsync.maybeWhen(
          data: (project) => Text(project?.title ?? 'Project', style: context.typography.lg),
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
          projectAsync.maybeWhen(
            data: (project) {
              if (project == null) return const SizedBox.shrink();
              return ActionMenuButton(
                onEdit: () => ProjectCommands.edit(context, project),
                onDelete: () => ProjectCommands.delete(context, ref, project, onDeleted: () => Navigator.pop(context)),
              );
            },
            orElse: () => const SizedBox.shrink(),
          ),
        ],
      ),
      footer: Padding(
        padding: EdgeInsets.all(AppConstants.spacing.large),
        child: fu.FButton(
          prefix: Icon(fu.FIcons.plus),
          child: const Text('Create New Task'),
          onPress: () => TaskCommands.create(context, ref, projectId: widget.projectId),
        ),
      ),
      child: projectAsync.when(
        loading: () => const Center(child: fu.FCircularProgress()),
        error: (err, _) => Center(child: Text('Error: $err')),
        data: (project) {
          if (project == null) {
            return const Center(child: Text('Project not found'));
          }

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

              // ── Filters & Search ──
              Column(
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
                            ref
                                .read(taskListFilterProvider(_projectIdString).notifier)
                                .updateFilter(priorityFilter: priority);
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
                            ref
                                .read(taskListFilterProvider(_projectIdString).notifier)
                                .updateFilter(sortCriteria: criteria);
                          },
                          criteriaOptions: TaskSortCriteria.values,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

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
                          spacing: AppConstants.spacing.regular,
                          children: [
                            Icon(
                              fu.FIcons.clipboardList,
                              size: AppConstants.size.icon.extraExtraLarge,
                              color: context.colors.mutedForeground,
                            ),
                            Text(
                              'No tasks yet',
                              style: context.typography.base.copyWith(color: context.colors.mutedForeground),
                            ),
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
