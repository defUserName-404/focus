import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/utils/platform_utils.dart';
import '../../../../core/widgets/master_detail_layout.dart';
import 'project_detail_screen.dart';
import 'project_list_screen.dart';

part 'projects_screen.g.dart';

class ProjectsScreen extends ConsumerWidget {
  const ProjectsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (context.isCompact) {
      return const ProjectListScreen();
    }

    final selectedProjectId = ref.watch(selectedProjectIdProvider);

    return MasterDetailLayout(
      masterWidth: 420,
      master: ProjectListScreen(
        selectedId: selectedProjectId,
        onProjectSelected: (id) {
          ref.read(selectedProjectIdProvider.notifier).select(id);
        },
      ),
      detail: selectedProjectId != null ? ProjectDetailScreen(projectId: selectedProjectId, isEmbedded: true) : null,
      emptyDetail: const Center(child: Text('Select a project to view details')),
    );
  }
}

@Riverpod(keepAlive: true)
class SelectedProjectId extends _$SelectedProjectId {
  @override
  int? build() => null;

  void select(int? projectId) => state = projectId;

  void clear() => state = null;
}
