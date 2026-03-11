import 'package:flutter/material.dart';
import 'package:forui/forui.dart' as fu;

import '../../../../core/config/theme/app_theme.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/route_constants.dart';
import '../../../../core/utils/datetime_formatter.dart';
import '../../../projects/domain/entities/project.dart';

class RecentProjectTile extends StatelessWidget {
  final Project project;

  const RecentProjectTile({super.key, required this.project});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (project.id != null) {
          Navigator.pushNamed(context, RouteConstants.projectDetailRoute, arguments: project.id!);
        }
      },
      child: fu.FCard(
        child: Padding(
          padding: EdgeInsets.all(AppConstants.spacing.regular),
          child: Row(
            children: [
              Container(
                width: AppConstants.size.icon.large + AppConstants.spacing.small,
                height: AppConstants.size.icon.large + AppConstants.spacing.small,
                decoration: BoxDecoration(
                  color: context.colors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppConstants.border.radius.regular),
                ),
                child: Icon(fu.FIcons.folder, size: AppConstants.size.icon.extraSmall, color: context.colors.primary),
              ),
              SizedBox(width: AppConstants.spacing.regular),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      project.title,
                      style: context.typography.sm.copyWith(fontWeight: FontWeight.w500),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (project.description != null && project.description!.isNotEmpty) ...[
                      SizedBox(height: AppConstants.spacing.extraSmall),
                      Text(
                        project.description!,
                        style: context.typography.xs.copyWith(color: context.colors.mutedForeground),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              if (project.deadline != null) ...[
                Text(
                  project.deadline!.toShortDateString(),
                  style: context.typography.xs.copyWith(color: context.colors.mutedForeground),
                ),
                SizedBox(width: AppConstants.spacing.small),
              ],
              Icon(
                fu.FIcons.chevronRight,
                size: AppConstants.size.icon.extraSmall,
                color: context.colors.mutedForeground,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
