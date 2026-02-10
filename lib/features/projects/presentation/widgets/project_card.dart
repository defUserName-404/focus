import 'package:flutter/material.dart';
import 'package:forui/forui.dart' as fu;
import 'package:intl/intl.dart';

import '../../../../core/config/theme/app_theme.dart';
import '../../../../core/constants/layout_constants.dart';
import '../../domain/entities/project.dart';

class ProjectCard extends StatelessWidget {
  final Project project;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const ProjectCard({super.key, required this.project, this.onTap, this.onEdit, this.onDelete});

  String _fmtDate(DateTime dt) => DateFormat('MMM d, yyyy').format(dt);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: LayoutConstants.spacing.marginRegular),
      child: GestureDetector(
        onTap: onTap,
        child: fu.FCard(
          child: Padding(
            padding: EdgeInsets.all(LayoutConstants.spacing.paddingRegular),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title + action buttons
                Row(
                  children: [
                    Expanded(
                      child: Text(project.title, style: context.typography.base.copyWith(fontWeight: FontWeight.w600)),
                    ),
                    if (onEdit != null)
                      fu.FButton.icon(
                        style: fu.FButtonStyle.ghost(),
                        onPress: onEdit,
                        child: Icon(fu.FIcons.pencil, size: 16, color: context.colors.mutedForeground),
                      ),
                    if (onDelete != null)
                      fu.FButton.icon(
                        style: fu.FButtonStyle.ghost(),
                        onPress: onDelete,
                        child: Icon(fu.FIcons.trash2, size: 16, color: context.colors.destructive),
                      ),
                  ],
                ),

                // Description
                if (project.description != null && project.description!.isNotEmpty) ...[
                  SizedBox(height: LayoutConstants.spacing.paddingSmall),
                  Text(
                    project.description!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: context.typography.sm.copyWith(color: context.colors.mutedForeground),
                  ),
                ],

                SizedBox(height: LayoutConstants.spacing.paddingRegular),

                // Date badges row
                Wrap(
                  spacing: LayoutConstants.spacing.paddingSmall,
                  runSpacing: LayoutConstants.spacing.paddingSmall,
                  children: [
                    if (project.startDate != null)
                      fu.FBadge(
                        style: fu.FBadgeStyle.outline(),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(fu.FIcons.calendarClock, size: 12, color: context.colors.mutedForeground),
                            const SizedBox(width: 4),
                            Text('Start: ${_fmtDate(project.startDate!)}'),
                          ],
                        ),
                      ),
                    if (project.deadline != null)
                      fu.FBadge(
                        style: _isOverdue(project) ? fu.FBadgeStyle.destructive() : fu.FBadgeStyle.secondary(),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(fu.FIcons.calendarCheck, size: 12),
                            const SizedBox(width: 4),
                            Text(_formatDeadline(project)),
                          ],
                        ),
                      )
                    else
                      fu.FBadge(style: fu.FBadgeStyle.outline(), child: const Text('No deadline')),
                    const Spacer(),
                    fu.FButton.icon(onPress: onTap, child: Icon(fu.FIcons.arrowRight)),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatDeadline(Project p) {
    if (p.deadline == null) return 'No deadline';
    final days = p.deadline!.difference(DateTime.now()).inDays;
    if (days < 0) return 'Overdue ${days.abs()}d';
    if (days == 0) return 'Due today';
    if (days == 1) return 'Due tomorrow';
    return 'Due in ${days}d';
  }

  bool _isOverdue(Project p) {
    if (p.deadline == null) return false;
    return p.deadline!.isBefore(DateTime.now());
  }
}
