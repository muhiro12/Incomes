import Foundation
@testable import IncomesLibrary
import SwiftData
import Testing

struct YearlyItemDuplicationSuggestionTests {
    let context: ModelContext

    init() {
        context = testContext
    }

    @Test
    func availableSourceYears_returns_current_year_when_no_tags() {
        let years = YearlyItemDuplicationSelectionOperations.availableSourceYears(
            from: [],
            currentYear: 2_030
        )

        #expect(years == [2_030])
    }

    @Test
    func availableSourceYears_loads_persisted_year_tags() throws {
        _ = try createItem(
            context: context,
            date: shiftedDate("2022-01-10T12:00:00Z"),
            content: "Old",
            income: .zero,
            outgo: 100,
            category: "Other",
            priority: .zero,
            repeatCount: 1
        )
        _ = try createItem(
            context: context,
            date: shiftedDate("2024-01-10T12:00:00Z"),
            content: "Recent",
            income: .zero,
            outgo: 200,
            category: "Other",
            priority: .zero,
            repeatCount: 1
        )

        let years = try YearlyItemDuplicationSelectionOperations.availableSourceYears(
            context: context,
            currentYear: 2_030
        )

        #expect(years == [2_024, 2_022])
    }

    @Test
    func targetYears_returns_descending_range() {
        let years = YearlyItemDuplicationSelectionOperations.targetYears(
            currentYear: 2_024,
            range: 1
        )

        #expect(years == [2_025, 2_024, 2_023])
    }

    @Test
    func suggestion_selects_latest_year_meeting_minimum_groups() throws {
        _ = try createItem(
            context: context,
            date: shiftedDate("2024-04-10T12:00:00Z"),
            content: "Solo",
            income: 0,
            outgo: 120,
            category: "Other",
            priority: 0,
            repeatCount: 3
        )

        for (offset, content) in ["Alpha", "Beta", "Gamma"].enumerated() {
            let month = 1 + offset
            let dateString = "2023-0\(month)-10T12:00:00Z"
            _ = try createItem(
                context: context,
                date: shiftedDate(dateString),
                content: content,
                income: 0,
                outgo: 200,
                category: "Card",
                priority: 0,
                repeatCount: 3
            )
        }

        let yearTags = try context.fetch(.tags(.typeIs(.year), order: .reverse))
        let targetYears = YearlyItemDuplicationSelectionOperations.targetYears(
            currentYear: 2_024,
            range: 1
        )

        let suggestion = YearlyItemDuplicationSelectionOperations.suggestion(
            context: context,
            yearTags: yearTags,
            targetYears: targetYears,
            minimumGroupCount: 3
        )

        let resolvedSuggestion = try #require(suggestion)
        #expect(resolvedSuggestion.sourceYear == 2_023)
        #expect(resolvedSuggestion.targetYear == 2_024)
        #expect(resolvedSuggestion.plan.groups.count == 3)
    }

    @Test
    func suggestion_falls_back_when_no_year_meets_threshold() throws {
        _ = try createItem(
            context: context,
            date: shiftedDate("2024-06-10T12:00:00Z"),
            content: "Solo",
            income: 0,
            outgo: 100,
            category: "Other",
            priority: 0,
            repeatCount: 3
        )

        let yearTags = try context.fetch(.tags(.typeIs(.year), order: .reverse))
        let targetYears = YearlyItemDuplicationSelectionOperations.targetYears(
            currentYear: 2_024,
            range: 1
        )

        let suggestion = YearlyItemDuplicationSelectionOperations.suggestion(
            context: context,
            yearTags: yearTags,
            targetYears: targetYears,
            minimumGroupCount: 3
        )

        let resolvedSuggestion = try #require(suggestion)
        #expect(resolvedSuggestion.sourceYear == 2_024)
        #expect(resolvedSuggestion.targetYear == 2_025)
        #expect(resolvedSuggestion.plan.groups.count == 1)
    }

    @Test
    func suggestion_loads_persisted_year_tags() throws {
        for (offset, content) in ["Alpha", "Beta", "Gamma"].enumerated() {
            let month = 1 + offset
            let dateString = "2023-0\(month)-10T12:00:00Z"
            _ = try createItem(
                context: context,
                date: shiftedDate(dateString),
                content: content,
                income: .zero,
                outgo: 200,
                category: "Card",
                priority: .zero,
                repeatCount: 3
            )
        }
        let targetYears = YearlyItemDuplicationSelectionOperations.targetYears(
            currentYear: 2_024,
            range: 1
        )

        let suggestion = try YearlyItemDuplicationSelectionOperations.suggestion(
            context: context,
            targetYears: targetYears,
            minimumGroupCount: 3
        )

        let resolvedSuggestion = try #require(suggestion)
        #expect(resolvedSuggestion.sourceYear == 2_023)
        #expect(resolvedSuggestion.targetYear == 2_024)
        #expect(resolvedSuggestion.plan.groups.count == 3)
    }
}
