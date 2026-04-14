import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:window_manager/window_manager.dart';

import 'core/app.dart';
import 'core/di/injection.dart';
import 'core/services/desktop_lifecycle_service.dart';
import 'core/utils/platform_utils.dart';
import 'features/tasks/domain/services/task_notification_service.dart';

void main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();
  final startHidden = args.contains('--start-hidden');

  if (PlatformUtils.isDesktop) {
    await windowManager.ensureInitialized();
    const windowOptions = WindowOptions(title: 'Focus', center: true, minimumSize: Size(960, 640), skipTaskbar: false);

    await windowManager.waitUntilReadyToShow(windowOptions, () async {
      if (startHidden) {
        await windowManager.hide();
        await windowManager.setSkipTaskbar(true);
        return;
      }

      await windowManager.show();
      await windowManager.focus();
    });
  }

  await setupDependencyInjection();

  if (PlatformUtils.isDesktop) {
    await getIt<DesktopLifecycleService>().init(startHidden: startHidden);
  }

  await getIt<TaskNotificationService>().rescheduleAllReminders();

  runApp(const ProviderScope(child: FocusApp()));
}
