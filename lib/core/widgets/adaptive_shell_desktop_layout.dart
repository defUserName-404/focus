import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart' as fu;

import '../../../features/session/presentation/widgets/mini_player_overlay.dart';
import '../../../features/settings/presentation/providers/settings_provider.dart';
import '../config/theme/app_theme.dart';
import '../constants/app_constants.dart';
import '../utils/greeting.dart';
import 'keyboard_shortcuts.dart';

class DesktopNavDestination {
  final IconData icon;
  final String label;

  const DesktopNavDestination({required this.icon, required this.label});
}

class AdaptiveShellDesktopLayout extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
    return fu.FScaffold(
      child: AppKeyboardShortcuts(
        child: Row(
          children: [
            SizedBox(
              width: 220,
              child: fu.FSidebar(
                header: Padding(padding: EdgeInsets.all(AppConstants.spacing.regular), child: const _SidebarGreeting()),
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

class _SidebarGreeting extends ConsumerWidget {
  const _SidebarGreeting();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final name = ref.watch(userPreferencesProvider).value?.displayName;
    return Text(
      greetingFor(name: name),
      style: context.typography.xl.copyWith(fontWeight: FontWeight.w700),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }
}
