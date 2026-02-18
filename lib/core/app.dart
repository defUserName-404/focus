import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

import 'common/widgets/adaptive_shell.dart';
import 'config/theme/app_theme.dart';
import 'constants/route_constants.dart';
import 'routing/app_router.dart';
import 'routing/navigator_key.dart';

class FocusApp extends StatelessWidget {
  const FocusApp({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.builder.build();

    return MaterialApp(
      title: 'Focus',
      navigatorKey: rootNavigatorKey,
      supportedLocales: FLocalizations.supportedLocales,
      localizationsDelegates: const [...FLocalizations.localizationsDelegates],
      debugShowCheckedModeBanner: false,
      theme: theme.toApproximateMaterialTheme(),
      builder: (_, child) => FAnimatedTheme(data: theme, child: child!),
      initialRoute: RouteConstants.homeRoute,
      onGenerateRoute: (settings) {
        // Home route → MainShell (contains bottom nav + nested navigators).
        if (settings.name == RouteConstants.homeRoute) {
          return MaterialPageRoute(settings: settings, builder: (_) => const AdaptiveShell());
        }

        // Full-screen routes that render above the shell (e.g. focus session).
        final fullScreen = AppRouter.generateFullScreenRoute(settings);
        if (fullScreen != null) return fullScreen;

        // Tab-level routes (fallback for deep links or direct pushes on root).
        final tab = AppRouter.generateTabRoute(settings);
        if (tab != null) return tab;

        return MaterialPageRoute(builder: (_) => const Text('Error: Unknown route'));
      },
    );
  }
}
