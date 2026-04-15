part of 'settings_provider.dart';

final desktopSettingsProvider = StreamProvider<DesktopPreferences>((ref) {
  return ref.watch(settingsRepositoryProvider).watchDesktopPreferences();
});
