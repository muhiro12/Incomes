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
expected_mhplatform_revision="083817e803431d33825a5878593d63e399053ed9"
package_manifest="IncomesLibrary/Package.swift"
package_resolved="IncomesLibrary/Package.resolved"
project_file="Incomes.xcodeproj/project.pbxproj"

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

if rg -q '\.package\(\s*path:\s*"[^"]*MHPlatform' "$package_manifest"; then
  record_failure "IncomesLibrary/Package.swift must not use a local path dependency for MHPlatform."
fi

if ! rg -q --fixed-strings "url: \"$expected_mhplatform_remote\"" "$package_manifest"; then
  record_failure "IncomesLibrary/Package.swift must reference the canonical MHPlatform remote."
fi

if ! rg -q --fixed-strings "revision: \"$expected_mhplatform_revision\"" "$package_manifest"; then
  record_failure "IncomesLibrary/Package.swift must pin MHPlatform to revision $expected_mhplatform_revision."
fi

if rg -q -U 'url:\s*"https://github.com/muhiro12/MHPlatform\.git"[\s\S]*branch:\s*"' "$package_manifest"; then
  record_failure "IncomesLibrary/Package.swift must not track an MHPlatform branch."
fi

if rg -q 'name:\s*"MHPlatform"' "$package_manifest"; then
  record_failure "IncomesLibrary must not depend on the umbrella MHPlatform product."
fi

if ! rg -q --fixed-strings "\"location\" : \"$expected_mhplatform_remote\"" "$package_resolved"; then
  record_failure "IncomesLibrary/Package.resolved must resolve MHPlatform from the canonical remote."
fi

if ! rg -q --fixed-strings "\"revision\" : \"$expected_mhplatform_revision\"" "$package_resolved"; then
  record_failure "IncomesLibrary/Package.resolved must resolve MHPlatform at revision $expected_mhplatform_revision."
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

  if ! grep -q --fixed-strings 'kind = revision;' <<<"$mhplatform_reference_block"; then
    record_failure "Incomes.xcodeproj must pin MHPlatform by revision."
  fi

  if ! grep -q --fixed-strings "revision = $expected_mhplatform_revision;" <<<"$mhplatform_reference_block"; then
    record_failure "Incomes.xcodeproj must pin MHPlatform to revision $expected_mhplatform_revision."
  fi

  if grep -q --fixed-strings 'kind = branch;' <<<"$mhplatform_reference_block" || \
    grep -q --fixed-strings 'branch = ' <<<"$mhplatform_reference_block"; then
    record_failure "Incomes.xcodeproj must not track an MHPlatform branch."
  fi
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

if [[ ${#failures[@]} -ne 0 ]]; then
  echo "MHPlatform boundary check failed." >&2

  for failure in "${failures[@]}"; do
    printf -- '- %s\n' "$failure" >&2
  done

  exit 1
fi

echo "MHPlatform boundary check passed."
