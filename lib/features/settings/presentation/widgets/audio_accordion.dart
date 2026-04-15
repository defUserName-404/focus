import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/audio_assets.dart';
import '../providers/settings_provider.dart';
import 'expandable_section.dart';
import 'sound_list_with_preview.dart';

class AudioAccordion extends StatefulWidget {
  final SettingsNotifier notifier;

  const AudioAccordion({super.key, required this.notifier});

  @override
  State<AudioAccordion> createState() => _AudioAccordionState();
}

class _AudioAccordionState extends State<AudioAccordion> {
  bool _ambienceExpanded = false;
  bool _alarmExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ExpandableSection(
          title: 'White Noise / Ambience',
          isExpanded: _ambienceExpanded,
          onToggle: () => setState(() => _ambienceExpanded = !_ambienceExpanded),
          child: SoundListWithPreview(
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
        ExpandableSection(
          title: 'Session Alarm',
          isExpanded: _alarmExpanded,
          onToggle: () => setState(() => _alarmExpanded = !_alarmExpanded),
          child: SoundListWithPreview(
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
