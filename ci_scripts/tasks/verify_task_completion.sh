#!/usr/bin/env bash
set -euo pipefail

argument_count=$#
if [[ $argument_count -ne 0 ]]; then
  echo "This script does not accept arguments." >&2
  exit 2
fi

script_directory=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
repository_root=$(cd "$script_directory/../.." && pwd)
cd "$repository_root"

if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "This script must run inside a git repository." >&2
  exit 1
fi

before_worktree_state=$(git status --short --untracked-files=all)

if [[ "${CI_RUN_FORCE_FULL:-0}" == "1" || "${CI_RUN_FORCE_FULL:-}" == "true" ]]; then
  echo "Running verify pipeline (environment + lint + full required builds/tests)..."
else
  echo "Running verify pipeline (environment + lint + required builds/tests)..."
fi

bash "$repository_root/ci_scripts/tasks/check_environment.sh" --profile verify
CI_SKIP_ENV_CHECK=1 bash "$repository_root/ci_scripts/tasks/lint_swift.sh"
CI_SKIP_ENV_CHECK=1 bash "$repository_root/ci_scripts/tasks/verify_repository_state.sh"

after_worktree_state=$(git status --short --untracked-files=all)

if [[ "$before_worktree_state" != "$after_worktree_state" ]]; then
  echo "verify_task_completion.sh must be non-destructive, but the working tree state changed." >&2
  echo "Before verify:" >&2
  if [[ -n "$before_worktree_state" ]]; then
    printf '%s\n' "$before_worktree_state" >&2
  else
    echo "(clean)" >&2
  fi
  echo "After verify:" >&2
  if [[ -n "$after_worktree_state" ]]; then
    printf '%s\n' "$after_worktree_state" >&2
  else
    echo "(clean)" >&2
  fi
  exit 1
fi
