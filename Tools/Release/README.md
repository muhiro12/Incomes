# Incomes release tools

This macOS SwiftPM package uses Apogee's command plugin for the Incomes 6.x
release cycle. It pins Apogee **1.0** at
`ced812230149a1c2db7155e054a02af18c6d21c9`; commit `Package.resolved` with any
deliberate dependency update. No app target links Apogee.

The public Git tag is `1.0`. SwiftPM requires the normalized three-component
version `1.0.0` in `Package.swift` and records it in `Package.resolved`.
Check the resolved revision as well as the version when updating.

Use the selected Xcode 27 RC (27A266a), followed by stable Xcode 27, for both
development and release verification. Run these commands from the repository
root:

```sh
xcode-select -p
xcodebuild -version
swift --version
swift package --package-path Tools/Release resolve
swift package --package-path Tools/Release plugin \
  --allow-network-connections all apogee -- --help
```

The package has no app or wrapper executable. SwiftPM builds the pinned Apogee
command plugin and its executable when the plugin runs.

## Local metadata

Prepare release notes for the actual intended version in a private directory:

```text
<version>/
  en-US/release_notes.txt
  es-ES/release_notes.txt
  fr-FR/release_notes.txt
  ja/release_notes.txt
  zh-Hans/release_notes.txt
```

Use the locale identifiers present on the target App Store Connect version.
Xcode language identifiers such as `en`, `es`, and `fr` are not sufficient to
select App Store regions; confirm the mapping remotely before writing.

The repository's `AppStore/Metadata/` and `AppStore/Plans/` directories are
ignored. Keep version-specific input and full remote output there or in other
private storage. `apogee.json` resolves its default metadata path beside the
configuration file; an explicit CLI path resolves from the current directory.
Prefer an absolute input path for release work:

```sh
export RELEASE_METADATA_PATH="/absolute/private/path/to/intended-version"
swift package --package-path Tools/Release plugin \
  --allow-network-connections all apogee validate-metadata \
  --metadata-path "$RELEASE_METADATA_PATH" --release-notes-only
```

Validation needs no API credentials and makes no App Store Connect requests.
SwiftPM may download dependencies. It validates UTF-8 input and safe paths,
not Apple's locale support, length limits, permissions, or version editability.
An empty file requests clearing a field; omit files for fields left unchanged.
Do not copy 5.x notes into a 6.x release or create placeholder remote versions.

## Authentication

Apogee 1.0 requires a team API key; individual API keys are unsupported.
An Account Holder or Admin can generate one in App Store Connect under
**Users and Access > Integrations > App Store Connect API > Team Keys**.
Select the role needed for the intended operations. Team keys can access every
app in the account; setting Incomes' app ID does not narrow that permission.
Follow Apple's [API key setup](https://developer.apple.com/help/app-store-connect/get-started/app-store-connect-api/).

Download the private key once, store it outside the repository, and restrict
file access to its owner. Configure the execution shell locally:

```sh
export ASC_KEY_ID="YOUR_TEAM_KEY_ID"
export ASC_ISSUER_ID="YOUR_TEAM_ISSUER_ID"
export ASC_PRIVATE_KEY_PATH="/absolute/private/path/to/AuthKey_YOUR_TEAM_KEY_ID.p8"
```

Keep the key, credential environment files, and tokens out of Git and chat.
Apogee does not load `.env` files automatically. If using a private shell
environment file, source it in the shell running the command. Avoid shell tracing.
`ASC_PRIVATE_KEY_BASE64`, when set, overrides `ASC_PRIVATE_KEY_PATH`.

## Initial account validation

Read the existing 5.12 version with the app ID stated explicitly:

```sh
swift package --package-path Tools/Release plugin \
  --allow-network-connections all apogee release-status \
  --app-id 1584472982 --platform IOS --version 5.12
```

Compare the version, attached build, review submissions, release type, and
earliest release date with App Store Connect. The released 5.12 version provides
a read-only baseline. Reading status does not validate remote writes.

For the first metadata write, use an existing editable version intended for a
real release. Agree on the version, locales, and complete text, then save the
current remote values in private storage. Set `RELEASE_VERSION` explicitly:

```sh
export RELEASE_VERSION="ACTUAL_EDITABLE_VERSION"
swift package --package-path Tools/Release plugin \
  --allow-network-connections all apogee update-release-notes \
  --app-id 1584472982 --platform IOS --version "$RELEASE_VERSION" \
  --metadata-path "$RELEASE_METADATA_PATH" --dry-run
```

Review the entire diff before approving that specific update. Only then replace
`--dry-run` with `--apply`. Read the values back in App Store Connect and run a
fresh dry run; expect no differences. If an operation fails, inspect remote
state before retrying: locale writes are sequential and do not roll back.
Keep the tag, resolved SHA, toolchain, commands, results, and remaining limits
in private validation notes for the Apogee adoption handoff.

If final release copy is not ready, explicitly approved temporary text can
validate writes on the actual editable version. Record whether that text remains
or was restored, and replace any remaining temporary text before submission.
Successful metadata validation does not authorize review submission or release.

## Subsequent 6.x releases

1. Develop on `main`; the `5.12` tag preserves the released 5.x baseline.
2. Verify library behavior, affected app surfaces, and relevant runtime flows.
   The Xcode Cloud workflow targets `main` with **Latest Beta or Release**.
   Match local release verification to the actual Xcode version recorded for
   the candidate's Cloud build.
3. Use Xcode Cloud to build, test, archive, and upload the intended candidate.
   Apogee does not build or upload app binaries.
4. Prepare an App Store version, locales, publication timing, and any review,
   privacy, screenshot, or subscription updates in App Store Connect.
5. Validate metadata, inspect release status, and review/apply the intended
   metadata update. Attach an exact processed build through a separate
   `attach-build --dry-run`, followed by its approved `--apply`.
6. Treat `submit-for-review` as a separate release decision after all evidence
   is ready. Check its dry run, attached build, and publication timing before
   applying. Monitor with `release-status`; confirm publication separately.

No operation runs automatically from an app build or Git push in this package.
Use Apogee's [adoption guide](https://github.com/muhiro12/Apogee/blob/1.0/docs/adoption.md)
for command boundaries and failure recovery. After dependency updates, verify
the published tag and resolved revision, run local metadata validation, and
check release status and a fresh metadata dry run before the next write.
