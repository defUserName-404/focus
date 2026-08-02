import 'package:flutter/material.dart';
import 'package:focus/core/config/theme/app_theme.dart';
import 'package:focus/core/constants/app_constants.dart';

/// Lightweight empty-state block used across list/board/calendar surfaces.
class AppEmptyState extends StatelessWidget {
  final IconData icon;
  final String message;
  final String? detail;

  const AppEmptyState({super.key, required this.icon, required this.message, this.detail});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppConstants.spacing.extraLarge2, vertical: AppConstants.spacing.large),
      child: Center(
        child: Column(
          mainAxisSize: .min,
          children: [
            Icon(
              icon,
              size: AppConstants.size.icon.large * 4 / 3,
              color: context.colors.mutedForeground.withValues(alpha: 0.4),
            ),
            SizedBox(height: AppConstants.spacing.regular),
            Text(
              message,
              textAlign: .center,
              style: context.typography.sm.copyWith(color: context.colors.mutedForeground),
            ),
            if (detail != null) ...[
              SizedBox(height: AppConstants.spacing.extraSmall),
              Text(
                detail!,
                textAlign: .center,
                style: context.typography.xs.copyWith(color: context.colors.mutedForeground.withValues(alpha: 0.8)),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
