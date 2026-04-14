import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:focus/core/widgets/confirmation_dialog.dart';
import 'package:focus/core/routing/routes.dart';
import 'package:focus/features/projects/domain/entities/project.dart';
import 'package:focus/features/projects/presentation/providers/project_provider.dart';

class ProjectCommands {
  static void create(BuildContext context) {
    context.push(AppRoutes.createProject.path);
  }

  static void edit(BuildContext context, Project project) {
    if (project.id == null) return;
    context.push(AppRoutes.editProjectPath(project.id!), extra: project);
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
