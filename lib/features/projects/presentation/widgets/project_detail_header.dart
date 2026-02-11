import 'package:flutter/material.dart';
import 'package:focus/core/config/theme/app_theme.dart';
import 'package:focus/core/constants/app_constants.dart';
import 'package:focus/features/projects/domain/entities/project.dart';
import 'package:focus/features/tasks/domain/entities/task.dart';
import 'package:forui/forui.dart' as fu;

import 'project_meta_section.dart';
import 'project_progress_bar.dart';

class ProjectDetailHeader extends StatelessWidget {
  final Project project;
  final List<Task> tasks;

  const ProjectDetailHeader({super.key, required this.project, required this.tasks});

  @override
  Widget build(BuildContext context) {
    final completed = tasks.where((t) => t.isCompleted).length;

    return Padding(
      padding: EdgeInsets.fromLTRB(AppConstants.spacing.large, 0, AppConstants.spacing.large, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Description
          if (project.description != null && project.description!.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              project.description!,
              style: context.typography.sm.copyWith(color: context.colors.mutedForeground, height: 1.5),
            ),
          ],

          SizedBox(height: AppConstants.spacing.large),

          // Progress bar
          ProjectProgressBar(completed: completed, total: tasks.length),

          SizedBox(height: AppConstants.spacing.regular),

          // Collapsible metadata chips
          ProjectMetaSection(project: project),

          // Divider
          fu.FDivider(),
          SizedBox(height: AppConstants.spacing.small),
        ],
      ),
    );
  }
}
