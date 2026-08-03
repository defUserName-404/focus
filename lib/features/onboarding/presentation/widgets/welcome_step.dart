import 'package:flutter/material.dart';
import 'package:forui/forui.dart' as fu;

import '../../../../core/config/theme/app_theme.dart';
import '../../../../core/constants/app_constants.dart';

/// Step 1 of onboarding: the welcome hero.
class WelcomeStep extends StatelessWidget {
  const WelcomeStep({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppConstants.spacing.extraLarge),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(fu.FLucideIcons.sparkles, size: 56, color: context.colors.primary),
          SizedBox(height: AppConstants.spacing.large),
          Text(
            'Welcome to Focus',
            textAlign: TextAlign.center,
            style: context.typography.xl2.copyWith(fontWeight: FontWeight.w700),
          ),
          SizedBox(height: AppConstants.spacing.regular),
          Text(
            'Deep work, on your terms.',
            textAlign: TextAlign.center,
            style: context.typography.lg.copyWith(color: context.colors.mutedForeground),
          ),
          SizedBox(height: AppConstants.spacing.regular),
          Text(
            "Let's take 30 seconds to set things up.",
            textAlign: TextAlign.center,
            style: context.typography.sm.copyWith(color: context.colors.mutedForeground),
          ),
        ],
      ),
    );
  }
}
