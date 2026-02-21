import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../features/projects/domain/entities/project.dart';
import '../../features/tasks/domain/entities/task.dart';
import '../di/injection.dart';
import '../constants/route_constants.dart';
import 'navigator_key.dart';

part 'navigation_service.g.dart';

/// Centralized navigation service.
///
/// All screen-to-screen navigation flows through this class.
/// Widgets and commands call these methods instead of using
/// `Navigator.of(context).pushNamed(...)` directly.
///
/// Benefits:
///  - Single place to change navigation behaviour.
///  - Easy to swap imperative Navigator 1.0 for GoRouter later.
///  - Keeps widgets free of routing logic.
class NavigationService {
  //  Project routes

  void goToProjectDetail(BuildContext context, int projectId) {
    Navigator.of(context).pushNamed(RouteConstants.projectDetailRoute, arguments: projectId);
  }

  void goToProjectList(BuildContext context) {
    Navigator.of(context).pushNamed(RouteConstants.projectListRoute);
  }

  void goToCreateProject(BuildContext context) {
    Navigator.of(context, rootNavigator: true).pushNamed(RouteConstants.createProjectRoute);
  }

  void goToEditProject(BuildContext context, Project project) {
    Navigator.of(context, rootNavigator: true).pushNamed(RouteConstants.editProjectRoute, arguments: project);
  }

  // Task routes

  void goToTaskDetail(BuildContext context, {required int taskId, required int projectId}) {
    Navigator.of(
      context,
    ).pushNamed(RouteConstants.taskDetailRoute, arguments: {'taskId': taskId, 'projectId': projectId});
  }

  void goToCreateTask(BuildContext context, {required int projectId, int? parentTaskId, int depth = 0}) {
    Navigator.of(context, rootNavigator: true).pushNamed(
      RouteConstants.createTaskRoute,
      arguments: {'projectId': projectId, 'parentTaskId': parentTaskId, 'depth': depth},
    );
  }

  void goToEditTask(BuildContext context, Task task) {
    Navigator.of(context, rootNavigator: true).pushNamed(RouteConstants.editTaskRoute, arguments: task);
  }

  void goToCreateTaskWithProject(BuildContext context) {
    Navigator.of(context, rootNavigator: true).pushNamed(RouteConstants.createTaskWithProjectRoute);
  }

  // Focus routes

  /// Navigate to the focus session screen, preventing duplicate pushes.
  void goToFocusSession({BuildContext? context}) {
    navigateToFocusSession(context: context);
  }

  // General

  void pop(BuildContext context) {
    Navigator.of(context).pop();
  }

  void popToRoot(BuildContext context) {
    Navigator.of(context).popUntil((route) => route.isFirst);
  }
}

/// Riverpod provider for the navigation service.
///
/// Prefer injecting this via `ref.read(navigationServiceProvider)` in
/// commands and providers rather than calling `Navigator.of` directly.
@Riverpod(keepAlive: true)
NavigationService navigationService(Ref ref) => getIt<NavigationService>();
