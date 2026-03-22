@testable import IncomesLibrary
import Testing

@Suite("AppStorage key bridge")
struct AppStorageKeyBridgeTests {
    @Test("Bool keys preserve legacy raw values")
    func boolKeysPreserveLegacyRawValues() {
        #expect(BoolAppStorageKey.isSubscribeOn.rawValue == "a018f613")
        #expect(BoolAppStorageKey.isICloudOn.rawValue == "X7b9C4tZ")
        #expect(BoolAppStorageKey.isDebugOn.rawValue == "a1B2c3D4")
    }

    @Test("String keys preserve legacy raw values")
    func stringKeysPreserveLegacyRawValues() {
        #expect(StringAppStorageKey.currencyCode.rawValue == "R8k2Z3tL")
        #expect(StringAppStorageKey.lastLaunchedAppVersion.rawValue == "j4N7v2Qk")
    }

    @Test("Notification settings key preserves legacy raw value")
    func notificationSettingsKeyPreservesLegacyRawValue() {
        #expect(
            NotificationSettingsAppStorageKey.notificationSettings.rawValue == "A3b9Z1xQ"
        )
    }
}
