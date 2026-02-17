import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart' as fu;

import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/audio_assets.dart';
import '../../domain/entities/setting.dart';
import '../providers/settings_provider.dart';
import '../widgets/ambience_toggle_card.dart';
import '../widgets/section_title.dart';
import '../widgets/timer_settings_card.dart';
import 'sound_list_with_preview.dart';

class SettingsContent extends ConsumerWidget {
  final AudioPreferences prefs;
  final TimerPreferences timerPrefs;

  const SettingsContent({super.key, required this.prefs, required this.timerPrefs});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(settingsProvider.notifier);

    final alarmPreset = AudioAssets.resolveAlarm(prefs.alarmSoundId);
    final ambiencePreset = AudioAssets.resolveAmbience(prefs.ambienceSoundId);

    return ListView(
      padding: EdgeInsets.symmetric(vertical: AppConstants.spacing.regular),
      children: [
        const SectionTitle(title: 'Focus Audio'),
        SizedBox(height: AppConstants.spacing.regular),

        AmbienceToggleCard(enabled: prefs.ambienceEnabled, onChanged: notifier.setAmbienceEnabled),
        SizedBox(height: AppConstants.spacing.regular),

        fu.FAccordion(
          children: [
            fu.FAccordionItem(
              title: const Text('White Noise / Ambience'),
              initiallyExpanded: false,
              child: fu.FCard(
                child: SoundListWithPreview(
                  presets: AudioAssets.ambience,
                  selectedId: ambiencePreset.id,
                  onTap: (preset) {
                    notifier.setAmbienceSound(preset.id);
                    notifier.previewAmbience(preset);
                  },
                ),
              ),
            ),
            fu.FAccordionItem(
              title: const Text('Session Alarm'),
              initiallyExpanded: false,
              child: fu.FCard(
                child: SoundListWithPreview(
                  presets: AudioAssets.alarms,
                  selectedId: alarmPreset.id,
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
        SizedBox(height: AppConstants.spacing.regular),

        TimerSettingsCard(
          title: 'Break Duration',
          subtitle: 'Rest time between focus sessions',
          value: timerPrefs.breakDurationMinutes,
          min: 1,
          max: 30,
          step: 1,
          onChanged: notifier.setBreakDuration,
        ),
        SizedBox(height: AppConstants.spacing.extraLarge),
      ],
    );
  }
}
