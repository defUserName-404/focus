part of 'settings_provider.dart';

@Riverpod(keepAlive: true)
AudioService audioService(Ref ref) => getIt<AudioService>();
