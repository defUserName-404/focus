// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'navigation_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Manages the bottom navigation bar state.
///
/// Keeps the selected tab index and exposes methods to switch tabs
/// programmatically from anywhere in the widget tree.

@ProviderFor(BottomNavIndex)
final bottomNavIndexProvider = BottomNavIndexProvider._();

/// Manages the bottom navigation bar state.
///
/// Keeps the selected tab index and exposes methods to switch tabs
/// programmatically from anywhere in the widget tree.
final class BottomNavIndexProvider extends $NotifierProvider<BottomNavIndex, int> {
  /// Manages the bottom navigation bar state.
  ///
  /// Keeps the selected tab index and exposes methods to switch tabs
  /// programmatically from anywhere in the widget tree.
  BottomNavIndexProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'bottomNavIndexProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$bottomNavIndexHash();

  @$internal
  @override
  BottomNavIndex create() => BottomNavIndex();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(int value) {
    return $ProviderOverride(origin: this, providerOverride: $SyncValueProvider<int>(value));
  }
}

String _$bottomNavIndexHash() => r'55948bcdc2cb419a4de2260e1a3315b4b9e8120c';

/// Manages the bottom navigation bar state.
///
/// Keeps the selected tab index and exposes methods to switch tabs
/// programmatically from anywhere in the widget tree.

abstract class _$BottomNavIndex extends $Notifier<int> {
  int build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<int, int>;
    final element = ref.element as $ClassProviderElement<AnyNotifier<int, int>, int, Object?, Object?>;
    element.handleCreate(ref, build);
  }
}
