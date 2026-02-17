import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/audio_assets.dart';
import '../providers/settings_provider.dart';
import 'sound_items_list.dart';

class SoundListWithPreview extends ConsumerWidget {
  final List<SoundPreset> presets;
  final String selectedId;
  final ValueChanged<SoundPreset> onTap;

  const SoundListWithPreview({super.key, required this.presets, required this.selectedId, required this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SoundItemsList(
      presets: presets,
      selectedId: selectedId,
      previewingId: ref.watch(previewingIdProvider),
      onTap: onTap,
    );
  }
}
