import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart' as fu;

import '../../../../core/common/providers/navigation_provider.dart';
import '../../../../core/config/theme/app_theme.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/audio_assets.dart';
import '../../domain/entities/setting.dart';
import '../providers/settings_provider.dart';
import '../widgets/ambience_toggle_card.dart';
import '../widgets/section_title.dart';
import '../widgets/sound_items_list.dart';
import '../widgets/timer_settings_card.dart';

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
        data: (prefs) => _SettingsContent(prefs: prefs, timerPrefs: timerAsync.value ?? const TimerPreferences()),
      ),
    );
  }
}

class _SettingsContent extends ConsumerWidget {
  final AudioPreferences prefs;
  final TimerPreferences timerPrefs;

  const _SettingsContent({required this.prefs, required this.timerPrefs});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(settingsProvider.notifier);
    final alarmPreset = notifier.getAlarmPreset(prefs);
    final ambiencePreset = notifier.getAmbiencePreset(prefs);
    final previewingId = ref.watch(previewingIdProvider);

    return ListView(
      padding: EdgeInsets.symmetric(vertical: AppConstants.spacing.regular),
      children: [
        SectionTitle(title: 'Focus Audio'),
        SizedBox(height: AppConstants.spacing.regular),

        AmbienceToggleCard(enabled: prefs.ambienceEnabled, onChanged: (value) => notifier.setAmbienceEnabled(value)),
        SizedBox(height: AppConstants.spacing.regular),

        fu.FAccordion(
          children: [
            fu.FAccordionItem(
              title: Text('White Noise / Ambience'),
              initiallyExpanded: false,
              child: fu.FCard(
                child: SoundItemsList(
                  presets: AudioAssets.ambience,
                  selectedId: ambiencePreset.id,
                  previewingId: previewingId,
                  onTap: (preset) {
                    notifier.setAmbienceSound(preset.id);
                    notifier.previewAmbience(preset);
                  },
                ),
              ),
            ),
            fu.FAccordionItem(
              title: Text('Session Alarm'),
              initiallyExpanded: false,
              child: fu.FCard(
                child: SoundItemsList(
                  presets: AudioAssets.alarms,
                  selectedId: alarmPreset.id,
                  previewingId: previewingId,
                  onTap: (preset) {
                    notifier.setAlarmSound(preset.id);
                    notifier.previewAlarm(preset);
                  },
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: AppConstants.spacing.extraLarge),

        // Timer Duration Settings
        SectionTitle(title: 'Pomodoro Timer'),
        SizedBox(height: AppConstants.spacing.regular),

        TimerSettingsCard(
          title: 'Focus Duration',
          subtitle: 'How long each focus session lasts',
          value: timerPrefs.focusDurationMinutes,
          min: 5,
          max: 120,
          step: 5,
          onChanged: (v) => ref.read(settingsProvider.notifier).setFocusDuration(v),
        ),
        SizedBox(height: AppConstants.spacing.regular),

        TimerSettingsCard(
          title: 'Break Duration',
          subtitle: 'Rest time between focus sessions',
          value: timerPrefs.breakDurationMinutes,
          min: 1,
          max: 30,
          step: 1,
          onChanged: (v) => ref.read(settingsProvider.notifier).setBreakDuration(v),
        ),
        SizedBox(height: AppConstants.spacing.extraLarge),
      ],
    );
  }
}
