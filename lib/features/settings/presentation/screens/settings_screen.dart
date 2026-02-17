import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart' as fu;

import '../../../../core/common/providers/navigation_provider.dart';
import '../../../../core/config/theme/app_theme.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/audio_assets.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/services/audio_service.dart';
import '../../../focus/domain/entities/session_state.dart';
import '../../../focus/presentation/providers/focus_providers.dart';
import '../../../focus/presentation/providers/focus_session_provider.dart';
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

class _SettingsContent extends ConsumerStatefulWidget {
  final AudioPreferences prefs;
  final TimerPreferences timerPrefs;

  const _SettingsContent({required this.prefs, required this.timerPrefs});

  @override
  ConsumerState<_SettingsContent> createState() => _SettingsContentState();
}

class _SettingsContentState extends ConsumerState<_SettingsContent> {
  String? _previewingId;

  AudioService get _audio => getIt<AudioService>();

  void _previewAmbience(SoundPreset preset) {
    setState(() => _previewingId = preset.id);

    // Pause session if running
    final session = ref.read(focusTimerProvider);
    final wasRunning = session?.state == SessionState.running || session?.state == SessionState.onBreak;
    if (wasRunning) {
      ref.read(focusTimerProvider.notifier).pauseSession();
    }

    _audio.startAmbience(preset);

    Future.delayed(const Duration(seconds: 3), () async {
      await _audio.stopAmbience();
      if (mounted) setState(() => _previewingId = null);

      if (wasRunning) {
        // Resume session. Since we overwrote the bgPlayer track with the preview,
        // we must force a reload of the correct session ambience.
        ref.read(focusTimerProvider.notifier).resumeSession();
        // resumeSession() calls resumeAmbience() which resumes the *preview* track
        // if we don't fix it. So we reload the correct ambience immediately.
        ref.read(focusAudioCoordinatorProvider).reloadAmbience();
      }
    });
  }

  void _previewAlarm(SoundPreset preset) {
    setState(() => _previewingId = preset.id);

    // Pause session if running (to avoid noise overlap)
    final session = ref.read(focusTimerProvider);
    final wasRunning = session?.state == SessionState.running || session?.state == SessionState.onBreak;
    if (wasRunning) {
      ref.read(focusTimerProvider.notifier).pauseSession();
    }

    _audio.playAlarm(preset);

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _previewingId = null);

      if (wasRunning) {
        ref.read(focusTimerProvider.notifier).resumeSession();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final prefs = widget.prefs;
    final notifier = ref.read(settingsProvider.notifier);
    final alarmPreset = notifier.getAlarmPreset(prefs);
    final ambiencePreset = notifier.getAmbiencePreset(prefs);

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
                  previewingId: _previewingId,
                  onTap: (preset) {
                    notifier.setAmbienceSound(preset.id);
                    _previewAmbience(preset);
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
                  previewingId: _previewingId,
                  onTap: (preset) {
                    notifier.setAlarmSound(preset.id);
                    _previewAlarm(preset);
                  },
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: AppConstants.spacing.extraLarge),

        // ── Timer Duration Settings ────────────────────────────────
        SectionTitle(title: 'Pomodoro Timer'),
        SizedBox(height: AppConstants.spacing.regular),

        TimerSettingsCard(
          title: 'Focus Duration',
          subtitle: 'How long each focus session lasts',
          value: widget.timerPrefs.focusDurationMinutes,
          min: 5,
          max: 120,
          step: 5,
          onChanged: (v) => ref.read(settingsProvider.notifier).setFocusDuration(v),
        ),
        SizedBox(height: AppConstants.spacing.regular),

        TimerSettingsCard(
          title: 'Break Duration',
          subtitle: 'Rest time between focus sessions',
          value: widget.timerPrefs.breakDurationMinutes,
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
