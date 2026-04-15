part of 'focus_providers.dart';

@Riverpod(keepAlive: true)
FocusMediaSessionCoordinator? focusMediaSessionCoordinator(Ref ref) {
  if (!PlatformUtils.supportsMediaSession) return null;
  return getIt<FocusMediaSessionCoordinator>();
}
