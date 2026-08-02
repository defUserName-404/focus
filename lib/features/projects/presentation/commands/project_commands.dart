import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:focus/core/widgets/confirmation_dialog.dart';
import 'package:focus/core/routing/routes.dart';
import 'package:focus/core/utils/platform_utils.dart';
import 'package:focus/core/utils/result.dart';
import 'package:focus/features/projects/domain/entities/project.dart';
import 'package:focus/features/projects/presentation/providers/project_provider.dart';
import 'package:focus/features/projects/presentation/providers/project_template_provider.dart';
import 'package:focus/features/projects/presentation/providers/projects_pane_form_provider.dart';

class ProjectCommands {
  static void create(BuildContext context) {
    if (!context.isCompact) {
      ProviderScope.containerOf(context).read(projectsPaneFormProvider.notifier).showCreate();
      return;
    }
    context.push(AppRoutes.createProject.path);
  }

  static void edit(BuildContext context, Project project) {
    if (project.id == null) return;
    if (!context.isCompact) {
      ProviderScope.containerOf(context).read(projectsPaneFormProvider.notifier).showEdit(project);
      return;
    }
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

  static Future<void> saveAsTemplate(BuildContext context, WidgetRef ref, Project project) async {
    if (project.id == null) return;
    final controller = TextEditingController(text: '${project.title} Template');
    final name = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Save as template'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Template name'),
          onSubmitted: (value) => Navigator.of(context).pop(value.trim()),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.of(context).pop(controller.text.trim()), child: const Text('Save')),
        ],
      ),
    );
    if (name == null || name.isEmpty) return;
    final result = await ref
        .read(projectTemplateServiceProvider)
        .saveProjectAsTemplate(projectId: project.id!, name: name);
    if (!context.mounted) return;
    switch (result) {
      case Success(:final value):
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Saved template "${value.name}"')));
      case Failure(:final failure):
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(failure.message)));
    }
  }
}
