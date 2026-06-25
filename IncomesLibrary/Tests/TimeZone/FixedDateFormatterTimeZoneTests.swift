import Foundation
@testable import IncomesLibrary
import Testing

@Suite(.serialized)
struct FixedDateFormatterTimeZoneTests {
    private var tokyoTimeZone: TimeZone {
        get throws {
            try #require(TimeZone(identifier: "Asia/Tokyo"))
        }
    }

    @Test("Without-locale formatting follows the default time zone")
    func withoutLocaleFormattingFollowsDefaultTimeZone() throws {
        try withDefaultTimeZone(tokyoTimeZone) {
            let date = try #require(iso8601Date("2024-12-31T15:00:00Z"))

            #expect(date.stringValueWithoutLocale(.yyyy) == "2025")
            #expect(date.stringValueWithoutLocale(.yyyyMM) == "202501")
        }
    }

    @Test("Without-locale parsing follows the default time zone")
    func withoutLocaleParsingFollowsDefaultTimeZone() throws {
        try withDefaultTimeZone(tokyoTimeZone) {
            let parsedDate = try #require("20250102".dateValueWithoutLocale(.yyyyMMdd))
            let expectedDate = try #require(iso8601Date("2025-01-01T15:00:00Z"))

            #expect(parsedDate == expectedDate)
        }
    }

    private func withDefaultTimeZone(
        _ timeZone: TimeZone,
        operation: () throws -> Void
    ) rethrows {
        let previousTimeZone = TimeZone.ReferenceType.default
        TimeZone.ReferenceType.default = timeZone
        defer {
            TimeZone.ReferenceType.default = previousTimeZone
        }
        try operation()
    }

    private func iso8601Date(_ string: String) -> Date? {
        ISO8601DateFormatter().date(from: string)
    }
}
