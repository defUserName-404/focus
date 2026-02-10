import 'package:flutter/material.dart';
import 'package:forui/forui.dart' as fu;

import '../../../../core/config/theme/app_theme.dart';
import '../../../../core/constants/layout_constants.dart';
import '../../domain/entities/project.dart';

class ProjectCard extends StatelessWidget {
  final Project project;
  final VoidCallback? onTap;

  const ProjectCard({super.key, required this.project, this.onTap});

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
              crossAxisAlignment: .start,
              children: [
                // Title
                Text(project.title, style: context.typography.base.copyWith(fontWeight: FontWeight.w600)),

                // Description
                if (project.description != null) ...[
                  SizedBox(height: LayoutConstants.spacing.paddingSmall),
                  Text(
                    project.description!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: context.typography.sm.copyWith(color: context.colors.mutedForeground),
                  ),
                ],

                SizedBox(height: LayoutConstants.spacing.paddingRegular),

                // Metadata row
                Row(
                  spacing: LayoutConstants.spacing.paddingSmall,
                  children: [
                    // Deadline badge
                    if (project.deadline != null)
                      fu.FBadge(
                        style: _isOverdue(project) ? fu.FBadgeStyle.destructive() : fu.FBadgeStyle.secondary(),
                        child: Text(_formatDeadline(project)),
                      )
                    else
                      fu.FBadge(style: fu.FBadgeStyle.outline(), child: const Text('No deadline')),

                    // Action buttons (if needed)
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
    if (days < 0) return 'Overdue ${days.abs()} days';
    if (days == 0) return 'Due today';
    if (days == 1) return 'Due tomorrow';
    return 'Due in $days days';
  }

  bool _isOverdue(Project p) {
    if (p.deadline == null) return false;
    return p.deadline!.isBefore(DateTime.now());
  }
}
