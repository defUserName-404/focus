import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart' as fu;
import 'package:go_router/go_router.dart';

import '../routing/routes.dart';
import '../utils/platform_utils.dart';
import 'adaptive_shell_desktop_layout.dart';
import 'adaptive_shell_mobile_layout.dart';

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

  static final _desktopTabs = [
    _TabDefinition(icon: fu.FIcons.house, label: 'Home', route: AppRoutes.home.path),
    _TabDefinition(icon: fu.FIcons.squareCheck, label: 'Tasks', route: AppRoutes.tasks.path),
    _TabDefinition(icon: fu.FIcons.folderOpen, label: 'Projects', route: AppRoutes.projects.path),
    _TabDefinition(icon: fu.FIcons.chartBar, label: 'Reports', route: AppRoutes.reports.path),
    _TabDefinition(icon: fu.FIcons.bell, label: 'Notifications', route: AppRoutes.notifications.path),
  ];

  static final _mobileTabs = [
    _TabDefinition(icon: fu.FIcons.house, label: 'Home', route: AppRoutes.home.path),
    _TabDefinition(icon: fu.FIcons.squareCheck, label: 'Tasks', route: AppRoutes.tasks.path),
    _TabDefinition(icon: fu.FIcons.folderOpen, label: 'Projects', route: AppRoutes.projects.path),
    _TabDefinition(icon: fu.FIcons.bell, label: 'Notifications', route: AppRoutes.notifications.path),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final location = GoRouterState.of(context).uri.path;
    final isExpanded = context.isExpanded;
    final tabs = isExpanded ? _desktopTabs : _mobileTabs;
    final currentIndex = _getIndexFromLocation(location, tabs);
    final desktopDestinations = [
      for (final tab in tabs) NavigationRailDestination(icon: Icon(tab.icon), label: Text(tab.label)),
    ];
    final mobileItems = [for (final tab in tabs) fu.FBottomNavigationBarItem(icon: Icon(tab.icon), label: Text(tab.label))];

    return isExpanded
        ? AdaptiveShellDesktopLayout(
            currentIndex: currentIndex,
            destinations: desktopDestinations,
            onTabChanged: (index) => _onTabChanged(context, index),
            child: child,
          )
        : AdaptiveShellMobileLayout(
            currentIndex: currentIndex,
            items: mobileItems,
            onTabChanged: (index) => _onTabChanged(context, index),
            child: child,
          );
  }

  /// Determine which tab index corresponds to the current route location.
  int _getIndexFromLocation(String location, List<_TabDefinition> tabs) {
    if (location.startsWith(AppRoutes.tasks.path)) return _indexForRoute(tabs, AppRoutes.tasks.path);
    if (location.startsWith(AppRoutes.projects.path)) return _indexForRoute(tabs, AppRoutes.projects.path);
    if (location.startsWith(AppRoutes.reports.path)) return _indexForRoute(tabs, AppRoutes.reports.path);
    if (location.startsWith(AppRoutes.notifications.path)) return _indexForRoute(tabs, AppRoutes.notifications.path);
    return _indexForRoute(tabs, AppRoutes.home.path);
  }

  int _indexForRoute(List<_TabDefinition> tabs, String route) {
    final index = tabs.indexWhere((tab) => tab.route == route);
    return index < 0 ? 0 : index;
  }

  /// Navigate to the selected tab's route.
  void _onTabChanged(BuildContext context, int index) {
    final tabs = context.isExpanded ? _desktopTabs : _mobileTabs;
    final currentIndex = _getIndexFromLocation(GoRouterState.of(context).uri.path, tabs);

    if (index == currentIndex) {
      // Already on this tab - pop to root of this tab
      // This is handled by go_router automatically when using go()
      context.go(tabs[index].route);
    } else {
      // Navigate to the new tab
      context.go(tabs[index].route);
    }
  }
}

//  Tab metadata

class _TabDefinition {
  final IconData icon;
  final String label;
  final String route;

  const _TabDefinition({required this.icon, required this.label, required this.route});
}
