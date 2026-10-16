import Foundation
import SwiftData
import Testing

@testable import IncomesLibrary

@MainActor
struct LedgerYearSelectionTests {
    @Test(arguments: [false, true])
    func candidateYearsAndAlignmentUseOwnedItems(preserve: Bool) throws {
        let context = try candidateFixture()
        let allTags = try context.fetch(.tags(.typeIs(.year), order: .reverse))
        let targets = [2_031, 2_025, 2_024, 2_021]
        let options = YearlyItemDuplicationOptions(includeSingleItems: true)
        let fromTags = try #require(
            YearlyItemDuplicationSelectionOperations.suggestion(
                context: context,
                yearTags: allTags,
                targetYears: targets,
                minimumGroupCount: 1,
                options: options
            )
        )
        let fromStore = try #require(
            try YearlyItemDuplicationSelectionOperations.suggestion(
                context: context,
                targetYears: targets,
                minimumGroupCount: 1,
                options: options
            )
        )
        #expect(fromTags.sourceYear == 2_023 && fromStore.sourceYear == 2_023)
        #expect(fromTags.plan.entries.allSatisfy { $0.sourceItem.ledgerIdentifier == .default })
        var source = 2_030
        var target = 2_031
        YearlyItemDuplicationSelectionOperations.alignSelection(
            context: context,
            yearTags: allTags,
            sourceYear: &source,
            targetYear: &target,
            preserveCurrentSelection: preserve,
            currentYear: 2_025,
            minimumGroupCount: 1,
            options: options
        )
        #expect(source == 2_023)
        #expect(target == (preserve ? 2_031 : 2_024))
        source = 2_030
        target = 2_031
        try YearlyItemDuplicationSelectionOperations.alignSelection(
            context: context,
            sourceYear: &source,
            targetYear: &target,
            preserveCurrentSelection: preserve,
            currentYear: 2_025,
            minimumGroupCount: 1,
            options: options
        )
        #expect(source == 2_023)
    }

    @Test(arguments: [0, 99])
    func explicitForeignYearsNeverProduceAnEmptySuggestion(threshold: Int) throws {
        let context = ModelContext(try ModelContainerFactory.inMemory())
        let other = try LedgerOperations.create(context: context, name: "Other")
        let empty = try LedgerOperations.create(context: context, name: "Empty")
        _ = try item(context: context, year: 2_023, owner: .default)
        _ = try item(context: context, year: 2_030, owner: other.id)
        try context.save()
        let options = YearlyItemDuplicationOptions(includeSingleItems: true)
        let suggestion = try #require(
            YearlyItemDuplicationSelectionOperations.suggestion(
                context: context,
                sourceYears: [2_030, 2_023],
                targetYears: [2_031, 2_024],
                minimumGroupCount: threshold,
                options: options
            )
        )
        #expect(suggestion.sourceYear == 2_023)
        #expect(!suggestion.plan.entries.isEmpty)
        #expect(
            YearlyItemDuplicationSelectionOperations.suggestion(
                context: context,
                sourceYears: [2_030],
                targetYears: [2_031],
                minimumGroupCount: threshold,
                options: options,
                ledgerIdentifier: empty.id
            ) == nil
        )
    }
}

private extension LedgerYearSelectionTests {
    func candidateFixture() throws -> ModelContext {
        let context = ModelContext(try ModelContainerFactory.inMemory())
        let other = try LedgerOperations.create(context: context, name: "Other")
        let empty = try LedgerOperations.create(context: context, name: "Empty")
        let olderYear = 2_020
        let recentYear = 2_023
        let nextYear = 2_024
        let foreignYear = 2_030
        for year in [olderYear, recentYear] {
            _ = try item(context: context, year: year, owner: .default)
        }
        for year in [recentYear, nextYear, foreignYear] {
            _ = try item(context: context, year: year, owner: other.id)
        }
        _ = try IncomesLibrary.Tag.create(context: context, name: "2040", type: .year)
        try context.save()
        try assertAvailableYears(context: context, other: other.id, empty: empty.id)
        return context
    }

    func assertAvailableYears(
        context: ModelContext,
        other: LedgerIdentifier,
        empty: LedgerIdentifier
    ) throws {
        let olderYear = 2_020
        let recentYear = 2_023
        let nextYear = 2_024
        let foreignYear = 2_030
        let defaultYears = [recentYear, olderYear]
        let otherYears = [foreignYear, nextYear, recentYear]
        let currentYear = 2_035
        let tags = try context.fetch(.tags(.typeIs(.year), order: .reverse))
        for (owner, years) in [
            (LedgerIdentifier.default, defaultYears), (other, otherYears), (empty, [currentYear])
        ] {
            #expect(
                try YearlyItemDuplicationSelectionOperations.availableSourceYears(
                    context: context,
                    currentYear: currentYear,
                    ledgerIdentifier: owner
                ) == years
            )
            #expect(
                YearlyItemDuplicationSelectionOperations.availableSourceYears(
                    from: tags,
                    ledgerIdentifier: owner,
                    currentYear: currentYear
                ) == years
            )
        }
    }

    func item(context: ModelContext, year: Int, owner: LedgerIdentifier, day: Int = 1) throws -> Item {
        let date = try #require(Calendar.utc.date(from: .init(year: year, month: 1, day: day)))
        return try Item.create(
            context: context,
            values: .init(
                date: Calendar.current.shiftedDate(componentsFrom: date, in: .utc),
                content: "Plan",
                income: 100,
                outgo: .zero,
                category: "Shared",
                priority: .zero,
                ledgerIdentifier: owner
            ),
            repeatID: .init()
        )
    }
}
