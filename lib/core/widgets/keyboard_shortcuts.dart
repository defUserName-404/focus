import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../routing/routes.dart';

class AppKeyboardShortcuts extends StatelessWidget {
  final Widget child;

  const AppKeyboardShortcuts({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.keyN, control: true): () {
          context.push(AppRoutes.createTaskWithProject);
        },
        const SingleActivator(LogicalKeyboardKey.keyP, control: true): () {
          context.push(AppRoutes.createProject);
        },
        const SingleActivator(LogicalKeyboardKey.space): () {
          context.push(AppRoutes.focusSession);
        },
        const SingleActivator(LogicalKeyboardKey.escape): () {
          if (context.canPop()) context.pop();
        },
      },
      child: Focus(autofocus: true, child: child),
    );
  }
}
