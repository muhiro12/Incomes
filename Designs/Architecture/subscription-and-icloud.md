# Subscription and iCloud

## Saved choice and effective configuration

`SubscriptionStateOperations` owns app policy using the existing standard
preferences. `isSubscribeOn` records the last resolved Premium access;
`isICloudOn` records the person's choice. Neither needs a new storage key or
SwiftData schema change.

- Active access sets `isSubscribeOn` to true; inactive access sets it to false.
- Unknown access preserves the last resolved value, including at startup.
- Every access transition preserves `isICloudOn`. A purchase, restore, or renewal
  never opts into sync or overrides an explicit off choice.
- Production startup calls `isICloudEnabled(store:)` and configures CloudKit only
  when both preferences are true. DEBUG continues using the separate local
  development database without CloudKit.

This decision changes configuration of the same production store URL. The
preference-update path performs no record deletion, replacement, or copying.
A previously erased choice cannot be reconstructed: an existing off value
remains off.

The open model container is not replaced when access or the choice changes.
Until the next launch it keeps its actual configuration, including when a
subscription expires. Settings shows that configuration independently of the
saved toggle and displays a direction-specific restart notice when the
next-launch setting differs. These messages describe the container configuration,
not successful synchronization or a guarantee against data loss.
During a lapse, an existing on choice can be turned off; off cannot be turned on
until access is available again. A retained on resumes at a subsequent launch
after active access has been saved.

Settings describes the toggle as a saved choice and requires quitting and
reopening Incomes to apply changes. When a retained on choice lacks subscription
access, it explains why that choice cannot enable sync at the next launch.
When a configuration change is pending, it also explains that returning from
the background does not apply the change. These explanations do not promise
that switching off the toggle immediately stops uploads or incoming changes.

Startup uses the last resolved access before opening the store. A different
access result received afterward updates the next-launch decision only. This
can require a further launch after purchase, restore, or expiry is recognized.
Do not block access to existing records on a network-dependent subscription
check as part of this policy. No startup entitlement wait is added here.

## Current-session consumers

The standard subscription section and StoreKit observer share MHPlatform's
StoreKitWrapper instance. Its purchased-identifier callback updates
`MHAppRuntime.premiumStatus`. `ContentView` observes that value initially and on
changes, maps the three provider states, and calls the shared operation through
the runtime's preference store.

Settings, ledger screens, editing controls, import, yearly duplication, and ad
placement wrappers observe `isSubscribeOn` through `AppStorage`. Mutation access
reads the current preference when checking permissions, including App Intents.
An inactive subscription keeps the default ledger editable and additional
ledgers readable/exportable under `LedgerAccessOperations`.

`AdvertisementSection` additionally observes the runtime's `canDisplayAds`,
which combines Premium and consent eligibility. There is no app-owned StoreKit
refresh loop or second entitlement verifier.

## Manual apply feasibility assessment

The 2026-11-14 assessment stops before implementing an **Apply now** button.
Keep the next-launch boundary. A deliberate button would improve control over
when screens reload, but does not establish a safe persistence handoff in the
current architecture. This is a bounded engineering decision, not a claim that
every same-process switching design is impossible.

The source and API review identified two unmet prerequisites:

- **Stop and drain every user-data operation.**
  `IncomesStartupCoordinator.registerDependencies` captures the platform
  environment for App Intent dependencies. `NotificationService` also retains
  its container. `CreateItemIntent` passes its context into
  `ItemCreateCoordinator`, whose asynchronous workflow retains that context
  across suspension. `IncomesMutationWorkflow.performDataMutation` launches a
  task without retaining a handle for a global handoff. Replacing the root view
  or registering new dependencies does not by itself revoke existing references
  or wait for those operations. A settings-only busy flag would not cover them.
- **Establish the old sync stack's shutdown boundary.**
  The selected Xcode's iOS 27.2 SwiftData public interface and Apple's
  [ModelContainer documentation][model-container] expose no explicit close or
  await-shutdown operation for the default store. Apple documents a writable
  [configurations property][container-configurations], but the reviewed contract
  does not specify a live CloudKit transition's completion, outstanding-work
  handling, or failure recovery. Its setter alone is insufficient evidence.
  [TN3164][sync-troubleshooting] explains that retained model objects can keep
  an old container alive and that overlapping containers can conflict.

Startup `retry()` is recovery after an open failure, not a live-switch API:
`state = makeState()` evaluates the replacement before assigning the new state.
Calling it from a ready session would not first release the current environment.
Neither saving the main context, waiting a fixed interval, nor user confirmation
establishes either prerequisite. Local save completion also does not establish
CloudKit delivery; TN3164 assigns synchronization timing to the system.

This assessment inspected current production call paths and the public SDK and
documentation. It did not run a live CloudKit switch, simulate data loss, or
establish a runtime failure. No prototype, production data operation, new test,
or app behavior change was made. A local-only reopen test would not qualify the
missing CloudKit boundary, so it was not used as a substitute.

Reconsider only with evidence for a supported sync handoff and an app-wide
operation gate that drains existing work, rejects stale writes, and replaces
all affected dependencies. Failure recovery and preservation of pending edits
would then need qualification on supported OS versions and actual cloud stores.
That scope is materially larger than adding a manual settings action and is
not selected by this assessment. A button that terminates the process is also
excluded; Apple's archived [QA1561][programmatic-exit] warns against `exit` and
notes that termination callbacks and saving may be skipped.

[model-container]: https://developer.apple.com/documentation/swiftdata/modelcontainer
[container-configurations]: https://developer.apple.com/documentation/swiftdata/modelcontainer/configurations
[sync-troubleshooting]: https://developer.apple.com/documentation/technotes/tn3164-debugging-the-synchronization-of-nspersistentcloudkitcontainer
[programmatic-exit]: https://developer.apple.com/library/archive/qa/qa1561/_index.html

## Evidence and remaining qualification

The 2026-11-13 review inspected the adopted MHPlatform 1.20.0
(`3f67a416`) and StoreKitWrapper 1.4.0 (`d82ee5bc`). Source inspection established
the callback and consumer wiring, not delivery by a real StoreKit purchase.
The provider retains its previous resolved access when entitlement verification
fails; pending or cancelled purchase UI must not be translated into inactive
access by the app.

`SubscriptionStateOperationsTests` covers both saved choices across lapse,
renewal, and preference reload; all unknown-state combinations; explicit off
during a lapse; first purchase without opt-in; and ledger permission changes.
These exercise the same preference update and startup decision used by the app.
They do not simulate StoreKit transactions or CloudKit delivery.

For this change, all 1,825 library tests passed on iOS Simulator 27.2, including
nine subscription-policy cases. The Incomes Debug build, Release compile check,
and repository rules passed. Release compilation used signing disabled and does
not qualify a signed distribution build. The settings messages cover all five
app languages. The subsequent direction-specific copy refinement passed an
Incomes Debug build, translation validation, and repository rules; it did not
change the shared subscription or persistence logic.
The 2026-11-14 saved-choice and background-resume guidance passed the same build,
translation validation, and repository rules. No shared logic changed, so the
library tests were not rerun for that copy-only adjustment.
The normal signed Debug launch reached `startup.ready` with iCloud disabled, as
expected for the development store. That launch does not expose the Release-only
iCloud settings section and does not replace its visual qualification.

The Japanese `Lapsed, current iCloud session` Preview failed twice during host
launch with `SIGSEGV`, including after a successful app rebuild. Its crash stack
passed through the Preview/JIT app entry point without identifying a settings
view frame; ownership of that failure is unresolved. No image was captured.
After the copy refinement, the Japanese `Renewed, next-launch sync` Preview
also failed during host launch with `SIGSEGV` before producing an image.
The inactive-off preview remains unattempted. Visible layout and toggle
interaction still need runtime qualification.
The additional retained-on/local-session preview is also unattempted; the
previous host-launch failures were not retried for the copy-only adjustment.

- [#424](https://github.com/muhiro12/Incomes/issues/424) still needs real
  purchase/restore, pending/cancellation, expiry/revocation, verification-failure,
  and offline/recovery qualification through the adopted standard subscription UI.
- [MHPlatform #23](https://github.com/muhiro12/MHPlatform/issues/23) owns evidence
  for the package's purchase/restore propagation. A callback injection alone is
  not evidence for that system flow.
- [#423](https://github.com/muhiro12/Incomes/issues/423) owns post-purchase navigation.
- [#411](https://github.com/muhiro12/Incomes/issues/411) owns safe same-session
  container replacement, including edits and recovery. This remains the exit
  from the next-launch application boundary.
- [#378](https://github.com/muhiro12/Incomes/issues/378) owns remote convergence.
  A configured container or active entitlement does not mean sync has completed.
