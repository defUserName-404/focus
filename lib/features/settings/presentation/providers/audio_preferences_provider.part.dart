part of 'settings_provider.dart';

final audioPreferencesProvider = StreamProvider<AudioPreferences>((ref) {
  return ref.watch(settingsRepositoryProvider).watchAudioPreferences();
});
