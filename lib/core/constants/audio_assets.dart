/// Audio asset references and sound presets for the Focus app.
///
/// Default sounds are bundled in `assets/audio/`. Users can customize
/// their preferred alarm and ambient sounds via Settings.
library;

/// The type of sound preset.
enum SoundType { alarm, ambience }

/// A bundled sound preset that ships with the app.
class SoundPreset {
  final String id;
  final String label;
  final String assetPath;
  final SoundType type;

  const SoundPreset({required this.id, required this.label, required this.assetPath, required this.type});
}

/// All available audio presets bundled with the app.
///
/// Place audio files under `assets/audio/alarms/` and `assets/audio/ambience/`.
/// Register new presets here to make them available throughout the app.
abstract final class AudioAssets {
  // ── Alarm Sounds ──────────────────────────────────────────────────────────

  static const List<SoundPreset> alarms = [
    SoundPreset(
      id: 'digital_alarm',
      label: 'Digital Alarm',
      assetPath: 'alarms/digital_alarm.mp3',
      type: SoundType.alarm,
    ),
    SoundPreset(id: 'gentle_bell', label: 'Gentle Bell', assetPath: 'alarms/gentle_bell.mp3', type: SoundType.alarm),
    SoundPreset(id: 'chime', label: 'Chime', assetPath: 'alarms/chime.mp3', type: SoundType.alarm),
  ];

  // ── Ambient / Focus Sounds ────────────────────────────────────────────────

  static const List<SoundPreset> ambience = [
    SoundPreset(id: 'forest', label: 'Forest', assetPath: 'ambience/forest.mp3', type: SoundType.ambience),
    SoundPreset(id: 'rain', label: 'Rain', assetPath: 'ambience/rain.mp3', type: SoundType.ambience),
    SoundPreset(
      id: 'white_noise',
      label: 'White Noise',
      assetPath: 'ambience/white_noise.mp3',
      type: SoundType.ambience,
    ),
    SoundPreset(
      id: 'coffee_shop',
      label: 'Coffee Shop',
      assetPath: 'ambience/coffee_shop.mp3',
      type: SoundType.ambience,
    ),
  ];

  /// Default alarm preset used when no preference is set.
  static SoundPreset get defaultAlarm => alarms.first;

  /// Default ambience preset. Returns the first available, or null if empty.
  static SoundPreset get defaultAmbience => ambience.first;

  /// Find a preset by its ID across all categories.
  static SoundPreset? findById(String id) {
    final all = [...alarms, ...ambience];
    for (final preset in all) {
      if (preset.id == id) return preset;
    }
    return null;
  }
}
