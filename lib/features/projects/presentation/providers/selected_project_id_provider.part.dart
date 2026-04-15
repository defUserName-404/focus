part of '../screens/projects_screen.dart';

@Riverpod(keepAlive: true)
class SelectedProjectId extends _$SelectedProjectId {
  @override
  int? build() => null;

  void select(int? projectId) => state = projectId;

  void clear() => state = null;
}
