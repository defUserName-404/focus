import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart' as fu;

import '../../../features/focus/presentation/widgets/mini_player_overlay.dart';
import '../../../features/home/presentation/pages/home_screen.dart';
import '../../../features/projects/presentation/screens/project_list_screen.dart';
import '../../../features/settings/presentation/screens/settings_screen.dart';
import '../../../features/tasks/presentation/screens/all_tasks_screen.dart';
import '../../routing/app_router.dart';
import '../providers/navigation_provider.dart';
import '../utils/platform_utils.dart';

/// Root shell that adapts its navigation chrome to the current form factor.
///
/// - **compact** (mobile): bottom navigation bar + per-tab nested navigators.
/// - **expanded** (desktop/tablet): persistent side navigation rail + content area.
///
/// Tab index state is managed via Riverpod ([bottomNavIndexProvider]).
class AdaptiveShell extends ConsumerStatefulWidget {
  const AdaptiveShell({super.key});

  @override
  ConsumerState<AdaptiveShell> createState() => _AdaptiveShellState();
}

class _AdaptiveShellState extends ConsumerState<AdaptiveShell> {
  final List<GlobalKey<NavigatorState>> _navigatorKeys = List.generate(4, (_) => GlobalKey<NavigatorState>());

  static const _tabs = [
    _TabDefinition(icon: fu.FIcons.house, label: 'Home'),
    _TabDefinition(icon: fu.FIcons.squareCheck, label: 'Tasks'),
    _TabDefinition(icon: fu.FIcons.folderOpen, label: 'Projects'),
    _TabDefinition(icon: fu.FIcons.settings, label: 'Settings'),
  ];

  Widget _buildTabContent(int index) {
    return switch (index) {
      0 => const HomeScreen(),
      1 => const AllTasksScreen(),
      2 => const ProjectListScreen(),
      3 => const SettingsScreen(),
      _ => const HomeScreen(),
    };
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = ref.watch(bottomNavIndexProvider);
    final isExpanded = context.isExpanded;

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
      child: isExpanded
          ? _DesktopLayout(
              currentIndex: currentIndex,
              navigatorKeys: _navigatorKeys,
              tabs: _tabs,
              onTabChanged: _onTabChanged,
              buildTabContent: _buildTabContent,
            )
          : _MobileLayout(
              currentIndex: currentIndex,
              navigatorKeys: _navigatorKeys,
              tabs: _tabs,
              onTabChanged: _onTabChanged,
              buildTabContent: _buildTabContent,
            ),
    );
  }

  void _onTabChanged(int index) {
    final currentIndex = ref.read(bottomNavIndexProvider);
    if (index == currentIndex) {
      _navigatorKeys[index].currentState?.popUntil((route) => route.isFirst);
    } else {
      ref.read(bottomNavIndexProvider.notifier).setIndex(index);
    }
  }
}

// Desktop layout (side rail + content)

class _DesktopLayout extends StatelessWidget {
  final int currentIndex;
  final List<GlobalKey<NavigatorState>> navigatorKeys;
  final List<_TabDefinition> tabs;
  final ValueChanged<int> onTabChanged;
  final Widget Function(int index) buildTabContent;

  const _DesktopLayout({
    required this.currentIndex,
    required this.navigatorKeys,
    required this.tabs,
    required this.onTabChanged,
    required this.buildTabContent,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Navigation rail
          NavigationRail(
            selectedIndex: currentIndex,
            onDestinationSelected: onTabChanged,
            labelType: NavigationRailLabelType.all,
            backgroundColor: Theme.of(context).colorScheme.surface,
            leading: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(
                'Focus',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
            ),
            destinations: [
              for (final tab in tabs) NavigationRailDestination(icon: Icon(tab.icon), label: Text(tab.label)),
            ],
          ),
          const VerticalDivider(thickness: 1, width: 1),
          // Content area
          Expanded(
            child: Column(
              children: [
                // Mini-player bar at the top on desktop
                const MiniPlayerOverlay(),
                Expanded(
                  child: IndexedStack(
                    index: currentIndex,
                    children: [
                      for (var i = 0; i < tabs.length; i++)
                        _TabNavigator(navigatorKey: navigatorKeys[i], rootBuilder: (_) => buildTabContent(i)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

//  Mobile layout (bottom nav + content)

class _MobileLayout extends StatelessWidget {
  final int currentIndex;
  final List<GlobalKey<NavigatorState>> navigatorKeys;
  final List<_TabDefinition> tabs;
  final ValueChanged<int> onTabChanged;
  final Widget Function(int index) buildTabContent;

  const _MobileLayout({
    required this.currentIndex,
    required this.navigatorKeys,
    required this.tabs,
    required this.onTabChanged,
    required this.buildTabContent,
  });

  @override
  Widget build(BuildContext context) {
    return fu.FScaffold(
      childPad: false,
      footer: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const MiniPlayerOverlay(),
          fu.FBottomNavigationBar(
            index: currentIndex,
            onChange: onTabChanged,
            children: [
              for (final tab in tabs) fu.FBottomNavigationBarItem(icon: Icon(tab.icon), label: Text(tab.label)),
            ],
          ),
        ],
      ),
      child: IndexedStack(
        index: currentIndex,
        children: [
          for (var i = 0; i < tabs.length; i++)
            _TabNavigator(navigatorKey: navigatorKeys[i], rootBuilder: (_) => buildTabContent(i)),
        ],
      ),
    );
  }
}

//  Tab navigator (shared between layouts)

class _TabNavigator extends StatelessWidget {
  final GlobalKey<NavigatorState> navigatorKey;
  final WidgetBuilder rootBuilder;

  const _TabNavigator({required this.navigatorKey, required this.rootBuilder});

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: navigatorKey,
      onGenerateRoute: (settings) {
        final route = AppRouter.generateTabRoute(settings);
        if (route != null) return route;
        return MaterialPageRoute(builder: rootBuilder);
      },
    );
  }
}

//  Tab metadata

class _TabDefinition {
  final IconData icon;
  final String label;

  const _TabDefinition({required this.icon, required this.label});
}
