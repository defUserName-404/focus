import 'package:flutter/material.dart';
import 'package:forui/forui.dart' as fu;

import '../../../../core/constants/audio_assets.dart';
import 'sound_item_tile.dart';

/// Displays a column of [SoundPreset] items for use inside an expandable section.
///
/// Uses shrinkWrap so it sizes to its content without needing a fixed height.
/// The parent is responsible for providing a scrollable context if needed.
class SoundItemsList extends StatelessWidget {
  final List<SoundPreset> presets;
  final String selectedId;
  final String? previewingId;
  final ValueChanged<SoundPreset> onTap;

  const SoundItemsList({
    super.key,
    required this.presets,
    required this.selectedId,
    required this.previewingId,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: presets.length,
      separatorBuilder: (_, _) => const fu.FDivider(),
      itemBuilder: (_, i) => SoundItemTile(
        preset: presets[i],
        isSelected: presets[i].id == selectedId,
        isPreviewing: presets[i].id == previewingId,
        onTap: () => onTap(presets[i]),
      ),
    );
  }
}
