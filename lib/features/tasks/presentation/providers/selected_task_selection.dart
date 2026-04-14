import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../models/task_selection.dart';

part 'selected_task_selection.g.dart';

@Riverpod(keepAlive: true)
class SelectedTaskSelection extends _$SelectedTaskSelection {
  @override
  TaskSelection? build() => null;

  void select(TaskSelection? selection) => state = selection;

  void clear() => state = null;
}
