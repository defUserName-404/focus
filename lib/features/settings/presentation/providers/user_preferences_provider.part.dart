part of 'settings_provider.dart';

/// Stream of [UserPreferences] sourced from [settingsRepositoryProvider].
final userPreferencesProvider = StreamProvider<UserPreferences>((ref) {
  return ref.watch(settingsRepositoryProvider).watchUserPreferences();
});
