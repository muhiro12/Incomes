# Xcode project configuration format

## Compatibility and scope

Incomes can migrate the configuration inside `Incomes.xcodeproj` from
`project.pbxproj` to `project.xcproj` without changing application code, deployment
targets, SDK requirements, or stored data. Apple documents reading both formats
in Xcode 27 and later; conversion to JSON requires Xcode 27.2 or later.

Keep the release-toolchain policy in [README.md](../../README.md#requirements).
Local conversion qualification does not qualify a beta toolchain for release.
The iPhone Duo SDK and Simulator qualification remain independent of this change.

## Direct dependency inventory

The pre-conversion audit for [Issue #400](https://github.com/muhiro12/Incomes/issues/400)
identified these dependencies on the legacy file or its property-list syntax:

| Consumer | Required adaptation |
| --- | --- |
| `ci_scripts/tasks/check_environment.sh` | Discover exactly one configuration and validate the SwiftLint package structurally. |
| `ci_scripts/lib/swiftlint_evidence.py` | Read the package requirement in either format and hash the actual configuration. |
| `ci_scripts/tasks/check_mhplatform_boundaries.sh` | Replace property-list text extraction with structural package and target checks. |
| `ci_scripts/tasks/check_push_verification.py` | Bind lint evidence to the single configuration in its source commit. |
| `ci_scripts/tests/test_rules_evidence.py` | Retain legacy coverage and add JSON provenance coverage. |
| `ci_scripts/tests/test_push_verification.py` | Retain historical receipts and test JSON configuration hashes. |
| `Designs/Overviews/incomes-architecture-conformance-audit.md` | Update current configuration references after conversion. |

Bundle-level references in shared schemes, Periphery, SwiftLint resolution, and
Xcode Cloud continue to address `Incomes.xcodeproj`. No new CI workflow is needed.
The Xcode Cloud manifest, shared schemes, entitlements, and package resolution
must remain unchanged by conversion.

The repository adapter uses Foundation's native JSON5 reader because Xcode's
JSON includes trailing commas. `plutil` remains the legacy-format reader. Missing,
malformed, or ambiguous configurations fail verification. No Python parsing
dependency or project generator is added.

## Conversion and rollback

Start from a clean working tree and retain the previous configuration in Git.
Review conversion in its own commit, after the compatibility adapters pass.
Use Xcode's Project Format control or the converter advertised by the selected
Xcode's `xcodebuild -help`:

```sh
xcodebuild -project Incomes.xcodeproj -convert-project 'Xcode Project'
```

Before committing, compare native target, phase, resource, package, configuration,
and build-setting views with the baseline. Build the app and companion surfaces,
run the shared-library tests, and check the Release archive configuration.

To roll back, revert the isolated conversion commit. This restores the previous
`project.pbxproj` and removes `project.xcproj` together. Keep the compatibility
adapter commit: it supports either format and rejects both being present.
Do not use reverse conversion as an exact restoration of the original file;
Xcode can regenerate internal object identifiers and normalize configuration.

Xcode Cloud must be checked on an authorized pushed candidate. A local build or
archive-configuration inspection does not prove a successful cloud archive,
upload, or distribution.

## References

- [Apple project-format conversion and compatibility](https://developer.apple.com/documentation/xcode/updating-your-xcode-project-configuration-file-format)
- [Apple project-format library](https://github.com/apple/xcode-project-format)
