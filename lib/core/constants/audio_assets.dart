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
  // Alarm Sounds
  static const List<SoundPreset> alarms = [
    SoundPreset(
      id: 'digital_alarm',
      label: 'Digital Alarm',
      assetPath: 'alarms/digital_alarm.ogg',
      type: SoundType.alarm,
    ),
    SoundPreset(id: 'bell_alarm', label: 'Gentle Bell', assetPath: 'alarms/bell_alarm.ogg', type: SoundType.alarm),
    SoundPreset(
      id: 'old_mechanical_bell',
      label: 'Old Mechanical Bell',
      assetPath: 'alarms/old_mechanical_bell.ogg',
      type: SoundType.alarm,
    ),
  ];

  // Ambient / Focus Sounds
  static const List<SoundPreset> ambience = [
    SoundPreset(
      id: 'brown_noise',
      label: 'Brown Noise',
      assetPath: 'ambience/brown_noise.ogg',
      type: SoundType.ambience,
    ),
    SoundPreset(id: 'campfire', label: 'Campfire', assetPath: 'ambience/campfire.ogg', type: SoundType.ambience),
    SoundPreset(
      id: 'coffee_shop',
      label: 'Coffee Shop',
      assetPath: 'ambience/coffee_shop.ogg',
      type: SoundType.ambience,
    ),
    SoundPreset(id: 'forest_sound', label: 'Forest', assetPath: 'ambience/forest.ogg', type: SoundType.ambience),
    SoundPreset(
      id: 'ocean_waves',
      label: 'Ocean Waves',
      assetPath: 'ambience/ocean_waves.ogg',
      type: SoundType.ambience,
    ),
    SoundPreset(id: 'office_sound', label: 'Office', assetPath: 'ambience/office.ogg', type: SoundType.ambience),
    SoundPreset(id: 'pink_noise', label: 'Pink Noise', assetPath: 'ambience/pink_noise.ogg', type: SoundType.ambience),
    SoundPreset(
      id: 'rain_wind_thunder',
      label: 'Rain, Wind & Thunder',
      assetPath: 'ambience/rain_wind_and_thunder.ogg',
      type: SoundType.ambience,
    ),
    SoundPreset(id: 'rain', label: 'Rain', assetPath: 'ambience/rain.ogg', type: SoundType.ambience),
    SoundPreset(id: 'river_sound', label: 'River', assetPath: 'ambience/river.ogg', type: SoundType.ambience),
    SoundPreset(
      id: 'white_noise',
      label: 'White Noise',
      assetPath: 'ambience/white_noise.ogg',
      type: SoundType.ambience,
    ),
    SoundPreset(
      id: 'forest_night',
      label: 'Forest Night',
      assetPath: 'ambience/forest_night.ogg',
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
