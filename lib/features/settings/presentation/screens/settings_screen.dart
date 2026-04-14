import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart' as fu;
import 'package:go_router/go_router.dart';

import '../../../../core/config/theme/app_theme.dart';
import '../../../../core/routing/routes.dart';
import '../providers/settings_provider.dart';
import '../widgets/settings_content.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefsAsync = ref.watch(settingsProvider);
    final timerAsync = ref.watch(timerSettingsProvider);

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
        title: Text('Settings', style: context.typography.xl2.copyWith(fontWeight: FontWeight.w700)),
      ),
      child: prefsAsync.when(
        loading: () => const Center(child: fu.FCircularProgress()),
        error: (err, _) => Center(child: Text('Error: $err')),
        data: (prefs) => timerAsync.when(
          loading: () => const Center(child: fu.FCircularProgress()),
          error: (err, _) => Center(child: Text('Error: $err')),
          data: (timerPrefs) => SettingsContent(prefs: prefs, timerPrefs: timerPrefs),
        ),
      ),
    );
  }
}
