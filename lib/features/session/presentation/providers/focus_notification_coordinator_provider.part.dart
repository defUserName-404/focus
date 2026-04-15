part of 'focus_providers.dart';

@Riverpod(keepAlive: true)
FocusNotificationCoordinator? focusNotificationCoordinator(Ref ref) {
  if (!PlatformUtils.supportsLocalNotifications) return null;
  return getIt<FocusNotificationCoordinator>();
}
