part of 'activity_graph_providers.dart';

@riverpod
class TappedDateNotifier extends _$TappedDateNotifier {
  @override
  String? build() {
    return null;
  }

  void setDate(String? date) {
    state = date;
  }
}
