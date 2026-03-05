#!/usr/bin/env bash
set -euo pipefail

script_directory=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
repository_root=$(cd "$script_directory/../.." && pwd)
cd "$repository_root"

if ! command -v pre-commit >/dev/null 2>&1; then
  echo "pre-commit is not installed. Install it and retry."
  echo "Install with: pipx install pre-commit or brew install pre-commit"
  exit 1
fi

echo "Running pre-commit checks..."
pre-commit run --all-files

echo "Running required builds/tests..."
bash "$repository_root/ci_scripts/tasks/run_required_builds.sh"
