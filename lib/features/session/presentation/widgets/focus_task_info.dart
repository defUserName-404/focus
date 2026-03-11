import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/config/theme/app_theme.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../projects/presentation/providers/project_provider.dart';
import '../../../tasks/presentation/providers/task_provider.dart';
import '../providers/focus_session_provider.dart';

/// Displays the current task title and its parent project name.
/// For quick sessions (no task), shows "Quick Session".
class FocusTaskInfo extends ConsumerWidget {
  const FocusTaskInfo({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(focusTimerProvider);
    if (session == null) return const SizedBox.shrink();

    // Quick session — no associated task.
    if (session.isQuickSession) {
      return Text(
        'Quick Session',
        style: context.typography.xl2.copyWith(fontWeight: FontWeight.w600),
        textAlign: TextAlign.center,
      );
    }

    final taskAsync = ref.watch(taskByIdProvider(session.taskId.toString()));

    return taskAsync.when(
      data: (task) {
        final projectAsync = ref.watch(projectByIdProvider(task.projectId.toString()));
        return Row(
          mainAxisAlignment: .center,
          crossAxisAlignment: .center,
          spacing: AppConstants.spacing.regular,
          children: [
            Text(
              task.title,
              style: context.typography.xl2.copyWith(fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
            projectAsync.when(
              data: (project) => Padding(
                padding: EdgeInsetsGeometry.only(top: AppConstants.spacing.regular),
                child: Text(
                  project?.title ?? '',
                  style: context.typography.base.copyWith(color: context.colors.mutedForeground),
                ),
              ),
              loading: () => const SizedBox.shrink(),
              error: (_, _) => const SizedBox.shrink(),
            ),
          ],
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const Text('Error loading task'),
    );
  }
}
