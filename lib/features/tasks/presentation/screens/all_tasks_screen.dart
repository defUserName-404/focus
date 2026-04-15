import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart' as fu;
import 'package:go_router/go_router.dart';

import '../../../../core/config/theme/app_theme.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/routing/routes.dart';
import '../../../../core/utils/platform_utils.dart';
import '../../../../core/widgets/constrained_content.dart';
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
    final isCompact = context.isCompact;

    final content = ConstrainedContent(
      maxWidth: 980,
      padding: _isEmbedded
          ? EdgeInsets.symmetric(horizontal: AppConstants.spacing.extraLarge, vertical: AppConstants.spacing.large)
          : EdgeInsets.zero,
      child: AllTasksContent(
        isCompact: isCompact,
        isEmbedded: _isEmbedded,
        selectedTaskId: selectedTaskId,
        onTaskSelected: onTaskSelected,
      ),
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
      ),
      footer: Padding(
        padding: EdgeInsets.all(isCompact ? AppConstants.spacing.regular : AppConstants.spacing.large),
        child: fu.FButton(
          prefix: Icon(fu.FIcons.plus),
          child: const Text('Create New Task'),
          onPress: () => context.push(AppRoutes.createTaskWithProject.path),
        ),
      ),
      child: content,
    );
  }
}
