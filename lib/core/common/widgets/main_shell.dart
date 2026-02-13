import 'package:flutter/material.dart';
import 'package:forui/forui.dart' as fu;

import '../../../features/all_tasks/presentation/screens/all_tasks_screen.dart';
import '../../../features/home/presentation/pages/home_screen.dart';
import '../../../features/projects/presentation/screens/project_detail_screen.dart';
import '../../../features/projects/presentation/screens/project_list_screen.dart';
import '../../../features/settings/presentation/screens/settings_screen.dart';
import '../../../features/tasks/presentation/screens/task_detail_screen.dart';
import '../../constants/route_constants.dart';
import 'confirmation_dialog.dart';

/// Root shell with bottom navigation.
///
/// Hosts the four primary tabs: Home, Tasks, Projects, Settings.
/// Uses a nested [Navigator] per tab so that sub-pages (e.g. project
/// detail, task detail) render inside the shell and the bottom bar
/// stays visible.
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  final List<GlobalKey<NavigatorState>> _navigatorKeys = List.generate(
    4,
    (_) => GlobalKey<NavigatorState>(),
  );

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;

        // If the current tab's navigator can pop, pop it.
        final navState = _navigatorKeys[_currentIndex].currentState;
        if (navState != null && navState.canPop()) {
          navState.pop();
          return;
        }

        // If not on the home tab, go to home first.
        if (_currentIndex != 0) {
          setState(() => _currentIndex = 0);
          return;
        }

        // On home tab root — show exit confirmation.
        if (!context.mounted) return;
        await ConfirmationDialog.show(
          context,
          title: 'Leave Focus?',
          body: 'Are you sure you want to exit the app?',
          confirmLabel: 'Exit',
          confirmStyle: fu.FButtonStyle.destructive(),
          onConfirm: () => Navigator.of(context).maybePop(),
        );
      },
      child: fu.FScaffold(
        childPad: false,
        footer: fu.FBottomNavigationBar(
          index: _currentIndex,
          onChange: (index) => setState(() => _currentIndex = index),
          children: [
            fu.FBottomNavigationBarItem(icon: const Icon(fu.FIcons.house), label: const Text('Home')),
            fu.FBottomNavigationBarItem(icon: const Icon(fu.FIcons.squareCheck), label: const Text('Tasks')),
            fu.FBottomNavigationBarItem(icon: const Icon(fu.FIcons.folderOpen), label: const Text('Projects')),
            fu.FBottomNavigationBarItem(icon: const Icon(fu.FIcons.settings), label: const Text('Settings')),
          ],
        ),
        child: IndexedStack(
          index: _currentIndex,
          children: [
            _TabNavigator(navigatorKey: _navigatorKeys[0], rootBuilder: (_) => const HomeScreen()),
            _TabNavigator(navigatorKey: _navigatorKeys[1], rootBuilder: (_) => const AllTasksScreen()),
            _TabNavigator(navigatorKey: _navigatorKeys[2], rootBuilder: (_) => const ProjectListScreen()),
            _TabNavigator(navigatorKey: _navigatorKeys[3], rootBuilder: (_) => const SettingsScreen()),
          ],
        ),
      ),
    );
  }
}

/// A per-tab nested navigator that handles sub-routes (detail screens)
/// while keeping the bottom navigation bar visible.
class _TabNavigator extends StatelessWidget {
  final GlobalKey<NavigatorState> navigatorKey;
  final WidgetBuilder rootBuilder;

  const _TabNavigator({required this.navigatorKey, required this.rootBuilder});

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: navigatorKey,
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case RouteConstants.projectDetailRoute:
            final projectId = settings.arguments as BigInt;
            return MaterialPageRoute(builder: (_) => ProjectDetailScreen(projectId: projectId));
          case RouteConstants.taskDetailRoute:
            final args = settings.arguments as Map<String, dynamic>;
            final taskId = args['taskId'] as BigInt;
            final projectId = args['projectId'] as BigInt;
            return MaterialPageRoute(builder: (_) => TaskDetailScreen(taskId: taskId, projectId: projectId));
          case RouteConstants.projectListRoute:
            return MaterialPageRoute(builder: (_) => const ProjectListScreen());
          default:
            // Root screen for this tab.
            return MaterialPageRoute(builder: rootBuilder);
        }
      },
    );
  }
}
