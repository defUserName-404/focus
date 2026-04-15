import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/audio_assets.dart';
import '../../domain/entities/setting.dart';
import '../providers/settings_provider.dart';
import 'sound_items_list.dart';

class SoundListWithPreview extends ConsumerWidget {
  final List<SoundPreset> presets;
  final String? Function(AudioPreferences) soundIdSelector;
  final SoundPreset defaultPreset;
  final ValueChanged<SoundPreset> onTap;

  const SoundListWithPreview({
    super.key,
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
