import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../features/projects/presentation/commands/project_commands.dart';
import '../../features/tasks/presentation/commands/task_commands.dart';
import '../routing/routes.dart';
import '../utils/platform_utils.dart';

class AppKeyboardShortcuts extends StatelessWidget {
  final Widget child;

  const AppKeyboardShortcuts({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final meta = PlatformUtils.isDesktop;
    return CallbackShortcuts(
      bindings: {
        SingleActivator(LogicalKeyboardKey.keyN, control: !meta, meta: meta): () {
          TaskCommands.createWithProject(context);
        },
        SingleActivator(LogicalKeyboardKey.keyP, control: !meta, meta: meta): () {
          ProjectCommands.create(context);
        },
        const SingleActivator(LogicalKeyboardKey.space): () {
          context.push(AppRoutes.focusSession.path);
        },
        const SingleActivator(LogicalKeyboardKey.escape): () {
          if (context.canPop()) context.pop();
        },
      },
      child: Focus(autofocus: true, child: child),
    );
  }
}
