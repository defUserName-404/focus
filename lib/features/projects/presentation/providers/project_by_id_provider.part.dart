part of 'project_provider.dart';

@Riverpod(keepAlive: true)
Stream<Project?> projectById(Ref ref, String id) {
  final repository = ref.watch(projectRepositoryProvider);
  return repository.watchProjectById(int.parse(id));
}
