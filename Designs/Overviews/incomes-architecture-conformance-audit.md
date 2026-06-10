# Incomes Architecture Conformance Audit

Current as of March 26, 2026.

## Purpose

This note records whether the current repository still follows the accepted
Incomes architecture:

- `IncomesLibrary` is the single source of truth for reusable business logic.
- `Incomes`, `Watch`, `Widgets`, and App Intents stay responsibility-thin as
  Apple-platform adapters.
- Automated unit tests stay concentrated in `IncomesLibrary/Tests`.

Authoritative design rules remain:

- [ADR 0001](../Decisions/0001-shared-library-source-of-truth.md)
- [ADR 0003](../Decisions/0003-platform-adapters-stay-in-app-target.md)
- [ADR 0005](../Decisions/0005-adapter-failure-surfacing-contract.md)
- [ARCHITECTURE_GUIDE.md](../Architecture/ARCHITECTURE_GUIDE.md)
- [shared-service-design.md](../Architecture/shared-service-design.md)

## Conclusion

The repository is materially aligned with the intended architecture. The target
split, shared-library-first reuse, and library-centered test posture are still
present in the implementation. The main drift found during this audit was watch
sync failure surfacing, where empty sentinels and `try?` could hide failures.
That drift is corrected in the current state by the shared `WatchSyncReply`
contract and watch UI state handling.

## Conformant

### Shared business logic remains centralized

- `IncomesLibrary` still owns the shared model, mutation/query services,
  planners, and snapshot builders.
- Representative files:
  - `IncomesLibrary/Sources/Item/Item*Operations.swift`
  - `IncomesLibrary/Sources/Tag/Tag*Operations.swift`
  - `IncomesLibrary/Sources/Item/ItemSummaryOperations.swift`
  - `IncomesLibrary/Sources/Item/YearlyItemDuplication*Operations.swift`
  - `IncomesLibrary/Sources/Common/WidgetEntryOperations.swift`

### Multiple targets still consume the same shared APIs

- The iPhone app, watch app, and widgets all depend on the local
  `IncomesLibrary` package product from `Incomes.xcodeproj`.
- Representative files:
  - `Incomes/Sources/Common/IncomesLibrary.swift`
  - `Watch/Sources/Common/IncomesLibrary.swift`
  - `Widgets/Sources/Common/IncomesLibrary.swift`
  - `Incomes.xcodeproj/project.pbxproj`

### Tests remain library-centered

- Repository-owned unit tests are still concentrated in `IncomesLibrary/Tests`.
- The Xcode project still exposes only product targets for `Incomes`, `Watch`,
  and `Widgets`, with no separate app/watch/widget unit test targets.
- Representative files:
  - `IncomesLibrary/Package.swift`
  - `IncomesLibrary/Tests/IncomesLibrary.xctestplan`
  - `Incomes.xcodeproj/project.pbxproj`

## Accepted Adaptations

### Thin targets are responsibility-thin, not line-count-thin

- `Incomes/Sources` is larger than `IncomesLibrary/Sources`, but most of that
  volume is SwiftUI composition, Apple-framework adapters, and runtime wiring.
- This is acceptable because reusable finance rules still route through shared
  services instead of being duplicated in the targets.
- Representative files:
  - `Incomes/Sources/IncomesApp.swift`
  - `Incomes/Sources/Common/Platform/IncomesPlatformEnvironmentFactory.swift`
  - `Incomes/Sources/Item/Services/ItemFormSaveCoordinator.swift`

### Watch and widget targets keep target-local glue while reusing shared rules

- `Watch` owns transport timing and screen state, and `Widgets` own timeline
  providers and entry presentation.
- Shared query, calculation, and snapshot apply logic remains in
  `IncomesLibrary`.
- Representative files:
  - `Watch/Sources/Services/WatchDataSyncer.swift`
  - `Watch/Sources/Services/PhoneSyncClient.swift`
  - `Widgets/Sources/Month/Providers/MonthSummaryProvider.swift`
  - `IncomesLibrary/Sources/Item/Sync/WatchSyncOperations.swift`

## Corrected Drift

### Watch sync failure surfacing drift

- Previous state:
  - `PhoneWatchBridge` could return empty `Data()`.
  - `PhoneSyncClient` collapsed transport and decode failures into `[]`.
  - `WatchDataSyncer` used `try?` and hid snapshot apply failures.
- Risk:
  - Transport, decode, and apply failures were not distinguishable from a
    legitimate zero-item sync result, which violated ADR 0005.
- Current correction:
  - `IncomesLibrary` now defines `ItemsRequest`, `WatchSyncReply`,
    `WatchSyncFailurePhase`, and `WatchSyncFailure`.
  - `PhoneWatchBridge` replies with typed success or failure payloads.
  - `PhoneSyncClient` and `WatchDataSyncer` now preserve transport, decode,
    and snapshot-apply failures as typed states.
  - `WatchHomeScreenModel` and `Watch` `ContentView` now distinguish
    reloading, sync failure, and successful empty sync on screen.
- Representative files:
  - `IncomesLibrary/Sources/Item/Sync/ItemsRequest.swift`
  - `IncomesLibrary/Sources/Item/Sync/WatchSyncReply.swift`
  - `Incomes/Sources/Common/Services/PhoneWatchBridge.swift`
  - `Watch/Sources/Services/PhoneSyncClient.swift`
  - `Watch/Sources/Services/WatchDataSyncer.swift`
  - `Watch/Sources/WatchHomeScreenModel.swift`
  - `Watch/Sources/ContentView.swift`

## Notes

- This audit does not introduce a new architecture policy. It records current
  conformance against the already accepted ADRs and guide documents.
- No additional app/watch/widget unit test targets were introduced as part of
  the correction. Coverage remains library-centered by design.
