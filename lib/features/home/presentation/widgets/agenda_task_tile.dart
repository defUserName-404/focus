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

class AgendaTaskTile extends ConsumerStatefulWidget {
  final TodayAgendaItem item;

  const AgendaTaskTile({super.key, required this.item});

  @override
  ConsumerState<AgendaTaskTile> createState() => _AgendaTaskTileState();
}

class _AgendaTaskTileState extends ConsumerState<AgendaTaskTile> {
  bool _hovered = false;

  String get _subtitle {
    return switch (widget.item.kind) {
      TodayAgendaKind.overdue => widget.item.occurrenceDate.toRelativeDueString(),
      TodayAgendaKind.dueToday => 'Due today',
      TodayAgendaKind.habitOccurrence => 'Habit',
    };
  }

  Color _subtitleColor(BuildContext context) {
    if (widget.item.kind == TodayAgendaKind.overdue) return context.colors.destructive;
    return context.colors.mutedForeground;
  }

  Future<void> _onToggle() async {
    if (widget.item.isCompleted) return;
    await TaskCommands.completeAgendaItem(widget.item);
  }

  @override
  Widget build(BuildContext context) {
    final task = widget.item.task;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: AppConstants.animation.short,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppConstants.border.radius.regular),
          color: _hovered ? context.colors.muted.withValues(alpha: 0.45) : Colors.transparent,
        ),
        child: GestureDetector(
          onTap: () {
            if (task.id == null) return;
            context.push(AppRoutes.taskDetailPath(task.id!), extra: {'projectId': task.projectId});
          },
          child: fu.FCard(
            child: Padding(
              padding: EdgeInsets.all(AppConstants.spacing.large),
              child: Row(
                children: [
                  fu.FCheckbox(
                    value: widget.item.isCompleted,
                    onChange: widget.item.isCompleted ? null : (_) => _onToggle(),
                  ),
                  SizedBox(width: AppConstants.spacing.regular),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          task.title,
                          style: context.typography.sm.copyWith(
                            fontWeight: FontWeight.w500,
                            color: widget.item.isCompleted ? context.colors.mutedForeground : context.colors.foreground,
                            decoration: widget.item.isCompleted ? TextDecoration.lineThrough : null,
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
                  if (!widget.item.isCompleted && task.id != null) ...[
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
        ),
      ),
    );
  }
}
