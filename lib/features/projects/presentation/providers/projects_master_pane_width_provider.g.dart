// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'projects_master_pane_width_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ProjectsMasterPaneWidth)
final projectsMasterPaneWidthProvider = ProjectsMasterPaneWidthProvider._();

final class ProjectsMasterPaneWidthProvider extends $AsyncNotifierProvider<ProjectsMasterPaneWidth, double> {
  ProjectsMasterPaneWidthProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'projectsMasterPaneWidthProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$projectsMasterPaneWidthHash();

  @$internal
  @override
  ProjectsMasterPaneWidth create() => ProjectsMasterPaneWidth();
}

String _$projectsMasterPaneWidthHash() => r'accbc7fcd8aef964dafc7897ee81662fccce58b0';

abstract class _$ProjectsMasterPaneWidth extends $AsyncNotifier<double> {
  FutureOr<double> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<double>, double>;
    final element =
        ref.element
            as $ClassProviderElement<AnyNotifier<AsyncValue<double>, double>, AsyncValue<double>, Object?, Object?>;
    return element.handleCreate(ref, build);
  }
}
