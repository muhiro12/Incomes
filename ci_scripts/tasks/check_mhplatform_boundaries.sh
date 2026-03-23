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

expected_mhplatform_remote="https://github.com/muhiro12/MHPlatform.git"
expected_mhplatform_minimum_version="1.0.0"
package_manifest="IncomesLibrary/Package.swift"
package_resolved="IncomesLibrary/Package.resolved"
project_file="Incomes.xcodeproj/project.pbxproj"
core_safe_modules=(
  MHDeepLinking
  MHLogging
  MHNotificationPayloads
  MHNotificationPlans
  MHRouteExecution
  MHPersistenceMaintenance
  MHPreferences
)

failures=()

record_failure() {
  failures+=("$1")
}

extract_project_block() {
  local block_name=$1

  awk -v block_name="$block_name" '
    index($0, "/* " block_name " */ = {") && $0 ~ /\{$/ { capture = 1 }
    capture { print }
    capture && $0 == "\t\t};" { exit }
  ' "$project_file"
}

extract_manifest_dependency_block() {
  local remote_url=$1

  awk -v remote_url="$remote_url" '
    index($0, "url: \"" remote_url "\"") { capture = 1 }
    capture { print }
    capture && $0 ~ /^[[:space:]]*\),?$/ { exit }
  ' "$package_manifest"
}

extract_resolved_pin_block() {
  local remote_url=$1

  awk -v remote_url="$remote_url" '
    index($0, "\"location\" : \"" remote_url "\"") { capture = 1 }
    capture { print }
    capture && $0 ~ /^    },?$/ { exit }
  ' "$package_resolved"
}

if rg -q '\.package\(\s*path:\s*"[^"]*MHPlatform' "$package_manifest"; then
  record_failure "IncomesLibrary/Package.swift must not use a local path dependency for MHPlatform."
fi

mhplatform_manifest_block=$(extract_manifest_dependency_block "$expected_mhplatform_remote")
if [[ -z "$mhplatform_manifest_block" ]]; then
  record_failure "IncomesLibrary/Package.swift must reference the canonical MHPlatform remote."
else
  if ! grep -q --fixed-strings "\"1.0.0\"..<\"2.0.0\"" <<<"$mhplatform_manifest_block"; then
    record_failure "IncomesLibrary/Package.swift must declare the MHPlatform 1.x semver range 1.0.0..<2.0.0."
  fi

  if grep -q --fixed-strings 'branch:' <<<"$mhplatform_manifest_block"; then
    record_failure "IncomesLibrary/Package.swift must not track an MHPlatform branch."
  fi

  if grep -q --fixed-strings 'revision:' <<<"$mhplatform_manifest_block"; then
    record_failure "IncomesLibrary/Package.swift must not pin MHPlatform by exact revision."
  fi
fi

if rg -q 'name:\s*"MHPlatform"' "$package_manifest"; then
  record_failure "IncomesLibrary must not depend on the umbrella MHPlatform product."
fi

if ! rg -q 'name:\s*"MHPlatformCore"' "$package_manifest"; then
  record_failure "IncomesLibrary must depend on the MHPlatformCore product."
fi

for module_name in "${core_safe_modules[@]}"; do
  if rg -q "name:\\s*\"$module_name\"" "$package_manifest"; then
    record_failure "IncomesLibrary must not declare direct MHPlatform core-safe module dependency $module_name."
  fi
done

mhplatform_resolved_block=$(extract_resolved_pin_block "$expected_mhplatform_remote")
if [[ -z "$mhplatform_resolved_block" ]]; then
  record_failure "IncomesLibrary/Package.resolved must resolve MHPlatform from the canonical remote."
else
  if ! grep -Eq '"version" : "1\.[^"]+"' <<<"$mhplatform_resolved_block"; then
    record_failure "IncomesLibrary/Package.resolved must resolve MHPlatform to a tagged 1.x release."
  fi
fi

if rg -q --fixed-strings 'XCLocalSwiftPackageReference "MHPlatform"' "$project_file"; then
  record_failure "Incomes.xcodeproj must not use a local MHPlatform package reference."
fi

mhplatform_reference_block=$(extract_project_block 'XCRemoteSwiftPackageReference "MHPlatform"')
if [[ -z "$mhplatform_reference_block" ]]; then
  record_failure "Incomes.xcodeproj must define an MHPlatform remote package reference."
else
  if ! grep -q --fixed-strings "repositoryURL = \"$expected_mhplatform_remote\";" <<<"$mhplatform_reference_block"; then
    record_failure "Incomes.xcodeproj must reference the canonical MHPlatform remote."
  fi

  if ! grep -q --fixed-strings 'kind = upToNextMajorVersion;' <<<"$mhplatform_reference_block"; then
    record_failure "Incomes.xcodeproj must use an MHPlatform 1.x semver requirement."
  fi

  if ! grep -q --fixed-strings "minimumVersion = $expected_mhplatform_minimum_version;" <<<"$mhplatform_reference_block"; then
    record_failure "Incomes.xcodeproj must set the MHPlatform minimum version to $expected_mhplatform_minimum_version."
  fi

  if grep -q --fixed-strings 'kind = branch;' <<<"$mhplatform_reference_block" || \
    grep -q --fixed-strings 'branch = ' <<<"$mhplatform_reference_block" || \
    grep -q --fixed-strings 'kind = revision;' <<<"$mhplatform_reference_block" || \
    grep -q --fixed-strings 'revision = ' <<<"$mhplatform_reference_block"; then
    record_failure "Incomes.xcodeproj must not track MHPlatform by branch or exact revision."
  fi
fi

incomes_target_block=$(extract_project_block 'Incomes')
if [[ -z "$incomes_target_block" ]] || ! grep -q --fixed-strings 'MHPlatform' <<<"$incomes_target_block"; then
  record_failure "Incomes must remain the MHPlatform umbrella adopter."
fi

for target_name in Watch Widgets IncomesTests; do
  target_block=$(extract_project_block "$target_name")
  if [[ -n "$target_block" ]] && grep -q --fixed-strings 'MHPlatform' <<<"$target_block"; then
    record_failure "$target_name must not depend on the umbrella MHPlatform product."
  fi
done

umbrella_import_matches=$(
  rg \
    --line-number \
    '^(@preconcurrency )?import MHPlatform$' \
    IncomesLibrary \
    Watch \
    Widgets \
    -g '*.swift' || true
)

if [[ -n "$umbrella_import_matches" ]]; then
  record_failure "Umbrella import MHPlatform is not allowed in IncomesLibrary, Watch, or Widgets:
$umbrella_import_matches"
fi

direct_core_module_imports=$(
  rg \
    --line-number \
    '^(@preconcurrency )?import (MHDeepLinking|MHLogging|MHNotificationPayloads|MHNotificationPlans|MHRouteExecution|MHPersistenceMaintenance|MHPreferences)$' \
    IncomesLibrary/Sources \
    -g '*.swift' || true
)

if [[ -n "$direct_core_module_imports" ]]; then
  record_failure "IncomesLibrary/Sources must import MHPlatformCore instead of direct core-safe MHPlatform modules:
$direct_core_module_imports"
fi

if [[ ${#failures[@]} -ne 0 ]]; then
  echo "MHPlatform boundary check failed." >&2

  for failure in "${failures[@]}"; do
    printf -- '- %s\n' "$failure" >&2
  done

  exit 1
fi

echo "MHPlatform boundary check passed."
