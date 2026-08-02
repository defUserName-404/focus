# Focus Commands Reference

This file documents command workflows for coding agents.

## Quick Reference

| Task | Command |
|------|---------|
| Install deps | `flutter pub get` |
| Run app | `flutter run` |
| Analyze | `flutter analyze` |
| Format | `dart format . --line-length=120` |
| Run tests | `flutter test` |
| Codegen | `dart run build_runner build --delete-conflicting-outputs` |
| Optimize commit groups | `bash .agents/commands/commit_optimizer.command main` |
| Write conventional commit | `bash .agents/commands/git_commit_writer.command <type> <scope> "<summary>" "<why>"` |
| Create PR via gh | `bash .agents/commands/pr_description_generator.command main "<labels>" "<title>"` |

## Daily Development Loop

```bash
flutter pub get
flutter analyze
dart format . --line-length=120
flutter run
```

## Code Generation

Run after changing Riverpod annotations, Drift schema/queries, or files with `part '*.g.dart'`:

```bash
dart run build_runner build --delete-conflicting-outputs
```

Watch mode during active provider/schema work:

```bash
dart run build_runner watch --delete-conflicting-outputs
```

### Analyzer / codegen version pins

On Flutter 3.44.x, `flutter_test` pins `test_api 0.7.11`. The only `test` release on that `test_api` requires `analyzer < 13`, and `riverpod` declares `test` as a runtime dependency, so analyzer 13 cannot enter the solve. Keep these caps in `pubspec.yaml` until upstream relaxes that:

- `riverpod_annotation: 4.0.3`
- `riverpod_generator: '>=4.0.4 <4.0.6'`
- `drift_dev: '>=2.34.0 <2.34.1'`
- `dart_mappable_builder: '>=4.8.0 <4.9.0'`
- `build_runner: '>=2.15.0 <2.15.2'`

Prefer `fvm flutter` / `fvm dart` so the local FVM pin (see `.fvmrc`) is used.

## Validation Workflow (Recommended)

```bash
dart format . --line-length=120
flutter analyze
flutter test
```

If generation is involved:

```bash
dart run build_runner build --delete-conflicting-outputs
flutter analyze
```

## Build Commands

Android release APK (split ABI):

```bash
flutter build apk --release --split-per-abi
```

iOS release (unsigned local build):

```bash
flutter build ios --release --no-codesign
```

Desktop builds:

```bash
flutter build macos --release
flutter build linux --release
flutter build windows --release
```

## Command Scripts in `.agents/commands`

- `new_feature.command`: scaffolds a Focus feature module with clean architecture folders and starter files.
- `review.command`: runs formatting, analysis, targeted static checks.
- `regression_test.command`: runs broader validation sequence for feature-level changes.
- `commit_optimizer.command`: inspects changes and suggests atomic commit grouping.
- `git_commit_writer.command`: commits staged files using Conventional Commit title + structured body.
- `pr_description_generator.command`: generates PR body from branch diff and runs `gh pr create` with assignee/label/title.

Run from repo root:

```bash
bash .agents/commands/new_feature.command my_feature
bash .agents/commands/review.command
bash .agents/commands/regression_test.command
bash .agents/commands/commit_optimizer.command main
bash .agents/commands/git_commit_writer.command feat tasks "add recurring reminders" "support deadline reminders"
bash .agents/commands/pr_description_generator.command main "feature,tasks" "feat(tasks): add recurring reminders"
```

## Core Git Workflow (Mandatory After Each Task)

Run this sequence for each coherent group of changes:

1. Inspect and optimize grouping:

```bash
bash .agents/commands/commit_optimizer.command main
```

2. Stage one logical group and commit with Conventional Commit title:

```bash
git add <files>
bash .agents/commands/git_commit_writer.command <type> <scope> "<summary>" "<why>"
```

3. Push to remote
```
git push -u origin feature
```

4. Create PR with assignee, labels, title, and generated description:

```bash
bash .agents/commands/pr_description_generator.command main "<labels>" "<title>"
```

For stacked phase work, pass the previous phase branch as the first argument (PR base), not `main`:

```bash
bash .agents/commands/pr_description_generator.command feat/phase-4-board-calendar "enhancement" "feat(home): Phase 5 dashboard refinement"
```

The PR command uses:
- `--base` (first script argument; defaults to `main`)
- `--assignee @me`
- `--label`
- `--title`
- `--body-file` (description)

Use multiple labels as comma-separated values, for example: `"docs,agent-workflow"`.

## Stacked Phase PRs

When a feature is split into ordered phase branches (each cut from the previous tip):

1. Open each PR with `--base` set to the previous phase branch so the review diff is phase-only.
2. Merge strictly bottom-up into `main` (earliest phase first). After each merge, retarget the next open PR to `main` (`gh pr edit <n> --base main`) before merging it.
3. Prefer merge commits (`gh pr merge <n> --merge`) while the stack is open so later branches keep shared ancestry. Avoid landing a later phase before its predecessor.
4. Do not open later phases from stale `main`; branch from the current phase tip.

Example merge order: Phase -1 → 0 → U → 1 → 2 → 3 → 4 → … → main.

## Troubleshooting

Common provider generation error:

```text
The getter '<name>Provider' isn't defined
```

Fix:

```bash
dart run build_runner build --delete-conflicting-outputs
```

Formatting check only:

```bash
dart format . --line-length=120 --set-exit-if-changed
```

Clean rebuild:

```bash
flutter clean
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter analyze
```

## Documentation Update Reminder

If commands, build flow, or CI process changes, update:

- `AGENTS.md`
- `.agents/docs/commands.md`
- Any affected scripts in `.agents/commands/`
