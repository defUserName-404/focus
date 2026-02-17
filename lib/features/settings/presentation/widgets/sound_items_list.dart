import 'package:flutter/material.dart';
import 'package:forui/forui.dart' as fu;

import '../../../../core/config/theme/app_theme.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/audio_assets.dart';

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
      itemBuilder: (_, i) => _SoundItem(
        preset: presets[i],
        isSelected: presets[i].id == selectedId,
        isPreviewing: presets[i].id == previewingId,
        onTap: () => onTap(presets[i]),
      ),
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
                spacing: AppConstants.spacing.small,
                children: [
                  Text(
                    preset.label,
                    style: context.typography.sm.copyWith(
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                      color: isSelected ? context.colors.primary : null,
                    ),
                  ),
                  Text(
                    preset.description,
                    style: context.typography.xs.copyWith(color: context.colors.mutedForeground),
                  ),
                ],
              ),
            ),
            if (isPreviewing)
              SizedBox(width: 18, height: 18, child: fu.FCircularProgress())
            else if (isSelected)
              Icon(fu.FIcons.check, color: context.colors.primary, size: 18),
          ],
        ),
      ),
    );
  }
}
