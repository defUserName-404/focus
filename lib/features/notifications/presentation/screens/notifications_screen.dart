import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart' as fu;
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/routing/routes.dart';
import '../widgets/recent_notifications_section.dart';
import '../widgets/upcoming_reminders_section.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return fu.FScaffold(
      header: fu.FHeader.nested(
        prefixes: [
          fu.FHeaderAction.back(
            onPress: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go(AppRoutes.home.path);
              }
            },
          ),
        ],
        title: const Text('Notifications'),
      ),
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const UpcomingRemindersSection(),
          SizedBox(height: AppConstants.spacing.large),
          const RecentNotificationsSection(),
          SizedBox(height: AppConstants.spacing.large),
        ],
      ),
    );
  }
}
