import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart' as fu;

import '../../../../core/common/widgets/action_menu_button.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../focus/domain/entities/session_state.dart';
import '../../../focus/presentation/commands/focus_commands.dart';
import '../../../focus/presentation/providers/focus_session_provider.dart';
import '../../../home/presentation/widgets/section_header.dart';
import '../../../projects/presentation/providers/project_provider.dart';
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
  final BigInt taskId;
  final BigInt projectId;

  const TaskDetailScreen({
    super.key,
    required this.taskId,
    required this.projectId,
  });

  String get _taskIdString => taskId.toString();

  String get _projectIdString => projectId.toString();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allTasksAsync = ref.watch(tasksByProjectProvider(_projectIdString));
    final projectAsync = ref.watch(projectByIdProvider(_projectIdString));
    final statsAsync = ref.watch(taskStatsProvider(_taskIdString));
    final recentAsync = ref.watch(recentSessionsProvider(_taskIdString));

    return allTasksAsync.when(
      loading: () =>
          const fu.FScaffold(child: Center(child: fu.FCircularProgress())),
      error: (err, _) =>
          fu.FScaffold(child: Center(child: Text('Error: $err'))),
      data: (allTasks) {
        final task = allTasks.where((t) => t.id == taskId).firstOrNull;

        if (task == null) {
          return fu.FScaffold(
            header: fu.FHeader.nested(
              title: const Text('Task Details'),
              prefixes: [
                fu.FHeaderAction.back(onPress: () => Navigator.pop(context)),
              ],
            ),
            child: const Center(child: Text('Task not found')),
          );
        }

        final subtasks = allTasks
            .where((t) => t.parentTaskId == taskId)
            .toList();
        final stats = statsAsync.value ?? TaskStats.empty;
        final recentSessions = recentAsync.value ?? [];
        final project = projectAsync.value;
        final activeSession = ref.watch(focusTimerProvider);
        final hasActiveSession =
            activeSession != null &&
            activeSession.taskId == taskId &&
            activeSession.state != SessionState.completed &&
            activeSession.state != SessionState.cancelled;

        return fu.FScaffold(
          header: fu.FHeader.nested(
            title: const Text('Task Details'),
            prefixes: [
              fu.FHeaderAction.back(onPress: () => Navigator.pop(context)),
            ],
            suffixes: [
              ActionMenuButton(
                onEdit: () => TaskCommands.edit(context, task),
                onDelete: () => TaskCommands.delete(
                  context,
                  ref,
                  task,
                  _projectIdString,
                  onDeleted: () => Navigator.pop(context),
                ),
              ),
            ],
          ),
          footer: task.isCompleted && !hasActiveSession
              ? null
              : Padding(
                  padding: EdgeInsets.all(AppConstants.spacing.large),
                  child: fu.FButton(
                    onPress: () =>
                        FocusCommands.start(context, ref, taskId: task.id!),
                    prefix: Icon(
                      hasActiveSession ? fu.FIcons.eye : fu.FIcons.play,
                      size: AppConstants.size.icon.small,
                    ),
                    child: Text(
                      hasActiveSession
                          ? 'View Active Session'
                          : 'Start Focus Session',
                    ),
                  ),
                ),
          child: SingleChildScrollView(
            padding: EdgeInsets.only(
              bottom: AppConstants.spacing.extraLarge * 2,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: AppConstants.spacing.regular,
              children: [
                TaskSummarySection(
                  task: task,
                  projectName: project?.title,
                  projectId: project?.id,
                ),
                SectionHeader(title: 'Stats'),
                TaskStatsRow(stats: stats),
                SizedBox(height: AppConstants.spacing.regular),
                TaskQuickActions(task: task, projectId: projectId),
                SizedBox(height: AppConstants.spacing.regular),
                RecentSessionsSection(sessions: recentSessions),
                SizedBox(height: AppConstants.spacing.regular),
                if (subtasks.isNotEmpty)
                  SubtasksSection(
                    subtasks: subtasks,
                    parentTask: task,
                    projectIdString: _projectIdString,
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
