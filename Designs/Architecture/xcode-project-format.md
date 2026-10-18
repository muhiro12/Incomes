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

Bundle-level references in shared schemes, SwiftLint resolution, and Xcode Cloud
continue to address `Incomes.xcodeproj`. No new CI workflow is needed.
The Xcode Cloud manifest, shared schemes, entitlements, and package resolution
must remain unchanged by conversion.

The optional `.periphery.yml` also addresses the bundle and selects the Incomes
scheme. Its obsolete `targets` option, including the absent `IncomesTests`
target, was removed. Periphery's supported `schemes` option selects the built
targets; the Incomes scheme includes the Watch and Widgets dependencies. Existing
index exclusions are preserved. The YAML keys and selected scheme were checked
against the upstream configuration definition and the actual Xcode project.
Periphery itself was not installed for this qualification, so its scan and
external parser compatibility remain unqualified. It is not part of the
documented repository-rule entrypoint.

The repository adapter normalizes both formats with Apple's `plutil` before
using Python's strict JSON reader. Probes confirmed the actual converter output,
comments, trailing commas, escaped strings, and URL preservation in the selected
environment. Missing, malformed, ambiguous, or mismatched configurations fail
verification. No Python parsing dependency, Swift compiler invocation, global
module-cache write, or project generator is needed.

Package checks resolve declared products and their actual Frameworks links to
the canonical package in both formats. A same-named product from another
package or a declaration without a link cannot satisfy the Incomes dependency.
Legacy package and target references are followed from the project root;
unattached objects cannot satisfy dependency checks. Watch and Widgets cannot
bypass the umbrella boundary through a direct framework reference.

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

Formal archive and Xcode Cloud execution are deferred release qualification and
do not block the local project-format migration. A local build or
archive-configuration inspection does not prove a successful cloud archive,
upload, or distribution. Any later cloud check requires an authorized candidate.

## Local qualification on October 18, 2026

The source baseline was `8a2ebce7`. Commit `63c5b1b2` adds the compatibility
adapters; `ef81ac3c` contains only the project-format conversion. Reverting
`ef81ac3c` restores the original configuration. A reverse-patch dry run passed.

The selected local toolchains were Xcode 27.2 (`27B5038j`) and Xcode 27.1
(`27A9275`). Xcode 27 is Apple's documented compatibility floor; Xcode 27.0 was
not installed for this run, so the directly verified floor is Xcode 27.1.

- Native inspection compared 21 before/after views covering targets, package
  requirements and product owners, folder references, all build phases and
  their source/resource/framework memberships, embedding destinations, and
  project/target settings in both Debug and Release. Navigator object IDs and
  framework/product listing order were normalized within their owners. These
  comparisons establish matching configuration values and memberships, with
  build-phase order preserved. They do not establish identical framework input
  order; the converter's ordering changes are recorded below.
- The Xcode-native settings integration reported identical values for all
  1,712 settings across Incomes, Widgets, and Watch at the original destination.
- Shared schemes and the Xcode Cloud manifest are byte-identical to their
  pre-conversion versions. App source, entitlements, deployment targets,
  persistence code, and tracked package resolution were not changed.
- Xcode 27.2 built Incomes, Widgets, and Watch successfully. The IncomesLibrary
  test plan passed all 1,609 tests, with zero failures, skips, or unrun tests.
- All 45 verification-adapter tests passed, including legacy compatibility,
  JSON5 parsing, configuration ambiguity, invalid package boundaries, and
  source-commit hash binding. The complete repository-rule check passed before
  and after conversion, including SwiftLint 0.65.1 over 890 tracked Swift files.
- Xcode 27.1 discovered all four schemes, three product targets, and both build
  configurations from the converted project with package updates disabled. An
  Incomes Simulator build, including its Watch and Widgets dependencies,
  succeeded with signing disabled for compilation only. The JSON5 verification
  adapter also passed under this toolchain.
- Both toolchains evaluated the Incomes archive configuration as Release for
  their iOS device SDKs, with `SKIP_INSTALL=NO` and the original entitlements
  path. This inspects archive settings without creating or signing an archive.

The separate Xcode 27.1 build initially stopped before compilation because the
existing LicenseList plugin expects a `SourcePackages` directory beside its
build tree. A build-local link to the same resolved package cache restored that
layout; no package source or project configuration was changed to fix it.

An additional native round trip confirmed these Frameworks input-order changes:

- Incomes: `MHPlatform, IncomesLibrary, MHDesign` became
  `IncomesLibrary, MHDesign, MHPlatform`.
- Widgets: `SwiftUI, IncomesLibrary, MHDesign, WidgetKit` became
  `IncomesLibrary, MHDesign, SwiftUI, WidgetKit`.
- Watch: `IncomesLibrary, MHPreferences, MHPreferencesUI, MHDesign` became
  `IncomesLibrary, MHDesign, MHPreferences, MHPreferencesUI`.

Apple's schema encoder also sorts package-product declarations. The membership
comparison therefore must not be interpreted as proof of original linker input
order. The converter output is retained, and the successful builds and library
tests above are the observed application evidence for that configuration.

Subsequent checker refinement separately covers missing Frameworks edges,
incorrect product owners, unattached legacy objects, and adapter framework
bypasses. Both the original legacy configuration and the converted JSON pass
the strengthened checks. The earlier failed `plutil` probe did not establish
format incompatibility: rereading the unchanged JSON succeeded. Replacing the
Swift-based reader also removes its reproducible global compiler-cache access
failure during ordinary restricted execution.
All 51 tooling tests and the full repository-rule entrypoint passed in that
restricted context, including SwiftLint over the same 890 tracked Swift files.

The original Xcode scheme and destination were restored. The Incomes-specific
configuration work and local qualification are complete. Formal signed archive
and Xcode Cloud execution are deferred, and the release-toolchain choice is
unchanged. Issue #400 remains open while the implementation is unpublished;
the deferred release checks are not a current completion gate.

The earlier app build and library-test results are migration-run observations,
not a publication receipt for subsequent tooling commits. Prepare current-source
evidence through the [push verification pilot](push-verification-pilot.md) before
any separately authorized push. Shared verification-skill modernization remains
separate; Incomes currently uses its repository-owned evidence adapter and
matcher, while other adopters may delegate to the shared helpers.

## References

- [Apple project-format conversion and compatibility](https://developer.apple.com/documentation/xcode/updating-your-xcode-project-configuration-file-format)
- [Apple project-format library](https://github.com/apple/xcode-project-format)
- [Apple package-product encoding](https://github.com/apple/xcode-project-format/blob/main/Sources/Library/Schema/Target/Target.swift)
- [Periphery configuration definition](https://github.com/peripheryapp/periphery/blob/master/Sources/Configuration/Configuration.swift)
- [Periphery scheme selection](https://github.com/peripheryapp/periphery/blob/master/Sources/Frontend/Commands/ScanCommand.swift)
