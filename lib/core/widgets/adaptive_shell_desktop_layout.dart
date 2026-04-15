import 'package:flutter/material.dart';

import '../../../features/session/presentation/widgets/mini_player_overlay.dart';
import '../constants/layout_breakpoints.dart';
import 'keyboard_shortcuts.dart';

class AdaptiveShellDesktopLayout extends StatelessWidget {
  final int currentIndex;
  final List<NavigationRailDestination> destinations;
  final ValueChanged<int> onTabChanged;
  final Widget child;

  const AdaptiveShellDesktopLayout({
    super.key,
    required this.currentIndex,
    required this.destinations,
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
              destinations: destinations,
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
