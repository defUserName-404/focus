import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart' as fu;

import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/platform_utils.dart';
import '../../../sync/presentation/widgets/sync_settings_card.dart';
import '../../domain/entities/setting.dart';
import '../providers/settings_provider.dart';
import 'audio_accordion.dart';
import 'ambience_toggle_card.dart';
import 'desktop_toggle_card.dart';
import 'section_title.dart';
import 'timer_settings_card.dart';

class SettingsContent extends ConsumerWidget {
  final AudioPreferences prefs;
  final TimerPreferences timerPrefs;

  const SettingsContent({super.key, required this.prefs, required this.timerPrefs});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(settingsProvider.notifier);
    final desktopPrefsAsync = ref.watch(desktopSettingsProvider);

    return ListView(
      padding: EdgeInsets.symmetric(vertical: AppConstants.spacing.regular),
      children: [
        const SectionTitle(title: 'Focus Audio'),
        SizedBox(height: AppConstants.spacing.regular),

        AmbienceToggleCard(enabled: prefs.ambienceEnabled, onChanged: notifier.setAmbienceEnabled),
        SizedBox(height: AppConstants.spacing.small),

        // _AudioAccordion is a StatefulWidget that owns open/close state.
        // It only receives the stable notifier reference so it is never
        // rebuilt by settingsProvider changes — its State survives.
        AudioAccordion(notifier: notifier),

        SizedBox(height: AppConstants.spacing.large),

        const SectionTitle(title: 'Pomodoro Timer'),
        SizedBox(height: AppConstants.spacing.regular),

        TimerSettingsCard(
          title: 'Focus Duration',
          subtitle: 'How long each focus session lasts',
          value: timerPrefs.focusDurationMinutes,
          min: 5,
          max: 120,
          step: 5,
          onChanged: notifier.setFocusDuration,
        ),
        SizedBox(height: AppConstants.spacing.small),

        TimerSettingsCard(
          title: 'Break Duration',
          subtitle: 'Rest time between focus sessions',
          value: timerPrefs.breakDurationMinutes,
          min: 1,
          max: 30,
          step: 1,
          onChanged: notifier.setBreakDuration,
        ),
        if (PlatformUtils.isDesktop) ...[
          SizedBox(height: AppConstants.spacing.large),
          const SectionTitle(title: 'Desktop Behavior'),
          SizedBox(height: AppConstants.spacing.regular),
          desktopPrefsAsync.when(
            loading: () => const Center(child: fu.FCircularProgress()),
            error: (err, _) => fu.FCard(child: Text('Desktop settings unavailable: $err')),
            data: (desktopPrefs) => Column(
              children: [
                DesktopToggleCard(
                  title: 'Minimize To Tray On Close',
                  subtitle: 'Keep Focus running in the tray instead of quitting when the window closes',
                  enabled: desktopPrefs.trayEnabled,
                  onChanged: notifier.setDesktopTrayEnabled,
                ),
                SizedBox(height: AppConstants.spacing.small),
                DesktopToggleCard(
                  title: 'Launch At Startup',
                  subtitle: 'Start Focus automatically after desktop sign-in',
                  enabled: desktopPrefs.launchAtStartupEnabled,
                  onChanged: notifier.setDesktopLaunchAtStartupEnabled,
                ),
              ],
            ),
          ),
        ],
        SizedBox(height: AppConstants.spacing.large),
        const SectionTitle(title: 'Cloud Sync'),
        SizedBox(height: AppConstants.spacing.regular),
        const SyncSettingsCard(),
        SizedBox(height: AppConstants.spacing.extraLarge),
      ],
    );
  }
}
