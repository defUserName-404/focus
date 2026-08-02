import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

import 'config/theme/app_theme.dart';
import 'routing/app_router.dart';
import 'utils/platform_utils.dart';

class FocusApp extends StatelessWidget {
  const FocusApp({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.builder.build(touch: PlatformUtils.isMobile);

    return MaterialApp.router(
      title: 'Focus',
      routerConfig: appRouter,
      supportedLocales: FLocalizations.supportedLocales,
      localizationsDelegates: const [...FLocalizations.localizationsDelegates],
      debugShowCheckedModeBanner: false,
      theme: theme.toApproximateMaterialTheme(),
      builder: (_, child) => FTheme(data: theme, child: child!),
    );
  }
}
