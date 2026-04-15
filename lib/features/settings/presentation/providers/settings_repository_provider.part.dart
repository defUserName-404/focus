part of 'settings_provider.dart';

@Riverpod(keepAlive: true)
ISettingsRepository settingsRepository(Ref ref) => getIt<ISettingsRepository>();
