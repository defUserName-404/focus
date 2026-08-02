import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart' as fu;
import 'package:go_router/go_router.dart';

import '../../../../core/config/theme/app_theme.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/routing/routes.dart';
import '../../../../core/utils/datetime_formatter.dart';
import '../../../session/presentation/commands/focus_commands.dart';
import '../../../tasks/domain/entities/today_agenda_item.dart';
import '../../../tasks/presentation/commands/task_commands.dart';
import '../../../tasks/presentation/widgets/task_priority_badge.dart';

class AgendaTaskTile extends ConsumerWidget {
  final TodayAgendaItem item;

  const AgendaTaskTile({super.key, required this.item});

  String get _subtitle {
    return switch (item.kind) {
      TodayAgendaKind.overdue => item.occurrenceDate.toRelativeDueString(),
      TodayAgendaKind.dueToday => 'Due today',
      TodayAgendaKind.habitOccurrence => 'Habit',
    };
  }

  Color _subtitleColor(BuildContext context) {
    if (item.kind == TodayAgendaKind.overdue) return context.colors.destructive;
    return context.colors.mutedForeground;
  }

  Future<void> _onToggle() async {
    if (item.isCompleted) return;
    await TaskCommands.completeAgendaItem(item);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final task = item.task;

    return GestureDetector(
      onTap: () {
        if (task.id == null) return;
        context.push(AppRoutes.taskDetailPath(task.id!), extra: {'projectId': task.projectId});
      },
      child: fu.FCard(
        child: Padding(
          padding: EdgeInsets.all(AppConstants.spacing.large),
          child: Row(
            children: [
              fu.FCheckbox(value: item.isCompleted, onChange: item.isCompleted ? null : (_) => _onToggle()),
              SizedBox(width: AppConstants.spacing.regular),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title,
                      style: context.typography.sm.copyWith(
                        fontWeight: FontWeight.w500,
                        color: item.isCompleted ? context.colors.mutedForeground : context.colors.foreground,
                        decoration: item.isCompleted ? TextDecoration.lineThrough : null,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: AppConstants.spacing.extraSmall),
                    Text(
                      _subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.typography.xs.copyWith(color: _subtitleColor(context)),
                    ),
                  ],
                ),
              ),
              SizedBox(width: AppConstants.spacing.small),
              TaskPriorityBadge(priority: task.priority),
              if (!item.isCompleted && task.id != null) ...[
                SizedBox(width: AppConstants.spacing.small),
                fu.FButton(
                  variant: .ghost,
                  onPress: () => FocusCommands.start(context, ref, taskId: task.id!),
                  child: Icon(fu.FLucideIcons.play, size: AppConstants.size.icon.extraSmall),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
