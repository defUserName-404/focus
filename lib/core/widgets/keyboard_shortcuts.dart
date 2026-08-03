import 'package:flutter/material.dart';

import '../../core/models/keyboard_shortcut.dart';

class AppKeyboardShortcuts extends StatelessWidget {
  final Widget child;

  const AppKeyboardShortcuts({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return CallbackShortcuts(
      bindings: {
        for (final s in KeyboardShortcuts.all)
          if (s.actionBuilder != null) s.activator: () => s.actionBuilder!(context),
      },
      child: Focus(autofocus: true, child: child),
    );
  }
}
