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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: AppConstants.spacing.regular,
      children: [
        if (project.description != null && project.description!.isNotEmpty)
          Text(
            project.description!,
            style: context.typography.sm.copyWith(color: context.colors.mutedForeground, height: 1.5),
          ),
        ProjectProgressBar(projectId: project.id!.toString()),
        ProjectMetaSection(project: project),
        fu.FDivider(),
      ],
    );
  }
}
