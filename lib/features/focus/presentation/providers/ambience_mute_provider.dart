import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/constants/audio_assets.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/services/audio_service.dart';
import '../../../settings/presentation/providers/settings_provider.dart';
import 'focus_session_provider.dart';

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
    final audioService = getIt<AudioService>();
    if (state) {
      audioService.resumeAmbience();
    } else {
      audioService.pauseAmbience();
    }
    state = !state;
  }

  /// Reset mute state (e.g. when a session ends).
  void reset() => state = false;
}

// ── Computed marquee display state ─────────────────────────────────────────

/// All the data the ambience marquee row needs to render.
class AmbienceMarqueeState {
  /// `null` means the row should be hidden entirely.
  final String? soundLabel;
  final bool isMuted;
  final bool isPaused;
  final bool isBreak;

  const AmbienceMarqueeState({
    this.soundLabel,
    this.isMuted = false,
    this.isPaused = false,
    this.isBreak = false,
  });

  /// Whether the marquee text should scroll.
  bool get isScrolling => soundLabel != null && !isMuted && !isPaused && !isBreak;

  /// Whether the visuals should appear dimmed.
  bool get isDimmed => isMuted || isPaused;

  /// Whether the entire row should be hidden.
  bool get isHidden => soundLabel == null || isBreak;
}

@riverpod
AmbienceMarqueeState ambienceMarquee(Ref ref) {
  final isMuted = ref.watch(ambienceMuteProvider);

  // Resolve sound label from audio preferences.
  final prefsAsync = ref.watch(audioPreferencesProvider);
  final soundLabel = prefsAsync.whenOrNull(data: (prefs) {
    if (!prefs.ambienceEnabled) return null;
    SoundPreset? preset;
    if (prefs.ambienceSoundId != null) {
      preset = AudioAssets.findById(prefs.ambienceSoundId!);
    }
    preset ??= AudioAssets.defaultAmbience;
    return preset.label;
  });

  // Resolve session phase.
  final progress = ref.watch(focusProgressProvider);
  final isBreak = progress != null && !progress.isFocusPhase && !progress.isIdle;
  final isPaused = progress != null && progress.isPaused;

  return AmbienceMarqueeState(
    soundLabel: soundLabel,
    isMuted: isMuted,
    isPaused: isPaused,
    isBreak: isBreak,
  );
}
