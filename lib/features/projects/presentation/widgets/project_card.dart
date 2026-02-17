import 'package:flutter/material.dart';
import 'package:focus/core/common/utils/datetime_formatter.dart';
import 'package:forui/forui.dart' as fu;

import '../../../../core/common/widgets/action_menu_button.dart';
import '../../../../core/common/widgets/app_card.dart';
import '../../../../core/config/theme/app_theme.dart';
import '../../../../core/constants/app_constants.dart';
import '../../domain/entities/project.dart';

class ProjectCard extends StatelessWidget {
  final Project project;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const ProjectCard({super.key, required this.project, this.onTap, this.onEdit, this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppConstants.spacing.regular),
      child: AppCard(
        onTap: onTap,
        title: Text(project.title),
        trailing: ActionMenuButton(onEdit: onEdit, onDelete: onDelete),
        subtitle: (project.description != null && project.description!.isNotEmpty)
            ? Text(
                project.description!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: context.typography.sm.copyWith(color: context.colors.mutedForeground),
              )
            : null,
        footerActions: [
          fu.FBadge(
            style: project.deadline?.isOverdue ?? false ? fu.FBadgeStyle.destructive() : fu.FBadgeStyle.secondary(),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 2),
                  child: Icon(fu.FIcons.calendarCheck, size: AppConstants.size.icon.small),
                ),
                const SizedBox(width: 4),
                Text(project.deadline?.toRelativeDueString() ?? 'No deadline'),
              ],
            ),
          ),
          Spacer(),
          fu.FButton.icon(
            onPress: onTap,
            child: Icon(fu.FIcons.arrowRight, size: AppConstants.size.icon.regular),
          ),
        ],
      ),
    );
  }
}
