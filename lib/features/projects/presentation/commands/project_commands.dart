import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:focus/core/common/widgets/confirmation_dialog.dart';
import 'package:focus/features/projects/domain/entities/project.dart';
import 'package:focus/features/projects/presentation/providers/project_provider.dart';

import '../../../../core/constants/route_constants.dart';

class ProjectCommands {
  static void create(BuildContext context) {
    Navigator.of(context, rootNavigator: true).pushNamed(RouteConstants.createProjectRoute);
  }

  static void edit(BuildContext context, Project project) {
    Navigator.of(context, rootNavigator: true).pushNamed(
      RouteConstants.editProjectRoute,
      arguments: project,
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
