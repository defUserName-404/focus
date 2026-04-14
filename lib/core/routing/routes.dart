/// Route descriptor that stores both path and go_router name.
class AppRoute {
  final String path;
  final String name;

  const AppRoute({required this.path, required this.name});
}

/// Centralized route definitions for go_router.
///
/// This is the single source of truth for both route path and route name.
abstract final class AppRoutes {
  // Shell routes (bottom nav tabs)
  static const home = AppRoute(path: '/', name: 'home');
  static const tasks = AppRoute(path: '/tasks', name: 'tasks');
  static const projects = AppRoute(path: '/projects', name: 'projects');
  static const reports = AppRoute(path: '/reports', name: 'reports');
  static const notifications = AppRoute(path: '/notifications', name: 'notifications');
  static const settings = AppRoute(path: '/settings', name: 'settings');

  // Project routes
  static const projectDetail = AppRoute(path: '/projects/:projectId', name: 'projectDetail');
  static const createProject = AppRoute(path: '/projects/new', name: 'createProject');
  static const editProject = AppRoute(path: '/projects/:projectId/edit', name: 'editProject');

  // Task routes
  static const taskDetail = AppRoute(path: '/tasks/:taskId', name: 'taskDetail');
  static const createTask = AppRoute(path: '/projects/:projectId/tasks/new', name: 'createTask');
  static const createTaskWithProject = AppRoute(path: '/tasks/new-with-project', name: 'createTaskWithProject');
  static const editTask = AppRoute(path: '/tasks/:taskId/edit', name: 'editTask');

  // Focus session routes
  static const focusSession = AppRoute(path: '/session', name: 'focusSession');

  // Sync routes
  static const syncConflicts = AppRoute(path: '/sync/conflicts', name: 'syncConflicts');

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
