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

echo "Running repository pre-commit checks..."
bash "$repository_root/ci_scripts/tasks/check_environment.sh" --profile format
CI_SKIP_ENV_CHECK=1 bash "$repository_root/ci_scripts/tasks/format_swift.sh"
CI_SKIP_ENV_CHECK=1 bash "$repository_root/ci_scripts/tasks/lint_swift.sh"
