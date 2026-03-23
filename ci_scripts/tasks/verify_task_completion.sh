#!/usr/bin/env bash
set -euo pipefail

script_directory=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
source "$script_directory/../lib/task_utils.sh"

ci_task_require_no_arguments "$@"
ci_task_enter_repository "${BASH_SOURCE[0]}"
repository_root=$CI_TASK_REPOSITORY_ROOT

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
