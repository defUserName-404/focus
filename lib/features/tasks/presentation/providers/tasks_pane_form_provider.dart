import 'package:meta/meta.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/entities/task.dart';

part 'tasks_pane_form_provider.g.dart';

/// Desktop detail-pane create/edit form state for Tasks.
@immutable
sealed class TasksPaneForm {
  const TasksPaneForm();
}

@immutable
class CreateTaskPaneForm extends TasksPaneForm {
  /// When null, show the project-picker create form.
  final int? projectId;
  final int? parentTaskId;
  final int depth;

  const CreateTaskPaneForm({this.projectId, this.parentTaskId, this.depth = 0});
}

@immutable
class EditTaskPaneForm extends TasksPaneForm {
  final Task task;

  const EditTaskPaneForm(this.task);
}

@Riverpod(keepAlive: true)
class TasksPaneFormNotifier extends _$TasksPaneFormNotifier {
  @override
  TasksPaneForm? build() => null;

  void showCreate({int? projectId, int? parentTaskId, int depth = 0}) {
    state = CreateTaskPaneForm(projectId: projectId, parentTaskId: parentTaskId, depth: depth);
  }

  void showEdit(Task task) => state = EditTaskPaneForm(task);

  void clear() => state = null;
}
