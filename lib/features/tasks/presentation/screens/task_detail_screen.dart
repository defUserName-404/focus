import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart' as fu;
import 'package:go_router/go_router.dart';

import '../../../../core/widgets/action_menu_button.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/routing/routes.dart';
import '../../../../core/utils/platform_utils.dart';
import '../../../home/presentation/widgets/section_header.dart';
import '../../../projects/presentation/providers/project_provider.dart';
import '../../../session/domain/entities/session_state.dart';
import '../../../session/presentation/commands/focus_commands.dart';
import '../../../session/presentation/providers/focus_session_provider.dart';
import '../../domain/entities/task_stats.dart';
import '../../domain/entities/task_extensions.dart';
import '../commands/task_commands.dart';
import '../providers/task_provider.dart';
import '../providers/task_stats_provider.dart';
import '../widgets/recent_sessions_section.dart';
import '../widgets/subtasks_section.dart';
import '../widgets/task_quick_actions.dart';
import '../widgets/task_stats_row.dart';
import '../widgets/task_summary_section.dart';

class TaskDetailScreen extends ConsumerWidget {
  final int taskId;
  final int projectId;
  final bool isEmbedded;
  final VoidCallback? onClose;

  const TaskDetailScreen({
    super.key,
    required this.taskId,
    required this.projectId,
    this.isEmbedded = false,
    this.onClose,
  });

  String get _taskIdString => taskId.toString();

  String get _projectIdString => projectId.toString();

  void _safePop(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRoutes.tasks.path);
    }
  }

  void _handleClose(BuildContext context) {
    if (onClose != null) {
      onClose!();
      return;
    }
    _safePop(context);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allTasksAsync = ref.watch(tasksByProjectProvider(_projectIdString));
    final projectAsync = ref.watch(projectByIdProvider(_projectIdString));
    final statsAsync = ref.watch(taskStatsProvider(_taskIdString));
    final recentAsync = ref.watch(recentSessionsProvider(_taskIdString));

    return allTasksAsync.when(
      loading: () => const fu.FScaffold(child: Center(child: fu.FCircularProgress())),
      error: (err, _) => fu.FScaffold(child: Center(child: Text('Error: $err'))),
      data: (allTasks) {
        final task = allTasks.where((t) => t.id == taskId).firstOrNull;

        if (task == null) {
          return fu.FScaffold(
            header: fu.FHeader.nested(
              title: const Text('Task Details'),
              prefixes: [fu.FHeaderAction.back(onPress: () => _safePop(context))],
            ),
            child: const Center(child: Text('Task not found')),
          );
        }

        final subtasks = allTasks.where((t) => t.parentTaskId == taskId).toList();
        final stats = statsAsync.value ?? TaskStats.empty;
        final recentSessions = recentAsync.value ?? [];
        final project = projectAsync.value;
        final activeSession = ref.watch(focusTimerProvider);
        final hasActiveSession =
            activeSession != null &&
            activeSession.taskId == taskId &&
            activeSession.state != SessionState.completed &&
            activeSession.state != SessionState.cancelled;

        final content = SingleChildScrollView(
          padding: EdgeInsets.only(bottom: AppConstants.spacing.extraLarge * 2),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: AppConstants.spacing.regular,
            children: [
              TaskSummarySection(
                task: task,
                projectName: project?.title,
                projectId: project?.id,
                onStatusChanged: (status) {
                  ref
                      .read(taskProvider(_projectIdString).notifier)
                      .updateTask(task.copyWith(status: status, updatedAt: DateTime.now()));
                },
              ),
              SectionHeader(title: 'Stats'),
              TaskStatsRow(stats: stats),
              SizedBox(height: AppConstants.spacing.regular),
              TaskQuickActions(task: task, projectId: projectId),
              SizedBox(height: AppConstants.spacing.regular),
              RecentSessionsSection(sessions: recentSessions),
              SizedBox(height: AppConstants.spacing.regular),
              if (subtasks.isNotEmpty)
                SubtasksSection(subtasks: subtasks, parentTask: task, projectIdString: _projectIdString),
            ],
          ),
        );

        if (isEmbedded) {
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
                    fu.FButton.icon(
                      variant: .ghost,
                      onPress: () => _handleClose(context),
                      child: const Icon(fu.FLucideIcons.arrowLeft),
                    ),
                    SizedBox(width: AppConstants.spacing.small),
                    Expanded(
                      child: Text(
                        'Task Details',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                      ),
                    ),
                    fu.FButton.icon(
                      variant: .primary,
                      onPress: () => TaskCommands.create(context, projectId: projectId),
                      child: Icon(fu.FLucideIcons.plus),
                    ),
                    SizedBox(width: AppConstants.spacing.small),
                    ActionMenuButton(
                      onEdit: () => TaskCommands.edit(context, task),
                      onDelete: () => TaskCommands.delete(
                        context,
                        ref,
                        task,
                        _projectIdString,
                        onDeleted: () => _handleClose(context),
                      ),
                    ),
                  ],
                ),
              ),
              if (!(task.isCompleted && !hasActiveSession))
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: AppConstants.spacing.large),
                  child: Align(
                    alignment: .centerLeft,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: context.isCompact ? double.infinity : 320),
                      child: fu.FButton(
                        onPress: () => FocusCommands.start(context, ref, taskId: task.id!),
                        prefix: Icon(
                          hasActiveSession ? fu.FLucideIcons.eye : fu.FLucideIcons.play,
                          size: AppConstants.size.icon.small,
                        ),
                        child: Text(hasActiveSession ? 'View Active Session' : 'Start Focus Session'),
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 8),
              Expanded(child: content),
            ],
          );
        }

        return fu.FScaffold(
          header: fu.FHeader.nested(
            title: const Text('Task Details'),
            prefixes: [fu.FHeaderAction.back(onPress: () => _safePop(context))],
            suffixes: [
              ActionMenuButton(
                onEdit: () => TaskCommands.edit(context, task),
                onDelete: () =>
                    TaskCommands.delete(context, ref, task, _projectIdString, onDeleted: () => _safePop(context)),
              ),
            ],
          ),
          footer: task.isCompleted && !hasActiveSession
              ? null
              : Padding(
                  padding: EdgeInsets.all(AppConstants.spacing.large),
                  child: Align(
                    alignment: .center,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: context.isCompact ? double.infinity : 320),
                      child: fu.FButton(
                        onPress: () => FocusCommands.start(context, ref, taskId: task.id!),
                        prefix: Icon(
                          hasActiveSession ? fu.FLucideIcons.eye : fu.FLucideIcons.play,
                          size: AppConstants.size.icon.small,
                        ),
                        child: Text(hasActiveSession ? 'View Active Session' : 'Start Focus Session'),
                      ),
                    ),
                  ),
                ),
          child: content,
        );
      },
    );
  }
}
