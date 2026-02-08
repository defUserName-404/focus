import 'package:flutter/material.dart';
import 'package:forui/forui.dart' as fu;

import '../../../../core/constants/layout_constants.dart';
import '../../domain/entities/project.dart';

class ProjectCard extends StatelessWidget {
  final Project project;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const ProjectCard({super.key, required this.project, this.onTap, this.onEdit, this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: LayoutConstants.spacing.marginExtraLarge),
      child: fu.FCard(
        child: Padding(
          padding: EdgeInsets.all(LayoutConstants.spacing.paddingSmall),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(width: LayoutConstants.spacing.paddingSmall),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(project.title),
                    const SizedBox(height: 6),
                    if (project.description != null)
                      Text(project.description!, maxLines: 2, overflow: TextOverflow.ellipsis)
                    else
                      Text('No description', style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(_formatDeadline(project)),
                        ),
                        const SizedBox(width: 8),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDeadline(Project p) {
    if (p.deadline == null) return 'No deadline';
    final days = p.deadline!.difference(DateTime.now()).inDays;
    if (days < 0) return 'Overdue';
    if (days == 0) return 'Due today';
    return 'Due in $days days';
  }
}

// Feature (projects) - project card widget
