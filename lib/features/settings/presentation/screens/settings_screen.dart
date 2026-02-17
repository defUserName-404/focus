import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart' as fu;

import '../../../../core/common/providers/navigation_provider.dart';
import '../../../../core/config/theme/app_theme.dart';
import '../providers/settings_provider.dart';
import '../widgets/setings_content.dart';

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
              if (Navigator.of(context).canPop()) {
                Navigator.of(context).pop();
              } else {
                ref.read(bottomNavIndexProvider.notifier).goHome();
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
