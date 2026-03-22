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

if [[ "${CI_RUN_FORCE_FULL:-0}" == "1" || "${CI_RUN_FORCE_FULL:-}" == "true" ]]; then
  echo "Running verify pipeline (pre-commit + full required builds/tests)..."
else
  echo "Running verify pipeline (pre-commit + required builds/tests)..."
fi
CI_RUN_ENABLE_PRE_COMMIT=1 bash "$repository_root/ci_scripts/tasks/run_required_builds.sh"
