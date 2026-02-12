import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:focus/core/common/widgets/confirmation_dialog.dart';
import 'package:focus/features/projects/domain/entities/project.dart';
import 'package:focus/features/projects/presentation/providers/project_provider.dart';
// Removed unused import: ProjectDetailScreen
import 'package:focus/features/projects/presentation/widgets/create_project_modal_content.dart';
import 'package:focus/features/projects/presentation/widgets/edit_project_modal_content.dart';
import 'package:forui/forui.dart' as fu;

import '../../../../core/constants/route_constants.dart'; // Added import

class ProjectCommands {
  static Future<void> create(BuildContext context, WidgetRef ref) async {
    final newProject = await fu.showFSheet<Project>(
      context: context,
      side: fu.FLayout.btt,
      builder: (context) => const CreateProjectModalContent(),
    );

    if (newProject != null && newProject.id != null && context.mounted) {
      Navigator.of(context).pushNamed(RouteConstants.projectDetailRoute, arguments: newProject.id!);
    }
  }

  static Future<void> edit(BuildContext context, Project project) async {
    await fu.showFSheet(
      context: context,
      side: fu.FLayout.btt,
      builder: (context) => EditProjectModalContent(project: project),
    );
  }

  static Future<void> delete(BuildContext context, WidgetRef ref, Project project, {VoidCallback? onDeleted}) async {
    if (project.id == null) return;

    await ConfirmationDialog.show(
      context,
      title: 'Delete Project',
      body: 'Are you sure you want to delete "${project.title}"? All tasks will also be deleted.',
      onConfirm: () {
        ref.read(projectProvider.notifier).deleteProject(project.id!);
        onDeleted?.call();
      },
    );
  }
}
