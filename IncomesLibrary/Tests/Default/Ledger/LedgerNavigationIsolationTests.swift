import Foundation
import SwiftData
import Testing

@testable import IncomesLibrary

@MainActor
struct LedgerNavigationIsolationTests {
    private let incomeAmount: Decimal = 10

    @Test
    func navigationResolvesThePhysicalDateTagsUsedByEachBook() throws {
        let context = ModelContext(try ModelContainerFactory.inMemory())
        let other = try LedgerOperations.create(context: context, name: "Other").id
        let standardItem = try makeItem(context: context, owner: .default)
        let otherItem = try makeItem(context: context, owner: other)
        _ = IncomesLibrary.Tag.createIgnoringDuplicates(context: context, name: "2026", type: .year)
        _ = IncomesLibrary.Tag.createIgnoringDuplicates(context: context, name: "202601", type: .yearMonth)
        try context.save()
        let years = try context.fetch(.tags(.nameIs("2026", type: .year)))
        let months = try context.fetch(.tags(.nameIs("202601", type: .yearMonth)))
        attach(year: years[0], month: months[0], to: standardItem)
        attach(year: years[1], month: months[1], to: otherItem)
        try context.save()
        for (owner, index) in [(LedgerIdentifier.default, 0), (other, 1)] {
            let state = try MainNavigationOperations.loadState(
                context: context,
                date: otherItem.localDate,
                ledgerIdentifier: owner
            )
            #expect(state.yearTag?.id == years[index].id)
            #expect(state.yearMonthTag?.id == months[index].id)
            let route = try MainNavigationOperations.execute(
                route: .month(year: 2_026, month: 1),
                context: context,
                ledgerIdentifier: owner
            )
            guard case let .destination(yearTagID, selectedTag) = route else {
                Issue.record("Expected a month destination")
                continue
            }
            #expect(yearTagID == years[index].id)
            #expect(selectedTag?.id == months[index].id)
        }
    }

    @Test
    func anEmptyBookDoesNotSelectAnotherBooksYearOrMonth() throws {
        let context = ModelContext(try ModelContainerFactory.inMemory())
        let other = try LedgerOperations.create(context: context, name: "Other").id
        let item = try makeItem(context: context, owner: other)
        try context.save()
        let state = try MainNavigationOperations.loadState(context: context, date: item.localDate)
        #expect(state.yearTag == nil)
        #expect(state.yearMonthTag == nil)
    }
}

private extension LedgerNavigationIsolationTests {
    func attach(year: IncomesLibrary.Tag, month: IncomesLibrary.Tag, to item: Item) {
        item.modify(tags: (item.tags ?? []).filter { $0.type != .year && $0.type != .yearMonth } + [year, month])
    }

    func makeItem(context: ModelContext, owner: LedgerIdentifier) throws -> Item {
        try Item.create(
            context: context,
            values: .init(
                date: shiftedDate("2026-01-01T00:00:00Z"),
                content: "Saved",
                income: incomeAmount,
                outgo: 0,
                category: "General",
                priority: 0,
                ledgerIdentifier: owner
            ),
            repeatID: UUID()
        )
    }
}
