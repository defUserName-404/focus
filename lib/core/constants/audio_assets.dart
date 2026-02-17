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
  final String description;
  final String assetPath;
  final SoundType type;

  const SoundPreset({
    required this.id,
    required this.label,
    required this.description,
    required this.assetPath,
    required this.type,
  });
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
      description: 'Sharp electronic beeps to cut through focus',
      assetPath: 'alarms/digital_alarm.ogg',
      type: SoundType.alarm,
    ),
    SoundPreset(
      id: 'bell_alarm',
      label: 'Gentle Bell',
      description: 'Soft chime for a calm session end',
      assetPath: 'alarms/bell_alarm.ogg',
      type: SoundType.alarm,
    ),
    SoundPreset(
      id: 'old_mechanical_bell',
      label: 'Old Mechanical Bell',
      description: 'Classic ringing bell, hard to miss',
      assetPath: 'alarms/old_mechanical_bell.ogg',
      type: SoundType.alarm,
    ),
  ];

  // Ambient / Focus Sounds
  static const List<SoundPreset> ambience = [
    SoundPreset(
      id: 'brown_noise',
      label: 'Brown Noise',
      description: 'Deep, rumbling noise for deep focus',
      assetPath: 'ambience/brown_noise.ogg',
      type: SoundType.ambience,
    ),
    SoundPreset(
      id: 'campfire',
      label: 'Campfire',
      description: 'Crackling wood and gentle flames',
      assetPath: 'ambience/campfire.ogg',
      type: SoundType.ambience,
    ),
    SoundPreset(
      id: 'coffee_shop',
      label: 'Coffee Shop',
      description: 'Busy café murmur and background chatter',
      assetPath: 'ambience/coffee_shop.ogg',
      type: SoundType.ambience,
    ),
    SoundPreset(
      id: 'forest_sound',
      label: 'Forest',
      description: 'Birds, leaves and gentle woodland sounds',
      assetPath: 'ambience/forest.ogg',
      type: SoundType.ambience,
    ),
    SoundPreset(
      id: 'ocean_waves',
      label: 'Ocean Waves',
      description: 'Slow rolling waves on an open shore',
      assetPath: 'ambience/ocean_waves.ogg',
      type: SoundType.ambience,
    ),
    SoundPreset(
      id: 'office_sound',
      label: 'Office',
      description: 'Keyboards and ambient office hum',
      assetPath: 'ambience/office.ogg',
      type: SoundType.ambience,
    ),
    SoundPreset(
      id: 'pink_noise',
      label: 'Pink Noise',
      description: 'Balanced noise, easier on the ears than white',
      assetPath: 'ambience/pink_noise.ogg',
      type: SoundType.ambience,
    ),
    SoundPreset(
      id: 'rain_wind_thunder',
      label: 'Rain, Wind & Thunder',
      description: 'Full storm atmosphere with distant thunder',
      assetPath: 'ambience/rain_wind_and_thunder.ogg',
      type: SoundType.ambience,
    ),
    SoundPreset(
      id: 'rain',
      label: 'Rain',
      description: 'Steady rainfall on a quiet afternoon',
      assetPath: 'ambience/rain.ogg',
      type: SoundType.ambience,
    ),
    SoundPreset(
      id: 'river_sound',
      label: 'River',
      description: 'Flowing water over rocks and pebbles',
      assetPath: 'ambience/river.ogg',
      type: SoundType.ambience,
    ),
    SoundPreset(
      id: 'white_noise',
      label: 'White Noise',
      description: 'Steady broadband noise to mask distractions',
      assetPath: 'ambience/white_noise.ogg',
      type: SoundType.ambience,
    ),
  ];

  /// Default alarm preset used when no preference is set.
  static SoundPreset get defaultAlarm => alarms.first;

  /// Default ambience preset used when no preference is set.
  static SoundPreset get defaultAmbience => ambience.first;

  /// Find a preset by its ID across all categories.
  static SoundPreset? findById(String id) {
    for (final preset in [...alarms, ...ambience]) {
      if (preset.id == id) return preset;
    }
    return null;
  }

  static SoundPreset resolveAlarm(String? soundId) {
    if (soundId != null) {
      final found = findById(soundId);
      if (found != null) return found;
    }
    return defaultAlarm;
  }

  static SoundPreset resolveAmbience(String? soundId) {
    if (soundId != null) {
      final found = findById(soundId);
      if (found != null) return found;
    }
    return defaultAmbience;
  }
}
