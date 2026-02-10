import 'package:flutter/material.dart';
import 'package:focus/features/projects/domain/entities/project.dart';
import 'package:focus/features/tasks/domain/entities/task.dart';

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
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Description
          if (project.description != null && project.description!.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(project.description!, style: const TextStyle(fontSize: 14, color: Color(0xFF888888), height: 1.5)),
          ],

          const SizedBox(height: 16),

          // Progress bar
          ProjectProgressBar(completed: completed, total: tasks.length),

          const SizedBox(height: 12),

          // Collapsible metadata chips
          ProjectMetaSection(project: project),

          // Divider
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Divider(color: Color(0xFF1A1A1A), height: 1),
          ),
        ],
      ),
    );
  }
}
