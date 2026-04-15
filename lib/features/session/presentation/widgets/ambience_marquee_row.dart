import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';

import '../../../../core/config/theme/app_theme.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/marquee_text.dart';
import '../providers/ambience_mute_provider.dart';

class AmbienceMarqueeRow extends ConsumerWidget {
  const AmbienceMarqueeRow({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(ambienceMarqueeProvider);

    if (state.isHidden) return const SizedBox.shrink();

    final dimmedColor = context.colors.mutedForeground;
    final activeColor = context.colors.foreground;
    final color = state.isDimmed ? dimmedColor : activeColor;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppConstants.spacing.large),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(FIcons.music2, size: 14, color: color),
          SizedBox(width: AppConstants.spacing.small),
          Flexible(
            child: SizedBox(
              height: 20,
              child: MarqueeText(
                text: state.soundLabel!,
                isAnimating: state.isScrolling,
                style: context.typography.sm.copyWith(color: color),
              ),
            ),
          ),
          SizedBox(width: AppConstants.spacing.regular),
          GestureDetector(
            onTap: () => ref.read(ambienceMuteProvider.notifier).toggle(),
            child: AnimatedSwitcher(
              duration: AppConstants.animation.short,
              child: Icon(
                state.isMuted ? FIcons.volumeOff : FIcons.volume2,
                key: ValueKey(state.isMuted),
                size: 20,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
