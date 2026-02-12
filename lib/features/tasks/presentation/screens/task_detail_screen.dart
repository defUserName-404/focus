import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart' as fu;

import '../../../../core/common/utils/date_formatter.dart';
import '../../../../core/common/widgets/action_menu_button.dart';
import '../../../../core/config/theme/app_theme.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../focus/domain/entities/session_state.dart';
import '../../../focus/presentation/commands/focus_commands.dart';
import '../../../focus/presentation/providers/focus_session_provider.dart';
import '../../../projects/presentation/providers/project_provider.dart';
import '../../domain/entities/task.dart';
import '../commands/task_commands.dart';
import '../providers/task_detail_provider.dart';
import '../providers/task_provider.dart';
import '../widgets/recent_sessions_section.dart';
import '../widgets/task_activity_graph.dart';
import '../widgets/task_priority_badge.dart';
import '../widgets/task_quick_actions.dart';
import '../widgets/task_stats_row.dart';

/// Detailed overview screen for a single task.
///
/// Shows summary, stats, activity heatmap, quick actions,
/// recent focus sessions, and subtask list.
class TaskDetailScreen extends ConsumerWidget {
  final BigInt taskId;
  final BigInt projectId;

  const TaskDetailScreen({super.key, required this.taskId, required this.projectId});

  String get _taskIdString => taskId.toString();

  String get _projectIdString => projectId.toString();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allTasksAsync = ref.watch(tasksByProjectProvider(_projectIdString));
    final projectAsync = ref.watch(projectByIdProvider(_projectIdString));
    final statsAsync = ref.watch(taskDetailStatsProvider(_taskIdString));

    return allTasksAsync.when(
      loading: () => const fu.FScaffold(child: Center(child: fu.FCircularProgress())),
      error: (err, _) => fu.FScaffold(child: Center(child: Text('Error: $err'))),
      data: (allTasks) {
        final task = allTasks.where((t) => t.id == taskId).firstOrNull;

        if (task == null) {
          return fu.FScaffold(
            header: fu.FHeader.nested(
              title: const Text('Task'),
              prefixes: [fu.FHeaderAction.back(onPress: () => Navigator.pop(context))],
            ),
            child: const Center(child: Text('Task not found')),
          );
        }

        final subtasks = allTasks.where((t) => t.parentTaskId == taskId).toList();
        final stats = statsAsync.value ?? TaskDetailStats.empty;
        final project = projectAsync.value;
        final activeSession = ref.watch(focusTimerProvider);
        final hasActiveSession =
            activeSession != null &&
            activeSession.taskId == taskId &&
            activeSession.state != SessionState.completed &&
            activeSession.state != SessionState.cancelled;

        return fu.FScaffold(
          header: fu.FHeader.nested(
            title: Text(task.title, style: context.typography.lg, overflow: TextOverflow.ellipsis),
            prefixes: [fu.FHeaderAction.back(onPress: () => Navigator.pop(context))],
            suffixes: [
              ActionMenuButton(
                onEdit: () => TaskCommands.edit(context, task),
                onDelete: () =>
                    TaskCommands.delete(context, ref, task, _projectIdString, onDeleted: () => Navigator.pop(context)),
              ),
            ],
          ),
          footer: Padding(
            padding: EdgeInsets.all(AppConstants.spacing.large),
            child: fu.FButton(
              onPress: () => FocusCommands.start(context, ref, taskId: task.id!),
              prefix: Icon(hasActiveSession ? fu.FIcons.eye : fu.FIcons.play, size: 16),
              child: Text(hasActiveSession ? 'View Active Session' : 'Start Focus Session'),
            ),
          ),
          child: SingleChildScrollView(
            padding: EdgeInsets.all(AppConstants.spacing.large),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Summary ──
                _TaskSummary(task: task, projectName: project?.title),

                SizedBox(height: AppConstants.spacing.extraLarge),

                // ── Stats Row ──
                TaskStatsRow(stats: stats),

                SizedBox(height: AppConstants.spacing.extraLarge),

                // ── Activity Graph ──
                TaskActivityGraph(dailyFocusMinutes: stats.dailyFocusMinutes),

                SizedBox(height: AppConstants.spacing.extraLarge),

                // ── Quick Actions ──
                TaskQuickActions(task: task, projectId: projectId),

                SizedBox(height: AppConstants.spacing.extraLarge),

                // ── Recent Sessions ──
                RecentSessionsSection(sessions: stats.recentSessions),

                SizedBox(height: AppConstants.spacing.extraLarge),

                // ── Subtasks ──
                if (subtasks.isNotEmpty)
                  _SubtasksSection(subtasks: subtasks, task: task, projectIdString: _projectIdString),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ── Summary Section ─────────────────────────────────────────────────────────

class _TaskSummary extends StatelessWidget {
  final Task task;
  final String? projectName;

  const _TaskSummary({required this.task, this.projectName});

  @override
  Widget build(BuildContext context) {
    final isOverdue = task.endDate?.isOverdue ?? false;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Badges row
        Wrap(
          spacing: AppConstants.spacing.regular,
          runSpacing: AppConstants.spacing.small,
          children: [
            TaskPriorityBadge(priority: task.priority),
            if (task.isCompleted)
              fu.FBadge(
                style: fu.FBadgeStyle.primary(),
                child: Text('Completed', style: context.typography.xs),
              ),
            if (isOverdue && !task.isCompleted)
              fu.FBadge(
                style: fu.FBadgeStyle.destructive(),
                child: Text('Overdue', style: context.typography.xs),
              ),
          ],
        ),

        // Description
        if (task.description != null && task.description!.isNotEmpty) ...[
          SizedBox(height: AppConstants.spacing.large),
          Text(
            task.description!,
            style: context.typography.sm.copyWith(color: context.colors.mutedForeground, height: 1.5),
          ),
        ],

        SizedBox(height: AppConstants.spacing.large),

        // Meta info
        Wrap(
          spacing: AppConstants.spacing.large,
          runSpacing: AppConstants.spacing.small,
          children: [
            if (projectName != null) _MetaChip(icon: fu.FIcons.folder, label: projectName!, context: context),
            if (task.startDate != null)
              _MetaChip(
                icon: fu.FIcons.calendarDays,
                label: 'Start: ${task.startDate!.toDateString}',
                context: context,
              ),
            if (task.endDate != null)
              _MetaChip(
                icon: fu.FIcons.calendarClock,
                label: 'Due: ${task.endDate!.toDateString}',
                context: context,
                isDestructive: isOverdue && !task.isCompleted,
              ),
          ],
        ),

        SizedBox(height: AppConstants.spacing.large),
        const fu.FDivider(),
      ],
    );
  }
}

class _MetaChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final BuildContext context;
  final bool isDestructive;

  const _MetaChip({required this.icon, required this.label, required this.context, this.isDestructive = false});

  @override
  Widget build(BuildContext outerContext) {
    final color = isDestructive ? outerContext.colors.destructive : outerContext.colors.mutedForeground;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: color),
        SizedBox(width: AppConstants.spacing.small),
        Text(label, style: outerContext.typography.xs.copyWith(color: color)),
      ],
    );
  }
}

// ── Subtasks Section ────────────────────────────────────────────────────────

class _SubtasksSection extends ConsumerWidget {
  final List<Task> subtasks;
  final Task task;
  final String projectIdString;

  const _SubtasksSection({required this.subtasks, required this.task, required this.projectIdString});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final completed = subtasks.where((t) => t.isCompleted).length;
    final total = subtasks.length;
    final progress = total > 0 ? completed / total : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Subtasks',
              style: context.typography.sm.copyWith(fontWeight: FontWeight.w600, color: context.colors.foreground),
            ),
            SizedBox(width: AppConstants.spacing.regular),
            Text('$completed / $total', style: context.typography.xs.copyWith(color: context.colors.mutedForeground)),
            const Spacer(),
            fu.FButton(
              style: fu.FButtonStyle.outline(),
              onPress: () => TaskCommands.create(
                context,
                ref,
                projectId: task.projectId,
                parentTaskId: task.id,
                depth: task.depth + 1,
              ),
              prefix: Icon(fu.FIcons.plus, size: 12),
              child: Text('Add', style: context.typography.xs),
            ),
          ],
        ),
        SizedBox(height: AppConstants.spacing.regular),

        // Progress bar
        fu.FDeterminateProgress(value: progress),
        SizedBox(height: AppConstants.spacing.large),

        // Subtask list
        ...subtasks.map((subtask) => _SubtaskTile(subtask: subtask, projectIdString: projectIdString)),
      ],
    );
  }
}

class _SubtaskTile extends ConsumerWidget {
  final Task subtask;
  final String projectIdString;

  const _SubtaskTile({required this.subtask, required this.projectIdString});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppConstants.spacing.small),
      child: fu.FCard(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: AppConstants.spacing.regular,
            vertical: AppConstants.spacing.regular,
          ),
          child: Row(
            children: [
              fu.FCheckbox(
                value: subtask.isCompleted,
                onChange: (_) => ref.read(taskProvider(projectIdString).notifier).toggleTaskCompletion(subtask),
              ),
              SizedBox(width: AppConstants.spacing.regular),
              Expanded(
                child: Text(
                  subtask.title,
                  style: context.typography.sm.copyWith(
                    color: subtask.isCompleted ? context.colors.mutedForeground : context.colors.foreground,
                    decoration: subtask.isCompleted ? TextDecoration.lineThrough : null,
                  ),
                ),
              ),
              TaskPriorityBadge(priority: subtask.priority),
            ],
          ),
        ),
      ),
    );
  }
}
