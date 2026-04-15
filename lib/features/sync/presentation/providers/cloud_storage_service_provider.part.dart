part of 'sync_provider.dart';

@Riverpod(keepAlive: true)
ICloudStorageService cloudStorageService(Ref ref) => getIt<ICloudStorageService>();
