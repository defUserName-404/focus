import 'package:meta/meta.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/entities/project.dart';

part 'projects_pane_form_provider.g.dart';

/// Desktop detail-pane create/edit form state for Projects.
@immutable
sealed class ProjectsPaneForm {
  const ProjectsPaneForm();
}

@immutable
class CreateProjectPaneForm extends ProjectsPaneForm {
  const CreateProjectPaneForm();
}

@immutable
class EditProjectPaneForm extends ProjectsPaneForm {
  final Project project;

  const EditProjectPaneForm(this.project);
}

@Riverpod(keepAlive: true)
class ProjectsPaneFormNotifier extends _$ProjectsPaneFormNotifier {
  @override
  ProjectsPaneForm? build() => null;

  void showCreate() => state = const CreateProjectPaneForm();

  void showEdit(Project project) => state = EditProjectPaneForm(project);

  void clear() => state = null;
}
