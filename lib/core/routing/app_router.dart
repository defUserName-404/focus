import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/home/presentation/pages/home_screen.dart';
import '../../features/projects/domain/entities/project.dart';
import '../../features/projects/presentation/screens/create_project_screen.dart';
import '../../features/projects/presentation/screens/edit_project_screen.dart';
import '../../features/projects/presentation/screens/project_detail_screen.dart';
import '../../features/projects/presentation/screens/projects_screen.dart';
import '../../features/reports/presentation/screens/reports_screen.dart';
import '../../features/session/presentation/screens/focus_session_screen.dart';
import '../../features/notifications/presentation/screens/notifications_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';
import '../../features/sync/domain/entities/sync_state.dart';
import '../../features/sync/presentation/screens/sync_conflict_screen.dart';
import '../../features/tasks/domain/entities/task.dart';
import '../../features/tasks/presentation/screens/create_task_screen.dart';
import '../../features/tasks/presentation/screens/create_task_with_project_screen.dart';
import '../../features/tasks/presentation/screens/edit_task_screen.dart';
import '../../features/tasks/presentation/screens/task_detail_screen.dart';
import '../../features/tasks/presentation/screens/tasks_screen.dart';
import '../widgets/adaptive_shell.dart';
import 'routes.dart';

/// Global navigator key for the root navigator.
///
/// Used by services (notifications, deep links) to navigate without a BuildContext.
final rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');

/// Shell navigator key for the adaptive shell.
final shellNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'shell');

/// Creates and configures the app router.
///
/// This is a singleton instance used throughout the app.
final GoRouter appRouter = GoRouter(
  navigatorKey: rootNavigatorKey,
  initialLocation: AppRoutes.home.path,
  debugLogDiagnostics: true,
  routes: [
    // Shell route wraps the main navigation (bottom nav / side rail)
    ShellRoute(
      navigatorKey: shellNavigatorKey,
      builder: (context, state, child) => AdaptiveShell(child: child),
      routes: [
        // Home tab
        GoRoute(
          path: AppRoutes.home.path,
          name: AppRoutes.home.name,
          pageBuilder: (context, state) => const NoTransitionPage(child: HomeScreen()),
        ),

        // Tasks tab and sub-routes
        GoRoute(
          path: AppRoutes.tasks.path,
          name: AppRoutes.tasks.name,
          pageBuilder: (context, state) => const NoTransitionPage(child: TasksScreen()),
          routes: [
            // Create task with project selection
            GoRoute(
              path: 'new-with-project',
              name: AppRoutes.createTaskWithProject.name,
              parentNavigatorKey: rootNavigatorKey,
              builder: (context, state) => const CreateTaskWithProjectScreen(),
            ),
            // Task detail
            GoRoute(
              path: ':taskId',
              name: AppRoutes.taskDetail.name,
              builder: (context, state) {
                final taskId = int.parse(state.pathParameters['taskId']!);
                // projectId passed via queryParams or extra
                final projectId = state.uri.queryParameters['projectId'] != null
                    ? int.parse(state.uri.queryParameters['projectId']!)
                    : (state.extra as Map<String, dynamic>?)?['projectId'] as int? ?? 0;
                return TaskDetailScreen(taskId: taskId, projectId: projectId);
              },
              routes: [
                // Edit task
                GoRoute(
                  path: 'edit',
                  name: AppRoutes.editTask.name,
                  parentNavigatorKey: rootNavigatorKey,
                  builder: (context, state) {
                    final task = state.extra as Task;
                    return EditTaskScreen(task: task);
                  },
                ),
              ],
            ),
          ],
        ),

        // Projects tab and sub-routes
        GoRoute(
          path: AppRoutes.projects.path,
          name: AppRoutes.projects.name,
          pageBuilder: (context, state) => const NoTransitionPage(child: ProjectsScreen()),
          routes: [
            // Create project
            GoRoute(
              path: 'new',
              name: AppRoutes.createProject.name,
              parentNavigatorKey: rootNavigatorKey,
              builder: (context, state) => const CreateProjectScreen(),
            ),
            // Project detail
            GoRoute(
              path: ':projectId',
              name: AppRoutes.projectDetail.name,
              builder: (context, state) {
                final projectId = int.parse(state.pathParameters['projectId']!);
                return ProjectDetailScreen(projectId: projectId);
              },
              routes: [
                // Edit project
                GoRoute(
                  path: 'edit',
                  name: AppRoutes.editProject.name,
                  parentNavigatorKey: rootNavigatorKey,
                  builder: (context, state) {
                    final project = state.extra as Project;
                    return EditProjectScreen(project: project);
                  },
                ),
                // Create task within project
                GoRoute(
                  path: 'tasks/new',
                  name: AppRoutes.createTask.name,
                  parentNavigatorKey: rootNavigatorKey,
                  builder: (context, state) {
                    final projectId = int.parse(state.pathParameters['projectId']!);
                    final parentTaskId = state.uri.queryParameters['parentTaskId'] != null
                        ? int.parse(state.uri.queryParameters['parentTaskId']!)
                        : null;
                    final depth = state.uri.queryParameters['depth'] != null
                        ? int.parse(state.uri.queryParameters['depth']!)
                        : 0;
                    return CreateTaskScreen(projectId: projectId, parentTaskId: parentTaskId, depth: depth);
                  },
                ),
              ],
            ),
          ],
        ),

        // Reports tab
        GoRoute(
          path: AppRoutes.reports.path,
          name: AppRoutes.reports.name,
          pageBuilder: (context, state) => const NoTransitionPage(child: ReportsScreen()),
        ),

        // Notifications tab
        GoRoute(
          path: AppRoutes.notifications.path,
          name: AppRoutes.notifications.name,
          pageBuilder: (context, state) => const NoTransitionPage(child: NotificationsScreen()),
        ),

        // Settings tab
        GoRoute(
          path: AppRoutes.settings.path,
          name: AppRoutes.settings.name,
          pageBuilder: (context, state) => const NoTransitionPage(child: SettingsScreen()),
        ),
      ],
    ),

    // Focus session (full-screen, above shell)
    GoRoute(
      path: AppRoutes.focusSession.path,
      name: AppRoutes.focusSession.name,
      parentNavigatorKey: rootNavigatorKey,
      pageBuilder: (context, state) => CustomTransitionPage(
        child: const FocusSessionScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    ),

    // Sync conflict resolution (full-screen, above shell)
    GoRoute(
      path: AppRoutes.syncConflicts.path,
      name: AppRoutes.syncConflicts.name,
      parentNavigatorKey: rootNavigatorKey,
      builder: (context, state) {
        final conflicts = state.extra as List<SyncConflict>;
        return SyncConflictScreen(conflicts: conflicts);
      },
    ),
  ],
  errorBuilder: (context, state) => _ErrorScreen(error: state.error),
);

/// Navigate to the focus session screen, preventing duplicate pushes.
///
/// Can be called from anywhere using the global [rootNavigatorKey].
void navigateToFocusSession({BuildContext? context}) {
  // Use the router from context if available
  if (context != null) {
    final currentLocation = GoRouterState.of(context).uri.path;
    if (currentLocation != AppRoutes.focusSession.path) {
      context.push(AppRoutes.focusSession.path);
    }
    return;
  }

  // Fallback to using appRouter directly
  final currentLocation = appRouter.routerDelegate.currentConfiguration.uri.path;
  if (currentLocation != AppRoutes.focusSession.path) {
    appRouter.push(AppRoutes.focusSession.path);
  }
}

/// Error screen shown when navigation fails.
class _ErrorScreen extends StatelessWidget {
  final Exception? error;

  const _ErrorScreen({this.error});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Error')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              const Text('Navigation Error', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(
                error?.toString() ?? 'Unknown error',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 24),
              ElevatedButton(onPressed: () => context.go(AppRoutes.home.path), child: const Text('Go Home')),
            ],
          ),
        ),
      ),
    );
  }
}
