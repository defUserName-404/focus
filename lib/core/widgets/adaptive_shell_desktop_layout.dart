import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart' as fu;
import 'package:go_router/go_router.dart';

import '../../../features/session/presentation/widgets/mini_player_overlay.dart';
import '../config/theme/app_theme.dart';
import '../constants/app_constants.dart';
import '../routing/routes.dart';
import 'keyboard_shortcuts.dart';

class DesktopNavDestination {
  final IconData icon;
  final String label;

  const DesktopNavDestination({required this.icon, required this.label});
}

class AdaptiveShellDesktopLayout extends StatelessWidget {
  final int currentIndex;
  final List<DesktopNavDestination> destinations;
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
    return fu.FScaffold(
      child: AppKeyboardShortcuts(
        child: Row(
          children: [
            SizedBox(
              width: 220,
              child: fu.FSidebar(
                header: Padding(
                  padding: EdgeInsets.all(AppConstants.spacing.regular),
                  child: Text('Focus', style: context.typography.xl.copyWith(fontWeight: FontWeight.w700)),
                ),
                children: [
                  for (var i = 0; i < destinations.length; i++)
                    fu.FSidebarItem(
                      icon: Icon(destinations[i].icon),
                      label: Text(
                        destinations[i].label,
                        style: context.typography.md.copyWith(fontWeight: FontWeight.w600),
                      ),
                      selected: i == currentIndex,
                      onPress: () => onTabChanged(i),
                    ),
                  const Spacer(),
                  fu.FSidebarItem(
                    icon: Icon(fu.FLucideIcons.settings),
                    label: Text('Settings', style: context.typography.md.copyWith(fontWeight: FontWeight.w600)),
                    selected: false,
                    onPress: () => context.push(AppRoutes.settings.path),
                  ),
                ],
              ),
            ),
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
