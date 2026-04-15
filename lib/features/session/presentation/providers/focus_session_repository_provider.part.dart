part of 'focus_providers.dart';

@Riverpod(keepAlive: true)
IFocusSessionRepository focusSessionRepository(Ref ref) => getIt<IFocusSessionRepository>();
