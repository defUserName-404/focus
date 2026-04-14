#!/bin/bash

set -euo pipefail

BASE_BRANCH="${1:-main}"

if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "Error: not inside a git repository"
  exit 1
fi

CURRENT_BRANCH="$(git rev-parse --abbrev-ref HEAD)"

echo "Commit Optimizer"
echo "Current branch: $CURRENT_BRANCH"
echo "Base branch: $BASE_BRANCH"

if git show-ref --verify --quiet "refs/heads/$BASE_BRANCH"; then
  echo
  echo "Commits ahead of $BASE_BRANCH:"
  git --no-pager log --oneline "$BASE_BRANCH"..HEAD || true
fi

echo
STAGED_FILES="$(git diff --cached --name-only)"
UNSTAGED_FILES="$(git diff --name-only)"

if [[ -z "$STAGED_FILES" && -z "$UNSTAGED_FILES" ]]; then
  echo "No working tree changes detected."
  exit 0
fi

if [[ -n "$STAGED_FILES" ]]; then
  echo "Staged files:"
  echo "$STAGED_FILES" | sed 's/^/  - /'
fi

if [[ -n "$UNSTAGED_FILES" ]]; then
  echo
  echo "Unstaged files:"
  echo "$UNSTAGED_FILES" | sed 's/^/  - /'
fi

ALL_FILES="$(printf "%s\n%s\n" "$STAGED_FILES" "$UNSTAGED_FILES" | sed '/^$/d' | sort -u)"

echo
echo "Suggested atomic groups (by path cluster):"
echo "$ALL_FILES" | awk -F/ '{
  if (NF >= 2) {
    print $1"/"$2;
  } else {
    print $1;
  }
}' | sort | uniq -c | sed 's/^/  - /'

echo
echo "Recommended flow:"
echo "  1) Stage one logical group"
echo "  2) Commit with conventional commit title"
echo "  3) Repeat for next group"
