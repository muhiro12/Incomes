@testable import IncomesLibrary
import MHPlatformCore
import Testing

@Suite("Preference descriptors")
struct PreferenceDescriptorTests {
    @Test("Bool descriptors preserve legacy storage keys")
    func boolDescriptorsPreserveLegacyStorageKeys() {
        let descriptors = MHPreferenceDescriptors()

        #expect(
            descriptors.isSubscribeOn.storageKey == IncomesUserDefaultsKeys.Standard.isSubscribeOn.rawValue
        )
        #expect(
            descriptors.isICloudOn.storageKey == IncomesUserDefaultsKeys.Standard.isICloudOn.rawValue
        )
        #expect(
            descriptors.isDebugOn.storageKey == IncomesUserDefaultsKeys.Standard.isDebugOn.rawValue
        )
        #expect(descriptors.isSubscribeOn.defaultSelection == .standard)
        #expect(descriptors.isICloudOn.defaultSelection == .standard)
        #expect(descriptors.isDebugOn.defaultSelection == .standard)
    }

    @Test("String descriptors preserve legacy storage keys")
    func stringDescriptorsPreserveLegacyStorageKeys() {
        let descriptors = MHPreferenceDescriptors()

        #expect(
            descriptors.currencyCode.storageKey == IncomesUserDefaultsKeys.Standard.currencyCode.rawValue
        )
        #expect(
            descriptors.lastLaunchedAppVersion.storageKey == IncomesUserDefaultsKeys.Standard.lastLaunchedAppVersion.rawValue
        )
        #expect(descriptors.currencyCode.defaultSelection == .standard)
        #expect(descriptors.lastLaunchedAppVersion.defaultSelection == .standard)
    }

    @Test("Notification settings descriptor preserves legacy storage key")
    func notificationSettingsDescriptorPreservesLegacyStorageKey() {
        let descriptors = MHPreferenceDescriptors()

        #expect(
            descriptors.notificationSettings.storageKey == IncomesUserDefaultsKeys.Standard.notificationSettings.rawValue
        )
        #expect(descriptors.notificationSettings.defaultSelection == .standard)
    }
}
