import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/app.dart';
import 'core/di/injection.dart';
import 'features/tasks/domain/services/task_notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await setupDependencyInjection();
  await getIt<TaskNotificationService>().rescheduleAllReminders();

  runApp(const ProviderScope(child: FocusApp()));
}
