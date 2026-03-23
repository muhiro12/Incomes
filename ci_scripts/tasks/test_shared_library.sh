#!/usr/bin/env bash
set -euo pipefail

script_directory=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
source "$script_directory/../lib/task_utils.sh"
source "$script_directory/../lib/xcodebuild.sh"

ci_task_require_no_arguments "$@"
ci_task_enter_repository "${BASH_SOURCE[0]}"
repository_root=$CI_TASK_REPOSITORY_ROOT

ci_xcodebuild_run "$repository_root" "IncomesLibrary" test "TestResults_IncomesLibrary"
echo "Finished IncomesLibrary tests. Result bundle: $CI_XCODEBUILD_LAST_RESULT_BUNDLE_PATH"
