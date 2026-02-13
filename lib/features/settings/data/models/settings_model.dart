import 'package:drift/drift.dart';

/// Key-value settings table for user preferences.
///
/// Stores configuration such as selected alarm sound, ambient sound,
/// and volume levels. Each setting is stored as a string key with a
/// string value, allowing flexible expansion of preferences.
@DataClassName('SettingsData')
class SettingsTable extends Table {
  /// Unique setting key, e.g. `'alarm_sound_id'`, `'ambience_sound_id'`.
  TextColumn get key => text()();

  /// The setting value stored as a string.
  TextColumn get value => text()();

  @override
  Set<Column> get primaryKey => {key};
}
