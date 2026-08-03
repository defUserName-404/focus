import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/utils/platform_utils.dart';
import '../../../../core/widgets/master_detail_layout.dart';
import '../providers/projects_master_pane_width_provider.dart';
import '../providers/projects_pane_form_provider.dart';
import 'create_project_screen.dart';
import 'edit_project_screen.dart';
import 'project_detail_screen.dart';
import 'project_list_screen.dart';

part 'projects_screen.g.dart';
part '../providers/selected_project_id_provider.part.dart';

class ProjectsScreen extends ConsumerWidget {
  const ProjectsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (context.isCompact) {
      return const ProjectListScreen();
    }

    final selectedProjectId = ref.watch(selectedProjectIdProvider);
    final form = ref.watch(projectsPaneFormProvider);
    final masterWidth = ref.watch(projectsMasterPaneWidthProvider).value ?? kDefaultProjectsMasterPaneWidth;

    return MasterDetailLayout(
      masterWidth: masterWidth,
      onMasterWidthChanged: (width) => ref.read(projectsMasterPaneWidthProvider.notifier).setWidth(width),
      master: ProjectListScreen(
        selectedId: selectedProjectId,
        onProjectSelected: (id) {
          ref.read(projectsPaneFormProvider.notifier).clear();
          ref.read(selectedProjectIdProvider.notifier).select(id);
        },
      ),
      detail: _detail(ref, form, selectedProjectId),
      emptyDetail: const Center(child: Text('Select a project to view details')),
    );
  }

  Widget? _detail(WidgetRef ref, ProjectsPaneForm? form, int? selectedProjectId) {
    if (form is CreateProjectPaneForm) {
      return CreateProjectScreen(
        isEmbedded: true,
        onDismiss: () => ref.read(projectsPaneFormProvider.notifier).clear(),
        onCreated: (project) {
          ref.read(projectsPaneFormProvider.notifier).clear();
          if (project.id != null) {
            ref.read(selectedProjectIdProvider.notifier).select(project.id);
          }
        },
      );
    }
    if (form is EditProjectPaneForm) {
      return EditProjectScreen(
        project: form.project,
        isEmbedded: true,
        onDismiss: () => ref.read(projectsPaneFormProvider.notifier).clear(),
        onSaved: (project) {
          ref.read(projectsPaneFormProvider.notifier).clear();
          if (project.id != null) {
            ref.read(selectedProjectIdProvider.notifier).select(project.id);
          }
        },
      );
    }
    if (selectedProjectId != null) {
      return ProjectDetailScreen(
        projectId: selectedProjectId,
        isEmbedded: true,
        onClose: () => ref.read(selectedProjectIdProvider.notifier).clear(),
      );
    }
    return null;
  }
}
