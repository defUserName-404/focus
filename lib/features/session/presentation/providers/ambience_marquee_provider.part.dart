part of 'ambience_mute_provider.dart';

@riverpod
AmbienceMarqueeState ambienceMarquee(Ref ref) {
  final isMuted = ref.watch(ambienceMuteProvider);

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

  final progress = ref.watch(focusProgressProvider);
  final isBreak = progress != null && !progress.isFocusPhase && !progress.isIdle;
  final isPaused = progress != null && progress.isPaused;

  return AmbienceMarqueeState(soundLabel: soundLabel, isMuted: isMuted, isPaused: isPaused, isBreak: isBreak);
}
