import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart' as fu;

import '../../../../core/config/theme/app_theme.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/datetime_formatter.dart';
import '../../../../core/utils/result.dart';
import '../../../milestones/domain/entities/milestone.dart';
import '../providers/project_milestones_provider.dart';

class ProjectMilestonesPanel extends ConsumerWidget {
  final int projectId;

  const ProjectMilestonesPanel({super.key, required this.projectId});

  Future<void> _create(BuildContext context, WidgetRef ref) async {
    final controller = TextEditingController();
    final title = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('New milestone'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Milestone title'),
          onSubmitted: (value) => Navigator.of(context).pop(value.trim()),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.of(context).pop(controller.text.trim()), child: const Text('Create')),
        ],
      ),
    );
    if (title == null || title.isEmpty) return;

    final result = await ref.read(milestoneServiceProvider).createMilestone(projectId: projectId, title: title);
    if (result case Failure(:final failure)) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(failure.message)));
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(projectMilestonesProvider(projectId));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: fu.FButton(
            size: .sm,
            mainAxisSize: .min,
            prefix: const Icon(fu.FLucideIcons.plus),
            onPress: () => _create(context, ref),
            child: const Text('Add milestone'),
          ),
        ),
        SizedBox(height: AppConstants.spacing.small),
        Expanded(
          child: async.when(
            loading: () => const Center(child: fu.FCircularProgress()),
            error: (err, _) => Center(child: Text('Error: $err')),
            data: (milestones) {
              if (milestones.isEmpty) {
                return Center(
                  child: Text(
                    'No milestones yet',
                    style: context.typography.sm.copyWith(color: context.colors.mutedForeground),
                  ),
                );
              }

              final sorted = [...milestones]
                ..sort((a, b) {
                  final aDate = a.targetDate;
                  final bDate = b.targetDate;
                  if (aDate == null && bDate == null) return a.title.compareTo(b.title);
                  if (aDate == null) return 1;
                  if (bDate == null) return -1;
                  return aDate.compareTo(bDate);
                });

              return ListView.separated(
                itemCount: sorted.length,
                separatorBuilder: (_, _) => SizedBox(height: AppConstants.spacing.small),
                itemBuilder: (context, index) => _MilestoneTile(milestone: sorted[index]),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _MilestoneTile extends StatelessWidget {
  final Milestone milestone;

  const _MilestoneTile({required this.milestone});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppConstants.spacing.regular),
      decoration: BoxDecoration(
        color: context.colors.muted.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(AppConstants.border.radius.regular),
      ),
      child: Row(
        children: [
          Icon(fu.FLucideIcons.flag, size: AppConstants.size.icon.regular, color: context.colors.primary),
          SizedBox(width: AppConstants.spacing.regular),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(milestone.title, style: context.typography.sm.copyWith(fontWeight: FontWeight.w600)),
                if (milestone.targetDate != null)
                  Text(
                    'Target: ${milestone.targetDate!.toShortDateString()}',
                    style: context.typography.xs.copyWith(color: context.colors.mutedForeground),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
