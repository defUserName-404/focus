import 'package:flutter/material.dart';
import 'package:forui/forui.dart' as fu;

import '../../../features/session/presentation/widgets/mini_player_overlay.dart';

class AdaptiveShellMobileLayout extends StatelessWidget {
  final int currentIndex;
  final List<fu.FBottomNavigationBarItem> items;
  final ValueChanged<int> onTabChanged;
  final Widget child;

  const AdaptiveShellMobileLayout({
    super.key,
    required this.currentIndex,
    required this.items,
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
          fu.FBottomNavigationBar(index: currentIndex, onChange: onTabChanged, children: items),
        ],
      ),
      child: child,
    );
  }
}
