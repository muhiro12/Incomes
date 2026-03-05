import Foundation
@testable import IncomesLibrary
import Testing

struct RepeatMonthSelectionRulesTests {
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

        let normalized = RepeatMonthSelectionRules.normalized(
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

        let offset = RepeatMonthSelectionRules.monthOffset(
            from: baseDate,
            to: target
        )

        #expect(offset == 3)
    }
}
