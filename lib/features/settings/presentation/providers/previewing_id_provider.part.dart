part of 'settings_provider.dart';

@riverpod
class PreviewingIdNotifier extends _$PreviewingIdNotifier {
  @override
  String? build() => null;

  void set(String? id) => state = id;
}
