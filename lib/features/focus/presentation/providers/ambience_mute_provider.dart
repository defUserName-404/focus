import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/constants/audio_assets.dart';
import '../../../settings/presentation/providers/settings_provider.dart';
import '../models/ambience_marquee_state.dart';
import 'focus_progress_provider.dart';
import 'focus_providers.dart';

part 'ambience_mute_provider.g.dart';

/// Whether the focus-session ambience audio is currently muted.
///
/// Toggling this pauses / resumes the ambient player via [AudioService]
/// without stopping the session or losing the current sound preset.
@Riverpod(keepAlive: true)
class AmbienceMute extends _$AmbienceMute {
  @override
  bool build() => false; // not muted by default

  void toggle() {
    final audioCoordinator = ref.read(focusAudioCoordinatorProvider);
    if (state) {
      audioCoordinator.resumeAmbience();
    } else {
      audioCoordinator.pauseAmbience();
    }
    state = !state;
  }

  /// Reset mute state (e.g. when a session ends).
  void reset() => state = false;
}

//  Computed marquee display state

@riverpod
AmbienceMarqueeState ambienceMarquee(Ref ref) {
  final isMuted = ref.watch(ambienceMuteProvider);

  // Resolve sound label from audio preferences.
  final prefsAsync = ref.watch(audioPreferencesProvider);
  final soundLabel = prefsAsync.whenOrNull(
    data: (prefs) {
      if (!prefs.ambienceEnabled) return null;
      SoundPreset? preset;
      if (prefs.ambienceSoundId != null) {
        preset = AudioAssets.findById(prefs.ambienceSoundId!);
      }
      preset ??= AudioAssets.defaultAmbience;
      return preset.label;
    },
  );

  // Resolve session phase.
  final progress = ref.watch(focusProgressProvider);
  final isBreak = progress != null && !progress.isFocusPhase && !progress.isIdle;
  final isPaused = progress != null && progress.isPaused;

  return AmbienceMarqueeState(soundLabel: soundLabel, isMuted: isMuted, isPaused: isPaused, isBreak: isBreak);
}
