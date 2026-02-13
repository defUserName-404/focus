import 'package:flutter/material.dart';

import '../../features/focus/presentation/screens/focus_session_screen.dart';
import '../../features/projects/presentation/screens/project_detail_screen.dart';
import '../../features/projects/presentation/screens/project_list_screen.dart';
import '../../features/tasks/presentation/screens/task_detail_screen.dart';
import '../constants/route_constants.dart';

/// Centralised route generation shared between the root [MaterialApp]
/// navigator and nested tab navigators inside [MainShell].
///
/// Screens that should render **inside** the bottom-nav shell (project
/// detail, task detail, project list) are in [generateTabRoute].
///
/// Screens that should render **above** the shell (focus session) are
/// in [generateRootRoute].
abstract final class AppRouter {
  /// Routes handled by the nested tab navigators (bottom nav stays visible).
  static Route<dynamic>? generateTabRoute(RouteSettings settings) {
    switch (settings.name) {
      case RouteConstants.projectDetailRoute:
        final projectId = settings.arguments as BigInt;
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => ProjectDetailScreen(projectId: projectId),
        );
      case RouteConstants.taskDetailRoute:
        final args = settings.arguments as Map<String, dynamic>;
        final taskId = args['taskId'] as BigInt;
        final projectId = args['projectId'] as BigInt;
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => TaskDetailScreen(taskId: taskId, projectId: projectId),
        );
      case RouteConstants.projectListRoute:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const ProjectListScreen(),
        );
      default:
        return null;
    }
  }

  /// Routes that must render full-screen **above** the bottom nav shell.
  static Route<dynamic>? generateFullScreenRoute(RouteSettings settings) {
    switch (settings.name) {
      case RouteConstants.focusSessionRoute:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const FocusSessionScreen(),
        );
      default:
        return null;
    }
  }
}
