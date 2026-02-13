import 'package:flutter/material.dart';
import 'package:forui/forui.dart' as fu;

import '../../../../core/config/theme/app_theme.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/audio_assets.dart';

/// Displays a column of [SoundPreset] items for use inside an [fu.FAccordionItem].
///
/// Each item is tappable for preview and shows a check icon when selected.
/// A spinning indicator is shown for the currently previewing sound.
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
    return Column(
      children: [
        for (int i = 0; i < presets.length; i++) ...[
          if (i > 0) fu.FDivider(),
          _SoundItem(
            preset: presets[i],
            isSelected: presets[i].id == selectedId,
            isPreviewing: presets[i].id == previewingId,
            onTap: () => onTap(presets[i]),
          ),
        ],
      ],
    );
  }
}

class _SoundItem extends StatelessWidget {
  final SoundPreset preset;
  final bool isSelected;
  final bool isPreviewing;
  final VoidCallback onTap;

  const _SoundItem({required this.preset, required this.isSelected, required this.isPreviewing, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: AppConstants.spacing.small),
        child: Row(
          children: [
            Icon(
              preset.type == SoundType.ambience ? fu.FIcons.audioLines : fu.FIcons.bellRing,
              color: isSelected ? context.colors.primary : context.colors.mutedForeground,
              size: 20,
            ),
            SizedBox(width: AppConstants.spacing.regular),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    preset.label,
                    style: context.typography.sm.copyWith(
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                      color: isSelected ? context.colors.primary : null,
                    ),
                  ),
                  Text(
                    preset.assetPath.split('/').last,
                    style: context.typography.xs.copyWith(color: context.colors.mutedForeground),
                  ),
                ],
              ),
            ),
            if (isPreviewing)
              SizedBox(width: 20, height: 20, child: fu.FCircularProgress())
            else if (isSelected)
              Icon(fu.FIcons.check, color: context.colors.primary, size: 18),
          ],
        ),
      ),
    );
  }
}
