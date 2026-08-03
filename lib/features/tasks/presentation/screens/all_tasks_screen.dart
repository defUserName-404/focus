import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart' as fu;
import 'package:go_router/go_router.dart';

import '../../../../core/config/theme/app_theme.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/routing/routes.dart';
import '../../../../core/widgets/constrained_content.dart';
import '../commands/task_commands.dart';
import '../models/task_selection.dart';
import '../widgets/all_tasks_content.dart';

/// Global all-tasks screen that shows tasks across all projects.
///
/// This is part of the tasks feature (not a standalone feature) and
/// serves as the Tasks tab root in the main shell.
class AllTasksScreen extends ConsumerWidget {
  final int? selectedTaskId;
  final ValueChanged<TaskSelection>? onTaskSelected;

  const AllTasksScreen({super.key, this.selectedTaskId, this.onTaskSelected});

  bool get _isEmbedded => onTaskSelected != null;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final content = ConstrainedContent(
      maxWidth: _isEmbedded ? double.infinity : 980,
      padding: EdgeInsets.symmetric(
        horizontal: _isEmbedded ? AppConstants.spacing.regular : AppConstants.spacing.large,
        vertical: AppConstants.spacing.regular,
      ),
      child: AllTasksContent(isEmbedded: _isEmbedded, selectedTaskId: selectedTaskId, onTaskSelected: onTaskSelected),
    );

    if (_isEmbedded) {
      return content;
    }

    return fu.FScaffold(
      header: fu.FHeader.nested(
        prefixes: [
          fu.FHeaderAction.back(
            onPress: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go(AppRoutes.home.path);
              }
            },
          ),
        ],
        title: Text('Tasks', style: context.typography.xl2.copyWith(fontWeight: FontWeight.w700)),
        suffixes: [
          fu.FTooltip(
            tipBuilder: (context, _) => const Text('Create task'),
            child: fu.FHeaderAction(
              icon: const Icon(fu.FLucideIcons.plus),
              semanticsLabel: 'Create task',
              onPress: () => TaskCommands.createWithProject(context),
            ),
          ),
        ],
      ),
      child: content,
    );
  }
}
