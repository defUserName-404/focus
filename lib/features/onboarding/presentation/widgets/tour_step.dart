import 'package:flutter/material.dart';

import '../../../../core/config/theme/app_theme.dart';
import '../../../../core/constants/app_constants.dart';

/// Steps 2-4 of onboarding: a reusable feature-tour card.
class TourStep extends StatelessWidget {
  final IconData icon;
  final String title;
  final String body;

  const TourStep({required this.icon, required this.title, required this.body, super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppConstants.spacing.extraLarge),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              color: context.colors.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(48),
            ),
            child: Icon(icon, size: 44, color: context.colors.primary),
          ),
          SizedBox(height: AppConstants.spacing.large),
          Text(
            title,
            textAlign: TextAlign.center,
            style: context.typography.xl.copyWith(fontWeight: FontWeight.w700),
          ),
          SizedBox(height: AppConstants.spacing.regular),
          Text(
            body,
            textAlign: TextAlign.center,
            style: context.typography.md.copyWith(color: context.colors.mutedForeground),
          ),
        ],
      ),
    );
  }
}
