import 'package:flutter/material.dart';
import 'package:focus/core/config/theme/app_theme.dart';
import 'package:focus/core/constants/app_constants.dart';

class EmptySection extends StatelessWidget {
  final IconData icon;
  final String message;

  const EmptySection({super.key, required this.icon, required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: AppConstants.spacing.extraLarge2,
        vertical: AppConstants.spacing.large,
      ),
      child: Center(
        child: Column(
          children: [
            Icon(
              icon,
              size: AppConstants.size.icon.large * 4 / 3,
              color: context.colors.mutedForeground.withValues(alpha: 0.4),
            ),
            SizedBox(height: AppConstants.spacing.regular),
            Text(
              message,
              style: context.typography.sm.copyWith(color: context.colors.mutedForeground),
            ),
          ],
        ),
      ),
    );
  }
}
