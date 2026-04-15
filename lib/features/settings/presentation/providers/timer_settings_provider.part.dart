part of 'settings_provider.dart';

final timerSettingsProvider = StreamProvider<TimerPreferences>((ref) {
  return ref.watch(settingsRepositoryProvider).watchTimerPreferences();
});
