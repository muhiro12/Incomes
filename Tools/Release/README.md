# Incomes release tools

This macOS SwiftPM package uses Apogee's command plugin for the Incomes 6.x
release cycle. It pins Apogee **1.5.0** at
`5492b06b750833fc945ae0fd041e011351d131d2`; commit `Package.resolved` with any
deliberate dependency update. No app target links Apogee.

Apogee publishes three-component semantic version tags, so the Git tag, the
`Package.swift` requirement, and the `Package.resolved` version all read
`1.5.0`. Check the resolved revision as well as the version when updating.

Match the selected local Xcode to the toolchain used for the intended release
candidate. The current project-format qualification uses Xcode 27.2 RC
(27B48); that qualification alone does not establish a Cloud candidate's
toolchain or release readiness. Run these commands from the repository root:

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

For screenshot operations, add `--progress` to show preparation and upload
stages on standard error while keeping standard output as the final JSON
result. The flag is optional and does not change the dry-run or apply boundary.

## Screenshot migration from 1.4.0

Apogee 1.5.0 uses Apple's App Asset Library, including `IPHONE_DUO`.
Production input directories now use display classes instead of the former
`APP_*` names. For the current Incomes captures, use these directories under
each App Store locale:

| Capture target | Directory |
| --- | --- |
| iPhone | `IPHONE_DYNAMIC_ISLAND_MEDIUM_DISPLAY` |
| iPhone Duo | `IPHONE_DUO` |
| iPad | `IPAD_13_DISPLAY` |
| Apple Watch | `WATCH_SERIES_10` |

Preserve the approved image bytes and numbered order. Do not mix old and new
directory names. Apple's runtime reference data determines compatible image
dimensions and placement groups; Apogee does not resize or retarget images.
Only supplied locale/display directories are updated. Omitted directories and
empty directories do not request deletion of obsolete placements.

Start each new operation with a new private recovery directory. Legacy
`state.json` journals cannot resume Asset Library operations. The new
`asset-library-state.json` records asset and placement identities and original
order; it does not export original image bytes. Keep the approved source files
and earlier recovery records. Obsolete placements may be removed, while shared
library images remain available.

Obtain a fresh `update-screenshots --dry-run` plan before an approved `--apply`.
Placement removal or reordering also requires `--allow-destructive` and the
matching plan token. Existing images may be planned for upload again if they
lack Apogee's SHA-256 identity metadata. That writable metadata is not a
server-verified checksum: the new API has no `sourceFileChecksum`. Verification
checks processing, compatible specifications, byte counts, asset and placement
identities, readiness, and order. Inspect the entire plan before applying.

See the pinned [screenshot guide](https://github.com/muhiro12/Apogee/blob/1.5.0/docs/screenshots.md)
for input limits, recovery, and the verification contract.

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

Release notes are plain text. When copying a draft from chat or a Markdown
document, copy only the content inside any code block; exclude opening and
closing fences such as triple backticks and any language label. Apogee's
validation does not detect these presentation wrappers. Review every locale's
complete text in the dry-run diff, including the first and last lines, before
applying it. After publication, check the actual storefront text as well as
the App Store Connect values.

Do not copy 5.x notes into a 6.x release or create placeholder remote versions.

## Authentication

Apogee requires a team API key; individual API keys are unsupported.
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
4. Prepare the App Store version, locales, publication timing, and any review,
   privacy, or subscription updates. `create-version` can create a missing
   version for manual release, and `update-version-settings` can change
   copyright or release policy; both plan first and apply only when approved.
   Locale creation and review declarations stay in App Store Connect.
5. Validate metadata, inspect release status, and review/apply the intended
   metadata update. `read-metadata` exports the stored remote values, and
   `update-screenshots` plans Asset Library placements and applies an approved
   plan with private recovery storage. Attach an exact processed build through
   a separate `attach-build --dry-run`, followed by its approved `--apply`.
6. Treat `submit-for-review` as a separate release decision after all evidence
   is ready. Read `build-feedback` for the candidate build, then check the dry
   run, attached build, and publication timing before applying. Monitor with
   `release-status`; confirm publication separately.

No operation runs automatically from an app build or Git push in this package.
Use Apogee's [adoption guide](https://github.com/muhiro12/Apogee/blob/1.5.0/docs/adoption.md)
for command boundaries and failure recovery. After dependency updates, verify
the published tag and resolved revision, run local metadata validation, and
check release status and a fresh metadata dry run before the next write.
