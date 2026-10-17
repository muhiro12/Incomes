import Foundation
import SwiftData
import Testing

@testable import IncomesLibrary

@MainActor
struct LedgerSurfaceIsolationTests {
    @Test
    func widgetsWatchAndUnqualifiedReadsStayInTheDefaultBook() throws {
        let context = ModelContext(try ModelContainerFactory.inMemory())
        let other = try LedgerOperations.create(context: context, name: "Other")
        for (owner, income) in [(LedgerIdentifier.default, 100), (other.id, 900)] {
            _ = try makeItem(context: context, owner: owner, income: Decimal(income), repeatID: UUID())
        }
        try context.save()
        let wires = try WatchSyncOperations.recentItemWires(
            context: context,
            baseDate: .now,
            monthOffsets: [0]
        )
        #expect(wires.count == 1 && wires.first?.income == 100)
        #expect(try ItemSummaryOperations.monthlyTotals(context: context, date: .now).totalIncome == 100)
        #expect(try ItemQueryOperations.items(context: context).count == 1)
        let conditions = ItemSearchConditions()
        let additional = try NaturalLanguageSearchOperations.results(
            context: context,
            conditions: conditions,
            ledgerIdentifier: other.id
        )
        #expect(additional.items.count == 1 && additional.items.first?.income == 900)
    }

    @Test
    func repeatEditingAndDeletionDoNotCrossTheBookBoundary() throws {
        let context = ModelContext(try ModelContainerFactory.inMemory())
        let other = try LedgerOperations.create(context: context, name: "Other")
        let series = UUID()
        let standard = try makeItem(context: context, owner: .default, income: 100, repeatID: series)
        let additional = try makeItem(context: context, owner: other.id, income: 900, repeatID: series)
        try context.save()
        try ItemUpdateOperations.update(
            context: context,
            item: additional,
            input: .init(
                date: additional.localDate,
                content: "Changed",
                incomeText: "50",
                outgoText: "0",
                category: "Same",
                priorityText: "0",
                ledgerIdentifier: other.id
            ),
            scope: .allItems
        )
        #expect(standard.income == 100 && standard.content == "Same")
        #expect(additional.income == 50 && additional.ledgerIdentifier == other.id)
        _ = try ItemDeletionOperations.deleteWithOutcome(context: context, items: [additional])
        #expect(try ItemQueryOperations.items(context: context).map(\.id) == [standard.id])
        #expect(try LedgerOperations.ledger(other.id, context: context).isAvailable)
    }

    @Test
    func resultLimitsAndNearestItemQueriesApplyAfterLedgerMembership() throws {
        let context = ModelContext(try ModelContainerFactory.inMemory())
        let selected = try LedgerOperations.create(context: context, name: "Selected")
        let other = try LedgerOperations.create(context: context, name: "Other")
        let rows = try [other.id, selected.id, other.id, selected.id, other.id].enumerated().map { offset, owner in
            try makeItem(context: context, owner: owner, income: 10, repeatID: UUID(), dayOffset: offset)
        }
        let first = try #require(rows.first { $0.ledgerIdentifier == selected.id })
        let last = try #require(rows.last { $0.ledgerIdentifier == selected.id })
        try context.save()
        for (order, expected) in [(SortOrder.forward, first), (.reverse, last)] {
            var descriptor = ItemFetchDescriptor.items(.all, order: order, ledgerIdentifier: selected.id)
            descriptor.fetchLimit = 1
            #expect(try context.fetch(descriptor).map(\.id) == [expected.id])
            #expect(try context.fetchFirst(descriptor)?.id == expected.id)
        }
        let result = try NaturalLanguageSearchOperations.results(
            context: context, conditions: .init(), limit: 1, ledgerIdentifier: selected.id
        )
        #expect(result.items.map(\.id) == [last.id])
        #expect(result.hasMoreItems)
    }

    private func makeItem(
        context: ModelContext,
        owner: LedgerIdentifier,
        income: Decimal,
        repeatID: UUID,
        dayOffset: Int = .zero
    ) throws -> Item {
        let date = try #require(Calendar.current.date(byAdding: .day, value: dayOffset, to: .now))
        return try Item.create(
            context: context,
            values: .init(
                date: date,
                content: "Same",
                income: income,
                outgo: 0,
                category: "Same",
                priority: 0,
                ledgerIdentifier: owner
            ),
            repeatID: repeatID
        )
    }
}
