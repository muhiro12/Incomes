import Foundation
@testable import IncomesLibrary
import MHPlatformCore
import Testing

struct SubscriptionStateOperationsTests {
    @Test(arguments: [false, true])
    func lapseAndRenewalPreserveTheChoiceAcrossPreferenceReloads(isICloudOn: Bool) throws {
        try withStore { suiteName, store in
            store.set(isICloudOn, for: \.isICloudOn)
            SubscriptionStateOperations.updateSubscriptionAccess(.active, store: store)
            #expect(SubscriptionStateOperations.isICloudEnabled(store: store) == isICloudOn)

            SubscriptionStateOperations.updateSubscriptionAccess(.inactive, store: store)
            let reloaded = MHPreferenceStore(userDefaults: try #require(UserDefaults(suiteName: suiteName)))
            #expect(!reloaded.bool(for: \.isSubscribeOn))
            #expect(!SubscriptionStateOperations.isICloudEnabled(store: reloaded))
            #expect(reloaded.bool(for: \.isICloudOn) == isICloudOn)

            SubscriptionStateOperations.updateSubscriptionAccess(.active, store: reloaded)
            #expect(reloaded.bool(for: \.isSubscribeOn))
            #expect(SubscriptionStateOperations.isICloudEnabled(store: reloaded) == isICloudOn)
            #expect(reloaded.bool(for: \.isICloudOn) == isICloudOn)
        }
    }

    @Test(arguments: [false, true], [false, true])
    func unknownStatusPreservesAccessAndChoice(isActive: Bool, isICloudOn: Bool) throws {
        try withStore { _, store in
            store.set(isActive, for: \.isSubscribeOn)
            store.set(isICloudOn, for: \.isICloudOn)
            SubscriptionStateOperations.updateSubscriptionAccess(.unknown, store: store)
            #expect(store.bool(for: \.isSubscribeOn) == isActive)
            #expect(store.bool(for: \.isICloudOn) == isICloudOn)
            #expect(SubscriptionStateOperations.isICloudEnabled(store: store) == (isActive && isICloudOn))
        }
    }

    @Test
    func explicitOffDuringLapsePreventsRenewalFromEnablingSync() throws {
        try withStore { _, store in
            store.set(true, for: \.isICloudOn)
            SubscriptionStateOperations.updateSubscriptionAccess(.active, store: store)
            SubscriptionStateOperations.updateSubscriptionAccess(.inactive, store: store)
            store.set(false, for: \.isICloudOn)
            SubscriptionStateOperations.updateSubscriptionAccess(.active, store: store)
            #expect(store.bool(for: \.isSubscribeOn))
            #expect(!SubscriptionStateOperations.isICloudEnabled(store: store))
            #expect(!store.bool(for: \.isICloudOn))
        }
    }

    @Test
    func firstPurchaseDoesNotOptIntoSync() throws {
        try withStore { _, store in
            SubscriptionStateOperations.updateSubscriptionAccess(.unknown, store: store)
            #expect(!store.bool(for: \.isSubscribeOn))
            #expect(!SubscriptionStateOperations.isICloudEnabled(store: store))
            SubscriptionStateOperations.updateSubscriptionAccess(.active, store: store)
            #expect(store.bool(for: \.isSubscribeOn))
            #expect(!SubscriptionStateOperations.isICloudEnabled(store: store))
            #expect(!store.bool(for: \.isICloudOn))
        }
    }

    @Test
    func ledgerPermissionsFollowResolvedAccess() throws {
        try withStore { _, store in
            let ledgerIdentifier = LedgerIdentifier()
            for access: SubscriptionStateOperations.SubscriptionAccess in [.active, .unknown, .inactive, .active] {
                SubscriptionStateOperations.updateSubscriptionAccess(access, store: store)
                #expect(LedgerAccessOperations.canEdit(
                    ledgerIdentifier,
                    isPremium: store.bool(for: \.isSubscribeOn)
                ) == (access != .inactive))
            }
        }
    }
}

private extension SubscriptionStateOperationsTests {
    func withStore(_ operation: (String, MHPreferenceStore) throws -> Void) throws {
        let suiteName = "SubscriptionStateOperationsTests-\(UUID().uuidString)"
        let defaults = try #require(UserDefaults(suiteName: suiteName))
        defer {
            defaults.removePersistentDomain(forName: suiteName)
        }
        try operation(suiteName, .init(userDefaults: defaults))
    }
}
