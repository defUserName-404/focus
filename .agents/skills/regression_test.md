# Regression Test Skill (Focus)

Use this skill after substantial changes to reduce release risk.

## When To Use

- Cross-feature refactors
- Routing/DI/database changes
- Notification/session behavior changes
- Any change that affects persisted user data or restart behavior

## Workflow

1. Install/update dependencies.
2. Regenerate code for Riverpod/Drift.
3. Verify formatting.
4. Run static analysis.
5. Run tests if available.
6. Run optional debug build for platform sanity.

## Command

```bash
bash .agents/commands/regression_test.command
```

Optional build step:

```bash
FOCUS_RUN_BUILD=1 bash .agents/commands/regression_test.command
```

## Manual Smoke Suggestions

- Launch app and verify shell navigation routes.
- Verify create/edit/delete in affected feature areas.
- Verify reminders/notifications for changed scheduling code.
- Restart app and verify persisted state (settings/view mode/filter state).

## Exit Criteria

- No analyzer errors
- No formatting diff
- Code generation up to date
- Manual smoke checks completed for changed flows

## Mandatory Post-Task Git Workflow

After a user task has passed regression validation, run:

1. `bash .agents/commands/commit_optimizer.command main`
2. `bash .agents/commands/git_commit_writer.command <type> <scope> "<summary>" "<why>"`
3. `bash .agents/commands/pr_description_generator.command main "<labels>" "<title>"`
