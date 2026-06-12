import Foundation
@testable import IncomesLibrary
import Testing

struct RepeatMonthSelectionOperationsTests {
    @Test
    func parse_accepts_commas_spaces_and_hyphens() throws {
        let selections = try RepeatMonthSelectionOperations.parse(
            "202501, 2025-02 202503"
        )

        #expect(selections.count == 3)
        #expect(selections.contains(.init(year: 2_025, month: 1)))
        #expect(selections.contains(.init(year: 2_025, month: 2)))
        #expect(selections.contains(.init(year: 2_025, month: 3)))
    }

    @Test
    func parse_returns_empty_for_blank_text() throws {
        let selections = try RepeatMonthSelectionOperations.parse("   ")
        #expect(selections.isEmpty)
    }

    @Test
    func parse_throws_for_invalid_token() {
        #expect(throws: RepeatMonthSelectionOperations.ParseError.self) {
            _ = try RepeatMonthSelectionOperations.parse("2025AA")
        }
    }

    @Test
    func validMonths_returns_calendar_month_range() {
        #expect(RepeatMonthSelectionOperations.validMonths == 1...12)
    }

    @Test
    func normalized_filters_invalid_entries_and_keeps_base_selection() {
        let baseDate = shiftedDate("2024-05-10T12:00:00Z")
        let selections: Set<RepeatMonthSelection> = [
            .init(year: 2_024, month: 5),
            .init(year: 2_024, month: 12),
            .init(year: 2_025, month: 2),
            .init(year: 2_026, month: 1),
            .init(year: 2_024, month: 0)
        ]

        let normalized = RepeatMonthSelectionOperations.normalized(
            selections,
            baseDate: baseDate
        )

        #expect(normalized.contains(.init(year: 2_024, month: 5)))
        #expect(normalized.contains(.init(year: 2_024, month: 12)))
        #expect(normalized.contains(.init(year: 2_025, month: 2)))
        #expect(!normalized.contains(.init(year: 2_026, month: 1)))
        #expect(!normalized.contains(.init(year: 2_024, month: 0)))
    }

    @Test
    func monthOffset_uses_base_date_year_and_month() {
        let baseDate = shiftedDate("2024-11-20T12:00:00Z")
        let target: RepeatMonthSelection = .init(year: 2_025, month: 2)

        let offset = RepeatMonthSelectionOperations.monthOffset(
            from: baseDate,
            to: target
        )

        #expect(offset == 3)
    }
}
