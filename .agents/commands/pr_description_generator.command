#!/bin/bash

set -euo pipefail

BASE_BRANCH="${1:-main}"
LABELS="${2:-documentation}"
TITLE="${3:-}"

if ! command -v gh >/dev/null 2>&1; then
  echo "Error: gh CLI is not installed"
  exit 1
fi

CURRENT_BRANCH="$(git rev-parse --abbrev-ref HEAD)"

if [[ "$CURRENT_BRANCH" == "$BASE_BRANCH" ]]; then
  echo "Error: current branch is base branch ($BASE_BRANCH). Create a feature branch first."
  exit 1
fi

if [[ -z "$(git log --oneline "$BASE_BRANCH"..HEAD 2>/dev/null || true)" ]]; then
  echo "Error: no commits ahead of $BASE_BRANCH"
  exit 1
fi

if [[ -z "$TITLE" ]]; then
  TITLE="$(git log -1 --pretty=%s)"
fi

COMMITS="$(git --no-pager log --oneline "$BASE_BRANCH"..HEAD)"
CHANGED_FILES="$(git diff --name-only "$BASE_BRANCH"...HEAD)"
DIFFSTAT="$(git diff --stat "$BASE_BRANCH"...HEAD)"

BODY_FILE="$(mktemp -t focus_pr_body.XXXXXX.md)"

cat > "$BODY_FILE" << EOF
## Summary
- This PR groups related changes from branch \\`$CURRENT_BRANCH\\` into an atomic review unit.

## Why
- Improve maintainability and review quality through focused, conventional changes.

## What Changed
### Commits
$COMMITS

### Files
$(echo "$CHANGED_FILES" | sed 's/^/- /')

### Diffstat
\
$DIFFSTAT
\

## Testing
- [ ] flutter analyze
- [ ] dart format . --line-length=120
- [ ] flutter test
- [ ] Manual smoke test for changed flows

## Reviewer Notes
- Changes were grouped atomically by intent.
- Conventional commit titles were used for semantic versioning.
EOF

if [[ "${GH_PR_DRY_RUN:-0}" == "1" ]]; then
  echo "DRY RUN"
  echo "gh pr create --assignee @me --label \"$LABELS\" --title \"$TITLE\" --body-file \"$BODY_FILE\""
  echo
  cat "$BODY_FILE"
  exit 0
fi

gh pr create --assignee @me --label "$LABELS" --title "$TITLE" --body-file "$BODY_FILE"

echo "PR created with title: $TITLE"
echo "Description file: $BODY_FILE"
