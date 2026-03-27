/// Centralized route path definitions for go_router.
///
/// Use these constants when navigating with `context.go()` or `context.push()`.
/// Paths with parameters use the `:param` syntax for go_router path matching.
abstract final class AppRoutes {
  // Shell routes (bottom nav tabs)
  static const home = '/';
  static const tasks = '/tasks';
  static const projects = '/projects';
  static const settings = '/settings';

  // Project routes
  static const projectDetail = '/projects/:projectId';
  static const createProject = '/projects/new';
  static const editProject = '/projects/:projectId/edit';

  // Task routes
  static const taskDetail = '/tasks/:taskId';
  static const createTask = '/projects/:projectId/tasks/new';
  static const createTaskWithProject = '/tasks/new-with-project';
  static const editTask = '/tasks/:taskId/edit';

  // Focus session routes
  static const focusSession = '/session';

  // Helper methods to build parameterized paths

  /// Build path for project detail: `/projects/123`
  static String projectDetailPath(int projectId) => '/projects/$projectId';

  /// Build path for edit project: `/projects/123/edit`
  static String editProjectPath(int projectId) => '/projects/$projectId/edit';

  /// Build path for task detail: `/tasks/123`
  static String taskDetailPath(int taskId) => '/tasks/$taskId';

  /// Build path for create task: `/projects/123/tasks/new`
  static String createTaskPath(int projectId) => '/projects/$projectId/tasks/new';

  /// Build path for edit task: `/tasks/123/edit`
  static String editTaskPath(int taskId) => '/tasks/$taskId/edit';
}

/// Named route constants for use with `context.goNamed()`.
///
/// Using named routes provides type safety and refactoring support.
abstract final class RouteNames {
  static const home = 'home';
  static const tasks = 'tasks';
  static const projects = 'projects';
  static const settings = 'settings';

  static const projectDetail = 'projectDetail';
  static const createProject = 'createProject';
  static const editProject = 'editProject';

  static const taskDetail = 'taskDetail';
  static const createTask = 'createTask';
  static const createTaskWithProject = 'createTaskWithProject';
  static const editTask = 'editTask';

  static const focusSession = 'focusSession';
}
