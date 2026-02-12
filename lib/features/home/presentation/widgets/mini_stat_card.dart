import 'package:flutter/material.dart';
import 'package:focus/core/config/theme/app_theme.dart';
import 'package:focus/core/constants/app_constants.dart';

class MiniStatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const MiniStatCard({
    super.key,
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppConstants.spacing.regular,
        vertical: AppConstants.spacing.large,
      ),
      decoration: BoxDecoration(
        color: context.colors.mutedForeground.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(AppConstants.border.radius.regular),
        border: Border.all(
          color: context.colors.mutedForeground.withValues(alpha: 0.12),
          width: AppConstants.border.width.small,
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            size: AppConstants.size.icon.regular,
            color: context.colors.mutedForeground,
          ),
          SizedBox(height: AppConstants.spacing.small),
          Text(
            value,
            style: context.typography.lg.copyWith(fontWeight: FontWeight.w700),
          ),
          SizedBox(height: AppConstants.spacing.extraSmall),
          Text(
            label,
            style: context.typography.xs.copyWith(color: context.colors.mutedForeground),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
