import Foundation
@testable import IncomesLibrary
import Testing

struct ItemInferenceDateOperationsTests {
    @Test(arguments: ["昨日", "昨日の", "昨日に", "yesterday", "hier", "ayer", "昨天"])
    func yesterday_crosses_a_year_boundary_without_model_arithmetic(_ expression: String) throws {
        #expect(try resolve(expression, reference: "20270101") == "20261231")
    }

    @Test(arguments: ["America/Los_Angeles", "Asia/Tokyo", "Europe/Paris"])
    func relative_days_use_calendar_days_across_dst(_ identifier: String) throws {
        #expect(try resolve("yesterday", reference: "20260309", timeZone: identifier) == "20260308")
        #expect(try resolve("yesterday", reference: "20261102", timeZone: identifier) == "20261101")
    }

    @Test
    func relative_days_preserve_leap_days_and_roll_months() throws {
        #expect(try resolve("昨日", reference: "20240301") == "20240229")
        #expect(try resolve("明日", reference: "20261231") == "20270101")
        #expect(try resolve("一昨日", reference: "20260101") == "20251230")
        #expect(try resolve("après-demain", reference: "20260227") == "20260301")
    }

    @Test(arguments: [
        "2026-10-28", "2026/10/28", "2026年10月28日", "２０２６年１０月２８日",
        "October 28, 2026", "28 octobre 2026", "28 de octubre de 2026", "10月28日"
    ])
    func supported_explicit_source_expressions_keep_the_exact_day(_ expression: String) throws {
        #expect(try resolve(expression) == "20261028")
    }

    @Test(arguments: [
        "", "来月", "next month", "2026年11月", "November 2026", "11/2", "2026年2月30日",
        "February 30, 2026", "2026-13-01", "20261028", "yesterday then tomorrow"
    ])
    func incomplete_invalid_or_unsupported_expressions_do_not_invent_a_day(_ expression: String) throws {
        #expect(try resolve(expression).isEmpty)
    }

    @Test
    func dates_not_present_in_source_are_not_applied() throws {
        let date = try referenceDate("20261029", timeZone: .gmt)
        #expect(ItemInferenceDateOperations.dateString(
            expression: "2026年11月1日",
            sourceText: "来月の家賃、金額未定です。",
            referenceDate: date,
            locale: .init(identifier: "ja_JP"),
            timeZone: .gmt
        ).isEmpty)
        #expect(ItemInferenceDateOperations.dateString(
            expression: "yesterday",
            sourceText: "Paid 1200 for lunch.",
            referenceDate: date,
            locale: .init(identifier: "en_US"),
            timeZone: .gmt
        ).isEmpty)
    }

    private func resolve(
        _ expression: String,
        reference: String = "20261029",
        timeZone identifier: String = "Asia/Tokyo"
    ) throws -> String {
        let timeZone = try #require(TimeZone(identifier: identifier))
        return try ItemInferenceDateOperations.dateString(
            expression: expression,
            sourceText: "Item: \(expression), expense 1200.",
            referenceDate: referenceDate(reference, timeZone: timeZone),
            locale: .init(identifier: "ja_JP"),
            timeZone: timeZone
        )
    }

    private func referenceDate(_ text: String, timeZone: TimeZone) throws -> Date {
        let formatter = DateFormatter()
        formatter.calendar = .init(identifier: .gregorian)
        formatter.locale = .init(identifier: "en_US_POSIX")
        formatter.timeZone = timeZone
        formatter.dateFormat = "yyyyMMdd"
        return try #require(formatter.date(from: text))
    }
}
