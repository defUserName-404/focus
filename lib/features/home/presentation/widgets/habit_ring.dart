import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/config/theme/app_theme.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/date_time_utils.dart';
import '../../../tasks/domain/entities/habit_strip_item.dart';
import '../../../tasks/presentation/commands/task_commands.dart';

/// Circular progress ring for a single habit in the home strip.
class HabitRing extends ConsumerWidget {
  final HabitStripItem item;

  const HabitRing({super.key, required this.item});

  Future<void> _onTap() async {
    if (item.completedToday || item.task.id == null) return;
    await TaskCommands.completeHabitOccurrence(item.task, DateTimeUtils.now());
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = item.completedToday ? 1.0 : 0.0;
    final ringColor = item.completedToday
        ? context.colors.primary
        : item.dueToday
        ? context.colors.primary.withValues(alpha: 0.35)
        : context.colors.mutedForeground.withValues(alpha: 0.25);

    return GestureDetector(
      onTap: item.completedToday ? null : _onTap,
      child: SizedBox(
        width: 72,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 56,
              height: 56,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 56,
                    height: 56,
                    child: CircularProgressIndicator(
                      value: progress == 0 ? 0.08 : progress,
                      strokeWidth: 3.5,
                      backgroundColor: context.colors.mutedForeground.withValues(alpha: 0.12),
                      color: ringColor,
                    ),
                  ),
                  Text(
                    item.currentStreak > 0 ? '${item.currentStreak}' : '·',
                    style: context.typography.sm.copyWith(
                      fontWeight: FontWeight.w700,
                      color: item.completedToday ? context.colors.primary : context.colors.foreground,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: AppConstants.spacing.small),
            Text(
              item.task.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: context.typography.xs.copyWith(
                color: item.completedToday ? context.colors.mutedForeground : context.colors.foreground,
                decoration: item.completedToday ? TextDecoration.lineThrough : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
