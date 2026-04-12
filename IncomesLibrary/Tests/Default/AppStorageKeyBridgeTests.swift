@testable import IncomesLibrary
import Testing

@Suite("AppStorage key bridge")
struct AppStorageKeyBridgeTests {
    @Test("Bool key bridge preserves the legacy storage key")
    func boolKeyBridgePreservesLegacyStorageKey() {
        let descriptor = BoolAppStorageKey.isSubscribeOn.preferenceDescriptor

        #expect(
            descriptor.storageKey == BoolAppStorageKey.isSubscribeOn.rawValue
        )
        #expect(
            descriptor.defaultSelection == .standard
        )
    }

    @Test("String key bridge preserves the legacy storage key")
    func stringKeyBridgePreservesLegacyStorageKey() {
        let descriptor = StringAppStorageKey.currencyCode.preferenceDescriptor

        #expect(
            descriptor.storageKey == StringAppStorageKey.currencyCode.rawValue
        )
        #expect(
            descriptor.defaultSelection == .standard
        )
    }

    @Test("Notification settings key bridge preserves the legacy storage key")
    func notificationSettingsKeyBridgePreservesLegacyStorageKey() {
        let descriptor = NotificationSettingsAppStorageKey.notificationSettings.preferenceDescriptor

        #expect(
            descriptor.storageKey == NotificationSettingsAppStorageKey.notificationSettings.rawValue
        )
        #expect(
            descriptor.defaultSelection == .standard
        )
    }
}
