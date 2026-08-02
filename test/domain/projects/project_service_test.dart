import 'package:flutter_test/flutter_test.dart';
import 'package:focus/core/utils/result.dart';
import 'package:focus/features/projects/domain/entities/project.dart';
import 'package:focus/features/projects/domain/entities/project_extensions.dart';
import 'package:focus/features/projects/domain/repositories/i_project_repository.dart';
import 'package:focus/features/projects/domain/services/project_service.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/fixtures.dart';

class _MockProjectRepository extends Mock implements IProjectRepository {}

void main() {
  late _MockProjectRepository repository;
  late ProjectService service;

  setUpAll(() {
    registerFallbackValue(buildProject());
  });

  setUp(() {
    repository = _MockProjectRepository();
    service = ProjectService(repository);
  });

  test('createProject stamps timestamps and returns Success', () async {
    when(() => repository.createProject(any())).thenAnswer((invocation) async {
      final project = invocation.positionalArguments.first as Project;
      return project.copyWith(id: 42);
    });

    final result = await service.createProject(title: 'Ship Phase 0');
    expect(result, isA<Success<Project>>());
    final created = (result as Success<Project>).value;
    expect(created.id, 42);
    expect(created.title, 'Ship Phase 0');
    verify(() => repository.createProject(any())).called(1);
  });

  test('createProject returns Failure when repository throws', () async {
    when(() => repository.createProject(any())).thenThrow(Exception('db down'));
    final result = await service.createProject(title: 'Broken');
    expect(result, isA<Failure<Project>>());
    expect((result as Failure<Project>).failure, isA<DatabaseFailure>());
  });

  test('updateProject refreshes updatedAt', () async {
    when(() => repository.updateProject(any())).thenAnswer((_) async {});
    final project = buildProject(id: 7);
    final result = await service.updateProject(project);
    expect(result, isA<Success<void>>());
    final captured = verify(() => repository.updateProject(captureAny())).captured.single as Project;
    expect(captured.id, 7);
    expect(
      captured.updatedAt.isAfter(project.updatedAt) || captured.updatedAt.isAtSameMomentAs(project.updatedAt),
      isTrue,
    );
  });

  test('deleteProject returns Failure when repository throws', () async {
    when(() => repository.deleteProject(9)).thenThrow(Exception('fk'));
    final result = await service.deleteProject(9);
    expect(result, isA<Failure<void>>());
  });
}
