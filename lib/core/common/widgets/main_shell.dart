import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart' as fu;

import '../../../features/all_tasks/presentation/screens/all_tasks_screen.dart';
import '../../../features/home/presentation/pages/home_screen.dart';
import '../../../features/projects/presentation/screens/project_list_screen.dart';
import '../../../features/settings/presentation/screens/settings_screen.dart';
import '../../routing/app_router.dart';
import '../providers/navigation_provider.dart';

/// Root shell with bottom navigation.
///
/// Hosts the four primary tabs: Home, Tasks, Projects, Settings.
/// Uses a nested [Navigator] per tab so that sub-pages (e.g. project
/// detail, task detail) render inside the shell and the bottom bar
/// stays visible.
///
/// Tab index state is managed via Riverpod ([bottomNavIndexProvider]).
class MainShell extends ConsumerStatefulWidget {
  const MainShell({super.key});

  @override
  ConsumerState<MainShell> createState() => _MainShellState();
}

class _MainShellState extends ConsumerState<MainShell> {
  final List<GlobalKey<NavigatorState>> _navigatorKeys = List.generate(4, (_) => GlobalKey<NavigatorState>());

  @override
  Widget build(BuildContext context) {
    final currentIndex = ref.watch(bottomNavIndexProvider);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final navState = _navigatorKeys[currentIndex].currentState;
        if (navState != null && navState.canPop()) {
          navState.pop();
          return;
        }
        if (currentIndex != 0) {
          ref.read(bottomNavIndexProvider.notifier).goHome();
          return;
        }
      },
      child: fu.FScaffold(
        childPad: false,
        footer: fu.FBottomNavigationBar(
          index: currentIndex,
          onChange: (index) {
            if (index == currentIndex) {
              _navigatorKeys[index].currentState?.popUntil((route) => route.isFirst);
            } else {
              ref.read(bottomNavIndexProvider.notifier).setIndex(index);
            }
          },
          children: [
            fu.FBottomNavigationBarItem(icon: const Icon(fu.FIcons.house), label: const Text('Home')),
            fu.FBottomNavigationBarItem(icon: const Icon(fu.FIcons.squareCheck), label: const Text('Tasks')),
            fu.FBottomNavigationBarItem(icon: const Icon(fu.FIcons.folderOpen), label: const Text('Projects')),
            fu.FBottomNavigationBarItem(icon: const Icon(fu.FIcons.settings), label: const Text('Settings')),
          ],
        ),
        child: IndexedStack(
          index: currentIndex,
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
///
/// Delegates route generation to [AppRouter.generateTabRoute].
class _TabNavigator extends StatelessWidget {
  final GlobalKey<NavigatorState> navigatorKey;
  final WidgetBuilder rootBuilder;
  const _TabNavigator({required this.navigatorKey, required this.rootBuilder});

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: navigatorKey,
      onGenerateRoute: (settings) {
        // Try the shared tab router first.
        final route = AppRouter.generateTabRoute(settings);
        if (route != null) return route;

        // Fall back to the tab's root screen.
        return MaterialPageRoute(builder: rootBuilder);
      },
    );
  }
}
