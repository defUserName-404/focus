import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

import '../features/home/presentation/pages/home_screen.dart';
import 'config/theme/app_theme.dart';

class FocusApp extends StatelessWidget {
  const FocusApp({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.builder.build();

    return MaterialApp(
      title: 'Focus',
      supportedLocales: FLocalizations.supportedLocales,
      localizationsDelegates: const [...FLocalizations.localizationsDelegates],
      debugShowCheckedModeBanner: false,
      theme: theme.toApproximateMaterialTheme(),
      builder: (_, child) => FAnimatedTheme(data: theme, child: child!),
      home: const FScaffold(child: HomeScreen()),
    );
  }
}
