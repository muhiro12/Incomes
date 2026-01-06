//
//  NotificationSettingsTests.swift
//  IncomesTests
//
//  Created by Hiromu Nakano on 2025/10/11.
//

import Foundation
@testable import IncomesLibrary
import Testing

struct NotificationSettingsTests {
    @Test
    func rawValue_round_trips_settings_values() throws {
        var original = NotificationSettings()
        original.isEnabled = false
        original.thresholdAmount = 1_234
        original.daysBeforeDueDate = 5
        original.notifyTime = Calendar.current.date(
            bySettingHour: 7,
            minute: 15,
            second: 0,
            of: shiftedDate("2024-01-01T00:00:00Z")
        )!

        let encoded = original.rawValue
        let decoded = try #require(NotificationSettings(rawValue: encoded))

        #expect(decoded == original)
    }

    @Test
    func rawValue_returns_nil_for_invalid_payload() {
        let decoded = NotificationSettings(rawValue: "not-json")
        #expect(decoded == nil)
    }
}
