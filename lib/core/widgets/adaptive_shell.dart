import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart' as fu;
import 'package:go_router/go_router.dart';

import '../../../features/session/presentation/widgets/mini_player_overlay.dart';
import '../constants/layout_breakpoints.dart';
import '../routing/routes.dart';
import '../utils/platform_utils.dart';
import 'keyboard_shortcuts.dart';

/// Root shell that adapts its navigation chrome to the current form factor.
///
/// - **compact** (mobile): bottom navigation bar
/// - **expanded** (desktop/tablet): persistent side navigation rail
///
/// With go_router, this widget receives the current route's [child] widget
/// directly from the router configuration.
class AdaptiveShell extends ConsumerWidget {
  /// The child widget provided by go_router's ShellRoute.
  final Widget child;

  const AdaptiveShell({super.key, required this.child});

  static const _tabs = [
    _TabDefinition(icon: fu.FIcons.house, label: 'Home', route: AppRoutes.home),
    _TabDefinition(icon: fu.FIcons.squareCheck, label: 'Tasks', route: AppRoutes.tasks),
    _TabDefinition(icon: fu.FIcons.folderOpen, label: 'Projects', route: AppRoutes.projects),
    _TabDefinition(icon: fu.FIcons.settings, label: 'Settings', route: AppRoutes.settings),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final location = GoRouterState.of(context).uri.path;
    final currentIndex = _getIndexFromLocation(location);
    final isExpanded = context.isExpanded;

    return isExpanded
        ? _DesktopLayout(
            currentIndex: currentIndex,
            tabs: _tabs,
            onTabChanged: (index) => _onTabChanged(context, index),
            child: child,
          )
        : _MobileLayout(
            currentIndex: currentIndex,
            tabs: _tabs,
            onTabChanged: (index) => _onTabChanged(context, index),
            child: child,
          );
  }

  /// Determine which tab index corresponds to the current route location.
  int _getIndexFromLocation(String location) {
    if (location.startsWith('/tasks')) return 1;
    if (location.startsWith('/projects')) return 2;
    if (location.startsWith('/settings')) return 3;
    return 0; // Home
  }

  /// Navigate to the selected tab's route.
  void _onTabChanged(BuildContext context, int index) {
    final currentIndex = _getIndexFromLocation(GoRouterState.of(context).uri.path);

    if (index == currentIndex) {
      // Already on this tab - pop to root of this tab
      // This is handled by go_router automatically when using go()
      context.go(_tabs[index].route);
    } else {
      // Navigate to the new tab
      context.go(_tabs[index].route);
    }
  }
}

// Desktop layout (side rail + content)

class _DesktopLayout extends StatelessWidget {
  final int currentIndex;
  final List<_TabDefinition> tabs;
  final ValueChanged<int> onTabChanged;
  final Widget child;

  const _DesktopLayout({
    required this.currentIndex,
    required this.tabs,
    required this.onTabChanged,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final sizeClass = LayoutBreakpoints.getWindowSizeClass(context);
    final spacing = ResponsiveSpacing.small(sizeClass);

    return Scaffold(
      body: AppKeyboardShortcuts(
        child: Row(
          children: [
            NavigationRail(
              selectedIndex: currentIndex,
              onDestinationSelected: onTabChanged,
              extended: true,
              minExtendedWidth: 200,
              backgroundColor: Theme.of(context).colorScheme.surface,
              leading: Padding(
                padding: EdgeInsets.all(spacing),
                child: Text(
                  'Focus',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              destinations: [
                for (final tab in tabs) NavigationRailDestination(icon: Icon(tab.icon), label: Text(tab.label)),
              ],
            ),
            const VerticalDivider(thickness: 1, width: 1),
            Expanded(
              child: Column(
                children: [
                  const MiniPlayerOverlay(),
                  Expanded(child: child),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

//  Mobile layout (bottom nav + content)

class _MobileLayout extends StatelessWidget {
  final int currentIndex;
  final List<_TabDefinition> tabs;
  final ValueChanged<int> onTabChanged;
  final Widget child;

  const _MobileLayout({
    required this.currentIndex,
    required this.tabs,
    required this.onTabChanged,
    required this.child,
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
      child: child,
    );
  }
}

//  Tab metadata

class _TabDefinition {
  final IconData icon;
  final String label;
  final String route;

  const _TabDefinition({required this.icon, required this.label, required this.route});
}
