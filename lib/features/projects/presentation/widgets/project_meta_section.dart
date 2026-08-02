import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart' as fu;

import '../../../../core/providers/expansion_provider.dart';
import '../../../../core/utils/datetime_formatter.dart';
import '../../../../core/config/theme/app_theme.dart';
import '../../../../core/constants/app_constants.dart';
import '../../domain/entities/project.dart';

class ProjectMetaSection extends ConsumerWidget {
  final Project project;

  const ProjectMetaSection({super.key, required this.project});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final project = this.project;
    final expansionKey = 'project_meta_${project.id}';
    final isExpanded = ref.watch(expansionProvider.select((map) => map[expansionKey] ?? false));
    final hasAnyMeta = project.startDate != null || project.deadline != null;

    if (!hasAnyMeta) return const SizedBox.shrink();

    final isOverdue = project.deadline?.isOverdue ?? false;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () => ref.read(expansionProvider.notifier).toggle(expansionKey),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: Icon(
                  isExpanded ? fu.FLucideIcons.chevronDown : fu.FLucideIcons.chevronRight,
                  size: AppConstants.size.icon.small,
                  color: context.colors.mutedForeground,
                ),
              ),
              const SizedBox(width: 4),
              Text('Project details', style: context.typography.xs.copyWith(color: context.colors.mutedForeground)),
              if (isOverdue && !isExpanded) ...[
                const SizedBox(width: 8),
                Padding(
                  padding: const EdgeInsets.only(bottom: 2),
                  child: Icon(
                    fu.FLucideIcons.triangleAlert,
                    color: context.colors.destructive,
                    size: AppConstants.size.icon.small,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  'Overdue',
                  style: context.typography.xs.copyWith(color: context.colors.destructive, fontWeight: FontWeight.w600),
                ),
              ],
            ],
          ),
        ),
        if (isExpanded) ...[
          const SizedBox(height: 12),
          Wrap(
            spacing: AppConstants.spacing.regular,
            runSpacing: AppConstants.spacing.regular,
            children: [
              if (project.startDate != null)
                fu.FBadge(
                  variant: .outline,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 2),
                        child: Icon(
                          fu.FLucideIcons.calendarClock,
                          size: AppConstants.size.icon.small,
                          color: context.colors.mutedForeground,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text('Started: ${project.startDate!.toShortDateString()}'),
                    ],
                  ),
                ),
              if (project.deadline != null)
                fu.FBadge(
                  variant: isOverdue ? .destructive : .secondary,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 2),
                        child: Icon(
                          isOverdue ? fu.FLucideIcons.triangleAlert : fu.FLucideIcons.calendarCheck,
                          size: AppConstants.size.icon.small,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(project.deadline!.toRelativeDueString()),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ],
    );
  }
}
