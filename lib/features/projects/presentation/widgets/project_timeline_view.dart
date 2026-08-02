import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart' as fu;

import '../../../../core/config/theme/app_theme.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/date_time_utils.dart';
import '../../../milestones/domain/entities/milestone.dart';
import '../../../tasks/domain/entities/task.dart';
import '../providers/project_milestones_provider.dart';

/// Read-only horizontal timeline of tasks with start+end dates and milestone diamonds.
class ProjectTimelineView extends ConsumerWidget {
  final int projectId;
  final List<Task> tasks;

  const ProjectTimelineView({super.key, required this.projectId, required this.tasks});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final milestonesAsync = ref.watch(projectMilestonesProvider(projectId));
    final milestones = milestonesAsync.value ?? const <Milestone>[];

    final datedTasks = tasks.where((t) => t.parentTaskId == null && t.startDate != null && t.endDate != null).toList()
      ..sort((a, b) => a.startDate!.compareTo(b.startDate!));

    final deadlineOnly = tasks
        .where((t) => t.parentTaskId == null && t.startDate == null && t.endDate != null)
        .toList();

    if (datedTasks.isEmpty && deadlineOnly.isEmpty && milestones.isEmpty) {
      return Center(
        child: Text(
          'No dated tasks or milestones',
          style: context.typography.sm.copyWith(color: context.colors.mutedForeground),
        ),
      );
    }

    final dates = <DateTime>[
      for (final t in datedTasks) ...[DateTimeUtils.dateOnly(t.startDate!), DateTimeUtils.dateOnly(t.endDate!)],
      for (final t in deadlineOnly) DateTimeUtils.dateOnly(t.endDate!),
      for (final m in milestones)
        if (m.targetDate != null) DateTimeUtils.dateOnly(m.targetDate!),
    ]..sort();

    final today = DateTimeUtils.dateOnly(DateTimeUtils.now());
    final rangeStart = dates.isEmpty ? today : dates.first;
    final rangeEnd = dates.isEmpty ? today : dates.last;
    final spanDays = math.max(1, rangeEnd.difference(rangeStart).inDays);

    return ListView(
      padding: EdgeInsets.symmetric(vertical: AppConstants.spacing.small),
      children: [
        SizedBox(
          height: 48,
          child: CustomPaint(
            painter: _TimelineAxisPainter(
              rangeStart: rangeStart,
              spanDays: spanDays,
              milestones: milestones,
              axisColor: context.colors.border,
              milestoneColor: context.colors.primary,
              labelStyle: context.typography.xs.copyWith(color: context.colors.mutedForeground),
            ),
            child: const SizedBox.expand(),
          ),
        ),
        SizedBox(height: AppConstants.spacing.regular),
        for (final task in datedTasks)
          Padding(
            padding: EdgeInsets.only(bottom: AppConstants.spacing.small),
            child: _TimelineTaskRow(
              title: task.title,
              start: DateTimeUtils.dateOnly(task.startDate!),
              end: DateTimeUtils.dateOnly(task.endDate!),
              rangeStart: rangeStart,
              spanDays: spanDays,
              barColor: context.colors.primary.withValues(alpha: task.isCompleted ? 0.35 : 0.75),
            ),
          ),
        for (final task in deadlineOnly)
          Padding(
            padding: EdgeInsets.only(bottom: AppConstants.spacing.small),
            child: _TimelineDeadlineRow(
              title: task.title,
              deadline: DateTimeUtils.dateOnly(task.endDate!),
              rangeStart: rangeStart,
              spanDays: spanDays,
              color: context.colors.secondary,
            ),
          ),
      ],
    );
  }
}

class _TimelineTaskRow extends StatelessWidget {
  final String title;
  final DateTime start;
  final DateTime end;
  final DateTime rangeStart;
  final int spanDays;
  final Color barColor;

  const _TimelineTaskRow({
    required this.title,
    required this.start,
    required this.end,
    required this.rangeStart,
    required this.spanDays,
    required this.barColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: context.typography.xs.copyWith(fontWeight: FontWeight.w600)),
        SizedBox(height: AppConstants.spacing.extraSmall),
        SizedBox(
          height: 18,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              final left = (start.difference(rangeStart).inDays / spanDays) * width;
              final right = (end.difference(rangeStart).inDays / spanDays) * width;
              final barWidth = math.max(8.0, right - left);
              return Stack(
                children: [
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: context.colors.muted.withValues(alpha: 0.25),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                  Positioned(
                    left: left.clamp(0, width - 8),
                    width: barWidth.clamp(8, width),
                    top: 2,
                    bottom: 2,
                    child: DecoratedBox(
                      decoration: BoxDecoration(color: barColor, borderRadius: BorderRadius.circular(4)),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}

class _TimelineDeadlineRow extends StatelessWidget {
  final String title;
  final DateTime deadline;
  final DateTime rangeStart;
  final int spanDays;
  final Color color;

  const _TimelineDeadlineRow({
    required this.title,
    required this.deadline,
    required this.rangeStart,
    required this.spanDays,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: context.typography.xs.copyWith(fontWeight: FontWeight.w600)),
        SizedBox(height: AppConstants.spacing.extraSmall),
        SizedBox(
          height: 18,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              final left = (deadline.difference(rangeStart).inDays / spanDays) * width;
              return Stack(
                children: [
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: context.colors.muted.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                  Positioned(
                    left: left.clamp(0, width - 10),
                    top: 3,
                    child: Icon(fu.FLucideIcons.flag, size: 12, color: color),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}

class _TimelineAxisPainter extends CustomPainter {
  final DateTime rangeStart;
  final int spanDays;
  final List<Milestone> milestones;
  final Color axisColor;
  final Color milestoneColor;
  final TextStyle labelStyle;

  _TimelineAxisPainter({
    required this.rangeStart,
    required this.spanDays,
    required this.milestones,
    required this.axisColor,
    required this.milestoneColor,
    required this.labelStyle,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = axisColor
      ..strokeWidth = 1;
    final y = size.height * 0.55;
    canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);

    final startLabel = TextPainter(
      text: TextSpan(text: '${rangeStart.month}/${rangeStart.day}', style: labelStyle),
      textDirection: TextDirection.ltr,
    )..layout();
    startLabel.paint(canvas, Offset(0, y + 6));

    final end = rangeStart.add(Duration(days: spanDays));
    final endLabel = TextPainter(
      text: TextSpan(text: '${end.month}/${end.day}', style: labelStyle),
      textDirection: TextDirection.ltr,
    )..layout();
    endLabel.paint(canvas, Offset(size.width - endLabel.width, y + 6));

    for (final milestone in milestones) {
      final target = milestone.targetDate;
      if (target == null) continue;
      final x = (DateTimeUtils.dateOnly(target).difference(rangeStart).inDays / spanDays) * size.width;
      final path = Path()
        ..moveTo(x, y - 8)
        ..lineTo(x + 6, y)
        ..lineTo(x, y + 8)
        ..lineTo(x - 6, y)
        ..close();
      canvas.drawPath(path, Paint()..color = milestoneColor);
    }
  }

  @override
  bool shouldRepaint(covariant _TimelineAxisPainter oldDelegate) {
    return oldDelegate.rangeStart != rangeStart ||
        oldDelegate.spanDays != spanDays ||
        oldDelegate.milestones != milestones;
  }
}
