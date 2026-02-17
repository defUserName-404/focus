import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart' as fu;

import '../../../../core/config/theme/app_theme.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/audio_assets.dart';
import '../../domain/entities/setting.dart';
import '../providers/settings_provider.dart';
import 'ambience_toggle_card.dart';
import 'section_title.dart';
import 'sound_items_list.dart';
import 'timer_settings_card.dart';

class SettingsContent extends ConsumerWidget {
  final AudioPreferences prefs;
  final TimerPreferences timerPrefs;

  const SettingsContent({super.key, required this.prefs, required this.timerPrefs});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(settingsProvider.notifier);

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
        _AudioAccordion(notifier: notifier),

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
        SizedBox(height: AppConstants.spacing.extraLarge),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Accordion
// ---------------------------------------------------------------------------

/// Stateful so open/close state is owned here and never reset by a parent
/// rebuild. Receives only [notifier] which is a stable reference — this
/// widget will not rebuild due to provider emissions.
class _AudioAccordion extends StatefulWidget {
  final SettingsNotifier notifier;

  const _AudioAccordion({required this.notifier});

  @override
  State<_AudioAccordion> createState() => _AudioAccordionState();
}

class _AudioAccordionState extends State<_AudioAccordion> {
  bool _ambienceExpanded = false;
  bool _alarmExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _ExpandableSection(
          title: 'White Noise / Ambience',
          isExpanded: _ambienceExpanded,
          onToggle: () => setState(() => _ambienceExpanded = !_ambienceExpanded),
          child: _SoundListWithPreview(
            presets: AudioAssets.ambience,
            soundIdSelector: (prefs) => prefs.ambienceSoundId,
            defaultPreset: AudioAssets.defaultAmbience,
            onTap: (preset) {
              widget.notifier.setAmbienceSound(preset.id);
              widget.notifier.previewAmbience(preset);
            },
          ),
        ),
        SizedBox(height: AppConstants.spacing.small),
        _ExpandableSection(
          title: 'Session Alarm',
          isExpanded: _alarmExpanded,
          onToggle: () => setState(() => _alarmExpanded = !_alarmExpanded),
          child: _SoundListWithPreview(
            presets: AudioAssets.alarms,
            soundIdSelector: (prefs) => prefs.alarmSoundId,
            defaultPreset: AudioAssets.defaultAlarm,
            onTap: (preset) {
              widget.notifier.setAlarmSound(preset.id);
              widget.notifier.previewAlarm(preset);
            },
          ),
        ),
      ],
    );
  }
}

/// A single expand/collapse section. Fully controlled — the parent owns the
/// boolean and this widget just renders and fires [onToggle].
class _ExpandableSection extends StatelessWidget {
  final String title;
  final bool isExpanded;
  final VoidCallback onToggle;
  final Widget child;

  const _ExpandableSection({
    required this.title,
    required this.isExpanded,
    required this.onToggle,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return fu.FCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          GestureDetector(
            onTap: onToggle,
            behavior: HitTestBehavior.opaque,
            child: Row(
              children: [
                Expanded(
                  child: Text(title, style: context.typography.sm.copyWith(fontWeight: FontWeight.w600)),
                ),
                AnimatedRotation(
                  turns: isExpanded ? 0.5 : 0,
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    fu.FIcons.chevronDown,
                    size: AppConstants.size.icon.regular,
                    color: context.colors.mutedForeground,
                  ),
                ),
              ],
            ),
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Padding(
              padding: EdgeInsets.only(top: AppConstants.spacing.regular),
              child: child,
            ),
            crossFadeState: isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 200),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Sound list with isolated provider watches
// ---------------------------------------------------------------------------

/// Watches [settingsProvider] (for selectedId) and [previewingIdProvider]
/// in isolation — only this widget rebuilds on those changes.
class _SoundListWithPreview extends ConsumerWidget {
  final List<SoundPreset> presets;
  final String? Function(AudioPreferences) soundIdSelector;
  final SoundPreset defaultPreset;
  final ValueChanged<SoundPreset> onTap;

  const _SoundListWithPreview({
    required this.presets,
    required this.soundIdSelector,
    required this.defaultPreset,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final soundId = ref.watch(settingsProvider.select((s) => s.whenOrNull(data: soundIdSelector)));
    final selectedId = (soundId != null ? AudioAssets.findById(soundId)?.id : null) ?? defaultPreset.id;

    final previewingId = ref.watch(previewingIdProvider);

    return SoundItemsList(presets: presets, selectedId: selectedId, previewingId: previewingId, onTap: onTap);
  }
}
