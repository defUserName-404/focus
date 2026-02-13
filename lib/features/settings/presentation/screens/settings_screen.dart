import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart' as fu;

import '../../../../core/config/theme/app_theme.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/audio_assets.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/services/audio_service.dart';
import '../../../../core/common/providers/navigation_provider.dart';
import '../../domain/entities/setting.dart';
import '../providers/settings_provider.dart';
import '../widgets/ambience_toggle_card.dart';
import '../widgets/section_title.dart';
import '../widgets/sound_items_list.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefsAsync = ref.watch(settingsProvider);

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
        data: (prefs) => _SettingsContent(prefs: prefs),
      ),
    );
  }
}

class _SettingsContent extends ConsumerStatefulWidget {
  final AudioPreferences prefs;

  const _SettingsContent({required this.prefs});

  @override
  ConsumerState<_SettingsContent> createState() => _SettingsContentState();
}

class _SettingsContentState extends ConsumerState<_SettingsContent> {
  String? _previewingId;

  AudioService get _audio => getIt<AudioService>();

  void _previewAmbience(SoundPreset preset) {
    setState(() => _previewingId = preset.id);
    _audio.startAmbience(preset);
    Future.delayed(const Duration(seconds: 3), () {
      _audio.stopAmbience();
      if (mounted) setState(() => _previewingId = null);
    });
  }

  void _previewAlarm(SoundPreset preset) {
    setState(() => _previewingId = preset.id);
    _audio.playAlarm(preset);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _previewingId = null);
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
      ],
    );
  }
}
