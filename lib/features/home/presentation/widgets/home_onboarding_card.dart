import 'package:flutter/material.dart';
import 'package:forui/forui.dart' as fu;
import 'package:go_router/go_router.dart';

import '../../../../core/config/theme/app_theme.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/routing/routes.dart';

/// Single empty-state card for brand-new users (replaces three empty sections).
class HomeOnboardingCard extends StatelessWidget {
  const HomeOnboardingCard({super.key});

  @override
  Widget build(BuildContext context) {
    return fu.FCard(
      child: Padding(
        padding: EdgeInsets.all(AppConstants.spacing.large),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(fu.FLucideIcons.sparkles, size: AppConstants.size.icon.large, color: context.colors.primary),
            SizedBox(height: AppConstants.spacing.regular),
            Text('Welcome to Focus', style: context.typography.lg.copyWith(fontWeight: FontWeight.w700)),
            SizedBox(height: AppConstants.spacing.small),
            Text(
              'Create a project and add tasks or habits — your agenda and week strip will fill in here.',
              style: context.typography.sm.copyWith(color: context.colors.mutedForeground),
            ),
            SizedBox(height: AppConstants.spacing.large),
            fu.FButton(
              onPress: () => context.push(AppRoutes.createProject.path),
              prefix: const Icon(fu.FLucideIcons.plus, size: 14),
              child: const Text('Create project'),
            ),
          ],
        ),
      ),
    );
  }
}
