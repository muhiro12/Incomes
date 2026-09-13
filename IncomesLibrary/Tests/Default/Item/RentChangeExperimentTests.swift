import Foundation
@testable import IncomesLibrary
import SwiftData
import Testing

/// Characterizes the existing projection boundary for the rent-change experiment.
@Suite(.serialized)
struct RentChangeExperimentTests {
    let context: ModelContext

    init() throws {
        let container = try ModelContainer(
            for: Item.self,
            configurations: .init(
                isStoredInMemoryOnly: true,
                cloudKitDatabase: .none
            )
        )
        context = .init(container)
        context.autosaveEnabled = false
        try seedFixture()
    }

    @Test
    func increase_matches_manual_input_without_changing_records() throws {
        let target = try rent(in: 10)
        let before = try snapshots()
        let tagCount = try context.fetchCount(FetchDescriptor<IncomesLibrary.Tag>())
        let hadChanges = context.hasChanges
        let assisted = try comparison(target: target, outgo: target.outgo + 5_000)
        let manual = try comparison(target: target, outgo: 85_000)

        #expect(assisted == manual)
        #expect(assisted.projected.changedItemCount == 3)
        #expect(assisted.monthlyBalances.map(\.currentBalance) == [70_000, 40_000, 10_000])
        #expect(assisted.monthlyBalances.map(\.projectedBalance) == [65_000, 30_000, -5_000])
        #expect(assisted.monthlyBalances.map(\.difference) == [-5_000, -10_000, -15_000])
        #expect(assisted.current.minimumBalance == 10_000)
        #expect(assisted.projected.minimumBalance == -5_000)
        #expect(assisted.projected.firstNegativeDate == date("2026-12-28"))
        #expect(try rent(in: 9).outgo == 80_000)
        #expect(try snapshots() == before)
        #expect(try context.fetchCount(FetchDescriptor<IncomesLibrary.Tag>()) == tagCount)
        #expect(context.hasChanges == hadChanges)
    }

    @Test
    func this_month_only_has_a_different_impact_from_future_items() throws {
        let target = try rent(in: 10)
        let comparison = try ItemBalanceProjectionOperations.previewUpdateComparison(
            context: context,
            item: target,
            input: input(target: target, outgo: 85_000),
            scope: .thisItem
        )

        #expect(comparison.projected.changedItemCount == 1)
        #expect(comparison.monthlyBalances.map(\.difference) == [-5_000, -5_000, -5_000])
        #expect(comparison.projected.firstNegativeDate == nil)
    }

    @Test
    func manual_single_month_override_is_outside_the_original_series() throws {
        let november = try rent(in: 11)
        try updateItem(
            context: context,
            item: november,
            input: input(target: november, outgo: 90_000)
        )
        let target = try rent(in: 10)
        let futureItems = try context.fetch(
            .items(.repeatIDAndDateIsAfter(repeatID: target.repeatID, date: target.localDate))
        )
        let before = try snapshots()
        let comparison = try comparison(target: target, outgo: 85_000)

        // A manual single-row edit detaches that row from its original series.
        #expect(november.repeatID != target.repeatID)
        #expect(futureItems.count == 2)
        #expect(comparison.monthlyBalances.map(\.difference) == [-5_000, -5_000, -10_000])
        #expect(comparison.latestBalanceDifference != -15_000)
        #expect(try snapshots() == before)
    }

    @Test
    func nonuniform_series_cannot_treat_a_replacement_as_an_increase() throws {
        let november = try rent(in: 11)
        // Reproduce a nonuniform series that can be represented by imported data.
        try november.modify(
            values: .init(formInput: input(target: november, outgo: 90_000)),
            repeatID: november.repeatID
        )
        let before = try snapshots()
        let target = try rent(in: 10)
        let futureItems = try context.fetch(
            .items(.repeatIDAndDateIsAfter(repeatID: target.repeatID, date: target.localDate))
        )
        let comparison = try comparison(target: target, outgo: 85_000)

        #expect(Set(futureItems.map(\.outgo)).count == 2)
        #expect(comparison.monthlyBalances.map(\.difference) == [-5_000, 0, -5_000])
        #expect(comparison.latestBalanceDifference != -15_000)
        #expect(try snapshots() == before)
    }

    @Test
    func changing_the_source_date_is_not_selecting_next_month() throws {
        let september = try rent(in: 9)
        let comparison = try ItemBalanceProjectionOperations.previewUpdateComparison(
            context: context,
            item: september,
            input: .init(
                date: date("2026-10-28"),
                content: september.content,
                income: september.income,
                outgo: 85_000,
                category: september.category?.name ?? "",
                priority: september.priority
            ),
            scope: .futureItems
        )

        // Anchor the proposal to the existing October row instead of moving September.
        #expect(comparison.projected.changedItemCount == 4)
        #expect(comparison.projected.affectedDateRange?.upperBound == date("2027-01-28"))
    }
}

private extension RentChangeExperimentTests {
    enum Fixture {
        static let openingBalance = 130_000
        static let monthlyIncome = 50_000
        static let monthlyRent = 80_000
        static let monthCount = 4
    }

    struct Snapshot: Equatable {
        let id: PersistentIdentifier
        let date: Date
        let content: String
        let income: Decimal
        let outgo: Decimal
        let balance: Decimal
        let priority: Int
        let repeatID: UUID
        let tags: Set<PersistentIdentifier>
    }

    func seedFixture() throws {
        try createItem(
            context: context,
            input: .init(
                date: date("2026-09-01"),
                content: "Opening balance",
                income: Decimal(Fixture.openingBalance),
                outgo: 0,
                category: "Opening"
            )
        )
        try createItem(
            context: context,
            input: .init(
                date: date("2026-09-25"),
                content: "Income",
                income: Decimal(Fixture.monthlyIncome),
                outgo: 0,
                category: "Income"
            ),
            repeatCount: Fixture.monthCount
        )
        try createItem(
            context: context,
            input: .init(
                date: date("2026-09-28"),
                content: "Rent",
                income: 0,
                outgo: Decimal(Fixture.monthlyRent),
                category: "Housing"
            ),
            repeatCount: Fixture.monthCount
        )
    }

    func date(_ value: String) -> Date {
        Calendar.current.startOfDay(for: shiftedDate("\(value)T12:00:00Z"))
    }

    func rent(in month: Int) throws -> Item {
        let items = try context.fetch(.items(.all, order: .forward))
        return try #require(items.first { item in
            item.content == "Rent" && Calendar.current.component(.month, from: item.localDate) == month
        })
    }

    func input(target: Item, outgo: Decimal) -> ItemFormInput {
        .init(
            date: target.localDate,
            content: target.content,
            income: target.income,
            outgo: outgo,
            category: target.category?.name ?? "",
            priority: target.priority
        )
    }

    func comparison(target: Item, outgo: Decimal) throws -> ItemBalanceProjectionOperations.Comparison {
        try ItemBalanceProjectionOperations.previewUpdateComparison(
            context: context,
            item: target,
            input: input(target: target, outgo: outgo),
            scope: .futureItems
        )
    }

    func snapshots() throws -> [Snapshot] {
        try context.fetch(.items(.all, order: .forward)).map { item in
            .init(
                id: item.persistentModelID,
                date: item.utcDate,
                content: item.content,
                income: item.income,
                outgo: item.outgo,
                balance: item.balance,
                priority: item.priority,
                repeatID: item.repeatID,
                tags: Set((item.tags ?? []).map(\.persistentModelID))
            )
        }
    }
}
