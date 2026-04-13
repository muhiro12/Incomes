@testable import IncomesLibrary
import Testing

@Suite("Notification settings raw value")
struct NotificationSettingsRawValueTests {
    @Test("Raw value round-trips the legacy string-backed representation")
    func rawValueRoundTripsLegacyStringBackedRepresentation() {
        var settings = NotificationSettings()
        settings.isEnabled = false
        settings.thresholdAmount = 1_234.56
        settings.daysBeforeDueDate = 5
        settings.notifyTime = .now

        let restoredSettings = NotificationSettings(
            rawValue: settings.rawValue
        )

        #expect(restoredSettings == settings)
    }
}
