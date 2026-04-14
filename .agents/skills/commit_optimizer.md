# Commit Optimizer Skill (Focus)

Use this skill before committing to enforce atomic commit grouping.

## Objective

Ensure one logical change per commit and prevent large mixed commits.

## Inputs

- Working tree and staged status
- Changed file groups
- Recent commit history on current branch

## Workflow

1. Inspect changes (`git status --short`, `git diff --name-only`).
2. Identify logical groups by intent (for example docs policy update vs feature code change).
3. Stage one group at a time.
4. Validate each group is self-contained and reversible.
5. Create one conventional commit per group.
6. Repeat until all groups are committed.

## Grouping Rules

- Keep refactors separate from behavior changes.
- Keep generated files with their source change when required.
- Keep docs-only changes in a docs/chore commit.
- Avoid single mega commit containing unrelated tasks.

## Suggested Helper

```bash
bash .agents/commands/commit_optimizer.command main
```

## Output

- Suggested commit groups
- Suggested staging order
- Cleaner branch history for review and release tooling
