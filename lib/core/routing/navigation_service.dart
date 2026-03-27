import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/projects/domain/entities/project.dart';
import '../../features/tasks/domain/entities/task.dart';
import 'app_router.dart';
import 'routes.dart';

/// Centralized navigation service using go_router.
///
/// All screen-to-screen navigation flows through this class.
/// Widgets and commands call these methods instead of using
/// `context.go()` or `context.push()` directly.
///
/// Benefits:
///  - Single place to change navigation behaviour.
///  - Consistent navigation patterns across the app.
///  - Keeps widgets free of routing logic.
class NavigationService {
  //  Project routes

  void goToProjectDetail(BuildContext context, int projectId) {
    context.push(AppRoutes.projectDetailPath(projectId));
  }

  void goToProjectList(BuildContext context) {
    context.go(AppRoutes.projects);
  }

  void goToCreateProject(BuildContext context) {
    context.push(AppRoutes.createProject);
  }

  void goToEditProject(BuildContext context, Project project) {
    context.push(AppRoutes.editProjectPath(project.id!), extra: project);
  }

  // Task routes

  void goToTaskDetail(BuildContext context, {required int taskId, required int projectId}) {
    context.push(AppRoutes.taskDetailPath(taskId), extra: {'projectId': projectId});
  }

  void goToCreateTask(BuildContext context, {required int projectId, int? parentTaskId, int depth = 0}) {
    var path = AppRoutes.createTaskPath(projectId);
    final queryParams = <String, String>{};
    if (parentTaskId != null) queryParams['parentTaskId'] = parentTaskId.toString();
    if (depth > 0) queryParams['depth'] = depth.toString();

    if (queryParams.isNotEmpty) {
      final uri = Uri.parse(path).replace(queryParameters: queryParams);
      path = uri.toString();
    }

    context.push(path);
  }

  void goToEditTask(BuildContext context, Task task) {
    context.push(AppRoutes.editTaskPath(task.id!), extra: task);
  }

  void goToCreateTaskWithProject(BuildContext context) {
    context.push(AppRoutes.createTaskWithProject);
  }

  // Focus routes

  /// Navigate to the focus session screen, preventing duplicate pushes.
  void goToFocusSession({BuildContext? context}) {
    navigateToFocusSession(context: context);
  }

  // General

  void pop(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    }
  }

  void popToRoot(BuildContext context) {
    // In go_router, we navigate to the root route instead of popping
    context.go(AppRoutes.home);
  }
}
