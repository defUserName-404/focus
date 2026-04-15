part of 'sync_provider.dart';

@Riverpod(keepAlive: true)
SyncEngine syncEngine(Ref ref) => getIt<SyncEngine>();
