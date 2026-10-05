#!/usr/bin/env bash

CI_TASK_REPOSITORY_ROOT=""

ci_task_require_no_arguments() {
  if [[ $# -ne 0 ]]; then
    echo "This script does not accept arguments." >&2
    exit 2
  fi
}

ci_task_resolve_repository_root() {
  local source_path=$1
  local script_directory

  script_directory=$(cd "$(dirname "$source_path")" && pwd)
  cd "$script_directory/../.." && pwd
}

ci_task_enter_repository() {
  local source_path=$1
  CI_TASK_REPOSITORY_ROOT=$(ci_task_resolve_repository_root "$source_path")
  cd "$CI_TASK_REPOSITORY_ROOT"

  if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    echo "This script must run inside a git repository." >&2
    exit 1
  fi
}

ci_task_should_skip_environment_check() {
  [[ "${CI_SKIP_ENV_CHECK:-0}" == "1" || "${CI_SKIP_ENV_CHECK:-}" == "true" ]]
}

# Return captured matches for both rg's match and no-match statuses. Any search
# failure exits the caller (including a command substitution) as incomplete.
ci_task_rg() {
  local output
  local status
  if ! command -v rg >/dev/null 2>&1; then
    echo "Repository search incomplete: rg is missing from PATH." >&2
    exit 2
  fi
  if output=$(rg "$@"); then
    status=0
  else
    status=$?
  fi
  if [[ $status -gt 1 ]]; then
    echo "Repository search incomplete: rg exited $status." >&2
    exit 2
  fi
  printf '%s' "$output"
}
