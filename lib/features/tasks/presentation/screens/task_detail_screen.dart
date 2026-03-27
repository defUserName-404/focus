import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart' as fu;
import 'package:go_router/go_router.dart';

import '../../../../core/widgets/action_menu_button.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../home/presentation/widgets/section_header.dart';
import '../../../projects/presentation/providers/project_provider.dart';
import '../../../session/domain/entities/session_state.dart';
import '../../../session/presentation/commands/focus_commands.dart';
import '../../../session/presentation/providers/focus_session_provider.dart';
import '../../domain/entities/task_stats.dart';
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

  const TaskDetailScreen({super.key, required this.taskId, required this.projectId, this.isEmbedded = false});

  String get _taskIdString => taskId.toString();

  String get _projectIdString => projectId.toString();

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
              prefixes: [fu.FHeaderAction.back(onPress: () => context.pop())],
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
              TaskSummarySection(task: task, projectName: project?.title, projectId: project?.id),
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
                    Expanded(
                      child: Text(
                        'Task Details',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                      ),
                    ),
                    fu.FButton.icon(
                      onPress: () => TaskCommands.create(context, projectId: projectId),
                      child: Icon(fu.FIcons.plus),
                    ),
                    SizedBox(width: AppConstants.spacing.small),
                    ActionMenuButton(
                      onEdit: () => TaskCommands.edit(context, task),
                      onDelete: () => TaskCommands.delete(context, ref, task, _projectIdString),
                    ),
                  ],
                ),
              ),
              if (!(task.isCompleted && !hasActiveSession))
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: AppConstants.spacing.large),
                  child: fu.FButton(
                    onPress: () => FocusCommands.start(context, ref, taskId: task.id!),
                    prefix: Icon(hasActiveSession ? fu.FIcons.eye : fu.FIcons.play, size: AppConstants.size.icon.small),
                    child: Text(hasActiveSession ? 'View Active Session' : 'Start Focus Session'),
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
            prefixes: [fu.FHeaderAction.back(onPress: () => context.pop())],
            suffixes: [
              ActionMenuButton(
                onEdit: () => TaskCommands.edit(context, task),
                onDelete: () =>
                    TaskCommands.delete(context, ref, task, _projectIdString, onDeleted: () => context.pop()),
              ),
            ],
          ),
          footer: task.isCompleted && !hasActiveSession
              ? null
              : Padding(
                  padding: EdgeInsets.all(AppConstants.spacing.large),
                  child: fu.FButton(
                    onPress: () => FocusCommands.start(context, ref, taskId: task.id!),
                    prefix: Icon(hasActiveSession ? fu.FIcons.eye : fu.FIcons.play, size: AppConstants.size.icon.small),
                    child: Text(hasActiveSession ? 'View Active Session' : 'Start Focus Session'),
                  ),
                ),
          child: content,
        );
      },
    );
  }
}
