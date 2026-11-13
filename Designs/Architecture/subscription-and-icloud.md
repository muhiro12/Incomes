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

This decision changes configuration of the same production store URL. It does
not delete, replace, or copy financial records. A previously erased choice
cannot be reconstructed: an existing off value remains off.

The open model container is not replaced when access or the choice changes.
Until the next launch it keeps its actual configuration, including when a
subscription expires. Settings shows that configuration independently of the
saved toggle and displays a restart notice when the next-launch setting differs.
During a lapse, an existing on choice can be turned off; off cannot be turned on
until access is available again. A retained on resumes at a subsequent launch
after active access has been saved.

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
not qualify a signed distribution build. The three new messages cover all five
app languages.
The normal signed Debug launch reached `startup.ready` with iCloud disabled, as
expected for the development store. That launch does not expose the Release-only
iCloud settings section and does not replace its visual qualification.

The Japanese `Lapsed, current iCloud session` Preview failed twice during host
launch with `SIGSEGV`, including after a successful app rebuild. Its crash stack
passed through the Preview/JIT app entry point without identifying a settings
view frame; ownership of that failure is unresolved. No image was captured.
The renewed and inactive-off previews remain unattempted, so visible layout and
toggle interaction still need runtime qualification.

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
