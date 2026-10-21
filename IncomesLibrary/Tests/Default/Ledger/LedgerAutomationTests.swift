import Foundation
@testable import IncomesLibrary
import SwiftData
import Testing

@MainActor
struct LedgerAutomationTests {
    @Test
    func context_export_captures_all_ledgers_and_refuses_missing_ownership_without_writing() throws {
        let context = testContext
        let ledger = try LedgerOperations.create(context: context, name: "Export")
        let date = shiftedDate("2000-06-15T00:00:00Z")
        _ = try item(context: context, ledger: .default, date: date, income: 10)
        let additional = try item(context: context, ledger: ledger.id, date: date, income: 900)
        try context.save()
        let exported = try ItemExportOperations.prepareFile(context: context)
        #expect(exported.items.count == 2)
        #expect(!context.hasChanges)
        additional.modify(tags: (additional.tags ?? []).filter { $0.type?.isLedgerOwnership != true })
        try context.save()
        #expect(throws: LedgerError.missingOwnership) {
            try ItemExportOperations.prepareFile(context: context)
        }
        #expect(!context.hasChanges)
    }

    @Test
    func relative_automation_queries_keep_omitted_scope_and_explicit_scope_separate() throws {
        let context = testContext
        let ledger = try LedgerOperations.create(context: context, name: "Automation")
        let date = shiftedDate("2000-06-15T00:00:00Z")
        let standard = try item(context: context, ledger: .default, date: date, income: 10)
        let additional = try item(context: context, ledger: ledger.id, date: date, income: 900)
        try context.save()

        for direction in [ItemRelativeQueryOperations.Direction.next, .previous] {
            let offset = direction == .next ? -1 : 1
            let reference = try #require(Calendar.current.date(byAdding: .day, value: offset, to: date))
            #expect(try ItemRelativeQueryOperations.item(
                context: context, date: reference, direction: direction
            ) == standard)
            #expect(try ItemRelativeQueryOperations.item(
                context: context, date: reference, direction: direction, ledgerIdentifier: ledger.id
            ) == additional)
            #expect(try ItemRelativeQueryOperations.items(
                context: context, date: reference, direction: direction, ledgerIdentifier: ledger.id
            ) == [additional])
            #expect(try ItemRelativeQueryOperations.netIncome(
                context: context, date: reference, direction: direction, ledgerIdentifier: ledger.id
            ) == 900)
            #expect(try ItemRelativeQueryOperations.content(
                context: context, date: reference, direction: direction, ledgerIdentifier: ledger.id
            ) == additional.content)
            #expect(try ItemRelativeQueryOperations.localDate(
                context: context, date: reference, direction: direction, ledgerIdentifier: ledger.id
            ) == date)
        }
        #expect(!context.hasChanges)
    }

    @Test
    func monthly_automation_context_does_not_mix_matching_categories_in_other_ledgers() throws {
        let context = testContext
        let ledger = try LedgerOperations.create(context: context, name: "Automation")
        let date = shiftedDate("2000-06-15T00:00:00Z")
        _ = try item(context: context, ledger: .default, date: date, income: 10)
        _ = try item(context: context, ledger: ledger.id, date: date, income: 900)
        _ = try item(context: context, ledger: ledger.id, date: shiftedDate("2000-05-15T00:00:00Z"), income: 400)
        try context.save()
        let standard = try MonthlySummaryOperations.loadContext(context: context, date: date, currencyCode: "JPY")
        let additional = try MonthlySummaryOperations.loadContext(
            context: context, date: date, currencyCode: "JPY", ledgerIdentifier: ledger.id
        )
        #expect(standard.currentTotals.totalIncome == 10)
        #expect(additional.currentTotals.totalIncome == 900)
        #expect(additional.previousTotals.totalIncome == 400)
        #expect(additional.categoryComparisons.first?.currentIncome == 900)
        #expect(!context.hasChanges)
    }

    @Test
    func yearly_automation_previews_and_applies_only_the_requested_ledger() throws {
        let context = testContext
        let ledger = try LedgerOperations.create(context: context, name: "Automation")
        _ = try item(context: context, ledger: .default, date: shiftedDate("2000-06-15T00:00:00Z"), income: 10)
        _ = try item(context: context, ledger: ledger.id, date: shiftedDate("2000-06-15T00:00:00Z"), income: 900)
        try context.save()
        let options = YearlyDuplicationAutomationOperations.options(
            includeSingleItems: true, minimumRepeatItemCount: 3, skipExistingItems: true
        )
        let preview = try YearlyDuplicationAutomationOperations.preview(
            context: context, sourceYear: 2_000, targetYear: 2_001, options: options, ledgerIdentifier: ledger.id
        )
        #expect(preview.itemCount == 1)
        #expect(!context.hasChanges)
        let result = try YearlyDuplicationAutomationOperations.apply(
            context: context, sourceYear: 2_000, targetYear: 2_001, options: options, ledgerIdentifier: ledger.id
        )
        #expect(result.createdCount == 1)
        #expect(try ItemQueryOperations.allItemsCount(context: context) == 1)
        let additional = try ItemQueryOperations.items(context: context, ledgerIdentifier: ledger.id)
        #expect(additional.count == 2)
        #expect(additional.allSatisfy { $0.income == 900 })
        #expect(try YearlyDuplicationAutomationOperations.sourceYears(context: context) == [2_000])
        #expect(try YearlyDuplicationAutomationOperations.sourceYears(
            context: context, ledgerIdentifier: ledger.id
        ) == [2_001, 2_000])
    }

    @Test
    func ledger_links_round_trip_and_resolve_empty_books_without_new_identifiers() throws {
        let context = testContext
        let ledger = try LedgerOperations.create(context: context, name: "Empty")
        for identifier in [LedgerIdentifier.default, ledger.id] {
            let route = IncomesRoute.ledger(identifier.rawValue)
            let url = try #require(IncomesRouteURLBuilder.customSchemeURL(for: route))
            #expect(IncomesRouteParser.parse(url: url) == route)
            #expect(MainNavigationOperations.ledgerIdentifier(forExternalRoute: route, context: context) == identifier)
            #expect(MainNavigationOperations.restorationURL(for: route) == nil)
            let monthRoute = IncomesRoute.ledgerMonth(identifier.rawValue, year: 2_000, month: 6)
            let monthURL = try #require(IncomesRouteURLBuilder.universalLinkURL(for: monthRoute))
            #expect(IncomesRouteParser.parse(url: monthURL) == monthRoute)
            #expect(MainNavigationOperations.ledgerIdentifier(
                forExternalRoute: monthRoute, context: context
            ) == identifier)
        }
        #expect(IncomesRouteParser.parse(url: try #require(URL(string: "incomes://ledger?id="))) == nil)
        #expect(MainNavigationOperations.ledgerIdentifier(
            forExternalRoute: .ledger("missing"), context: context
        ) == .default)
        #expect(!context.hasChanges)
    }
}

private extension LedgerAutomationTests {
    func item(context: ModelContext, ledger: LedgerIdentifier, date: Date, income: Decimal) throws -> Item {
        let item = try Item.create(
            context: context,
            values: .init(
                date: date,
                content: "Same",
                income: income,
                outgo: 0,
                category: "Same",
                priority: 0,
                ledgerIdentifier: ledger
            ),
            repeatID: UUID()
        )
        item.modify(balance: income)
        return item
    }
}
