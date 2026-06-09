#!/usr/bin/env bash
set -euo pipefail

script_directory=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
source "$script_directory/../lib/task_utils.sh"

usage() {
  cat <<'EOF' >&2
Usage: bash ci_scripts/tasks/check_environment.sh --profile <swiftlint|rules>
EOF
}

argument_count=$#
if [[ $argument_count -ne 2 || "${1:-}" != "--profile" ]]; then
  usage
  exit 2
fi

profile=$2
case "$profile" in
  swiftlint | rules)
    ;;
  *)
    usage
    exit 2
    ;;
esac

ci_task_enter_repository "${BASH_SOURCE[0]}"
repository_root=$CI_TASK_REPOSITORY_ROOT

failures=()
next_steps=()

record_failure() {
  failures+=("$1")
}

record_next_step() {
  local message=$1
  local existing_message

  if [[ ${#next_steps[@]} -gt 0 ]]; then
    for existing_message in "${next_steps[@]}"; do
      if [[ "$existing_message" == "$message" ]]; then
        return 0
      fi
    done
  fi

  next_steps+=("$message")
}

ensure_command() {
  local command_name=$1
  local install_hint=$2

  if command -v "$command_name" >/dev/null 2>&1; then
    return 0
  fi

  record_failure "Missing command: $command_name"
  record_next_step "$install_hint"
}

check_swiftlint_environment() {
  local project_file="Incomes.xcodeproj/project.pbxproj"

  ensure_command "xcodebuild" "Install Xcode and ensure xcodebuild is available from the command line."

  if [[ ! -f "$project_file" ]]; then
    record_failure "Missing file: $project_file"
    record_next_step "Restore $project_file so the repository-managed SwiftLint package can be resolved."
    return 0
  fi

  if ! grep -q --fixed-strings "https://github.com/SimplyDanny/SwiftLintPlugins" "$project_file"; then
    record_failure "Incomes.xcodeproj is missing the SwiftLintPlugins package dependency."
    record_next_step "Add https://github.com/SimplyDanny/SwiftLintPlugins to Incomes.xcodeproj."
  fi
}

check_rules_environment() {
  check_swiftlint_environment
  ensure_command "rg" "Install ripgrep so repository rule checks can scan source files."
}

case "$profile" in
  swiftlint)
    check_swiftlint_environment
    ;;
  rules)
    check_rules_environment
    ;;
esac

if [[ ${#failures[@]} -ne 0 ]]; then
  echo "Environment check failed for profile '$profile'." >&2
  echo "Missing prerequisites:" >&2

  for failure in "${failures[@]}"; do
    printf -- '- %s\n' "$failure" >&2
  done

  if [[ ${#next_steps[@]} -ne 0 ]]; then
    echo "Next actions:" >&2
    for next_step in "${next_steps[@]}"; do
      printf -- '- %s\n' "$next_step" >&2
    done
  fi

  exit 1
fi

echo "Environment check passed for profile '$profile'."
