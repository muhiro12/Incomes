@testable import IncomesLibrary
import Testing

@Suite("AppStorage key bridge")
struct AppStorageKeyBridgeTests {
    @Test("Bool key bridge preserves the legacy storage key")
    func boolKeyBridgePreservesLegacyStorageKey() {
        let storageKey = BoolAppStorageKey.isSubscribeOn.preferenceKey.storageKey

        #expect(
            storageKey == BoolAppStorageKey.isSubscribeOn.rawValue
        )
    }

    @Test("String key bridge preserves the legacy storage key")
    func stringKeyBridgePreservesLegacyStorageKey() {
        let storageKey = StringAppStorageKey.currencyCode.preferenceKey.storageKey

        #expect(
            storageKey == StringAppStorageKey.currencyCode.rawValue
        )
    }

    @Test("Notification settings key bridge preserves the legacy storage key")
    func notificationSettingsKeyBridgePreservesLegacyStorageKey() {
        let storageKey = NotificationSettingsAppStorageKey.notificationSettings.preferenceKey.storageKey

        #expect(
            storageKey == NotificationSettingsAppStorageKey.notificationSettings.rawValue
        )
    }
}
