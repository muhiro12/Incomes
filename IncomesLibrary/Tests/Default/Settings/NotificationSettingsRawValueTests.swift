import Foundation
@testable import IncomesLibrary
import Testing

@Suite("Notification settings raw value")
struct NotificationSettingsRawValueTests {
    @Test("Raw value round-trips the legacy string-backed representation")
    func rawValueRoundTripsLegacyStringBackedRepresentation() throws {
        var settings = NotificationSettings()
        settings.isEnabled = false
        settings.thresholdAmount = 1_234.56
        settings.daysBeforeDueDate = 5
        settings.notifyTime = try #require(
            Calendar.current.date(
                bySettingHour: 7,
                minute: 15,
                second: 0,
                of: shiftedDate("2024-01-01T00:00:00Z")
            )
        )

        let restoredSettings = try #require(
            NotificationSettings(
                rawValue: settings.rawValue
            )
        )

        #expect(restoredSettings.isEnabled == settings.isEnabled)
        #expect(restoredSettings.thresholdAmount == settings.thresholdAmount)
        #expect(restoredSettings.daysBeforeDueDate == settings.daysBeforeDueDate)
        #expect(
            abs(
                restoredSettings.notifyTime.timeIntervalSince1970
                    - settings.notifyTime.timeIntervalSince1970
            ) < 0.001
        )
    }
}
