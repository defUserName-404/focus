import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

import '../features/focus/presentation/screens/focus_session_screen.dart';
import '../features/home/presentation/pages/home_screen.dart';
import '../features/projects/presentation/screens/project_detail_screen.dart';
import '../features/projects/presentation/screens/project_list_screen.dart';
import '../features/tasks/presentation/screens/task_detail_screen.dart';
import 'config/theme/app_theme.dart';
import 'constants/route_constants.dart';

class FocusApp extends StatelessWidget {
  const FocusApp({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.builder.build();

    return MaterialApp(
      title: 'Focus',
      supportedLocales: FLocalizations.supportedLocales,
      localizationsDelegates: const [...FLocalizations.localizationsDelegates],
      debugShowCheckedModeBanner: false,
      theme: theme.toApproximateMaterialTheme(),
      builder: (_, child) => FAnimatedTheme(data: theme, child: child!),
      initialRoute: RouteConstants.homeRoute,
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case RouteConstants.homeRoute:
            return MaterialPageRoute(builder: (_) => HomeScreen());
          case RouteConstants.projectListRoute:
            return MaterialPageRoute(builder: (_) => const ProjectListScreen());
          case RouteConstants.projectDetailRoute:
            final projectId = settings.arguments as BigInt;
            return MaterialPageRoute(builder: (_) => ProjectDetailScreen(projectId: projectId));
          case RouteConstants.focusSessionRoute:
            return MaterialPageRoute(builder: (_) => const FocusSessionScreen());
          case RouteConstants.taskDetailRoute:
            final args = settings.arguments as Map<String, dynamic>;
            final taskId = args['taskId'] as BigInt;
            final projectId = args['projectId'] as BigInt;
            return MaterialPageRoute(
              builder: (_) => TaskDetailScreen(taskId: taskId, projectId: projectId),
            );
          default:
            return MaterialPageRoute(builder: (_) => const Text('Error: Unknown route'));
        }
      },
    );
  }
}
