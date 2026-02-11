import 'package:flutter/material.dart';
import 'package:focus/core/config/theme/app_theme.dart';
import 'package:focus/features/projects/domain/entities/project.dart';
import 'package:forui/forui.dart' as fu;
import 'package:intl/intl.dart';

class ProjectMetaSection extends StatefulWidget {
  final Project project;

  const ProjectMetaSection({super.key, required this.project});

  @override
  State<ProjectMetaSection> createState() => _ProjectMetaSectionState();
}

class _ProjectMetaSectionState extends State<ProjectMetaSection> {
  bool _expanded = false;

  String _fmt(DateTime dt) => DateFormat('MMM d, yyyy').format(dt);

  @override
  Widget build(BuildContext context) {
    final project = widget.project;
    final hasAnyMeta = project.startDate != null || project.deadline != null;

    if (!hasAnyMeta) return const SizedBox.shrink();

    final now = DateTime.now();
    final bool isOverdue = project.deadline != null && project.deadline!.isBefore(now);
    final int? overdueDays = project.deadline != null ? now.difference(project.deadline!).inDays : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () => setState(() => _expanded = !_expanded),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: Icon(
                  _expanded
                      ? Icons.keyboard_arrow_down_rounded
                      : Icons.keyboard_arrow_right_rounded,
                  size: 16,
                  color: context.colors.mutedForeground,
                ),
              ),
              const SizedBox(width: 4),
              Text('Project details', style: context.typography.xs.copyWith(color: context.colors.mutedForeground)),
              if (isOverdue && !_expanded) ...[
                const SizedBox(width: 8),
                Padding(
                  padding: const EdgeInsets.only(bottom: 2),
                  child: Icon(fu.FIcons.triangleAlert, color: context.colors.destructive, size: 12),
                ),
                const SizedBox(width: 4),
                Text(
                  'Overdue',
                  style: context.typography.xs.copyWith(color: context.colors.destructive, fontWeight: FontWeight.w600),
                ),
              ],
            ],
          ),
        ),
        if (_expanded) ...[
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (project.startDate != null)
                fu.FBadge(
                  style: fu.FBadgeStyle.outline(),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 2),
                        child: Icon(
                          fu.FIcons.calendarClock,
                          size: 12,
                          color: context.colors.mutedForeground,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text('Started: ${_fmt(project.startDate!)}'),
                    ],
                  ),
                ),
              if (project.deadline != null)
                fu.FBadge(
                  style: isOverdue ? fu.FBadgeStyle.destructive() : fu.FBadgeStyle.secondary(),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 2),
                        child: Icon(
                          isOverdue
                              ? fu.FIcons.triangleAlert
                              : fu.FIcons.calendarCheck,
                          size: 12,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        isOverdue
                            ? 'Overdue ${overdueDays}d (${_fmt(project.deadline!)})'
                            : 'Deadline: ${_fmt(project.deadline!)}',
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
        ],
      ],
    );
  }
}
