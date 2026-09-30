import Foundation
@testable import IncomesLibrary
import SwiftData
import Testing

struct SampleDataOperationsTests {
    let context: ModelContext

    init() {
        context = testContext
    }

    // MARK: - Seed

    @Test
    func seedMinimal_creates_items_and_debug_tag() throws {
        try SampleDataOperations.seed(
            context: context,
            profile: .minimal,
            baseDate: shiftedDate("2000-01-03T12:00:00Z")
        )

        let items = fetchItems(context)
        #expect(items.count == 3)

        let debugTags = try context.fetch(.tags(.typeIs(.debug)))
        #expect(!debugTags.isEmpty)
        #expect(debugTags.flatMap { tag in
            tag.items ?? []
        }.count == 3)
    }

    @Test
    func seedMinimal_is_idempotent_when_ifEmptyOnly_and_not_empty() throws {
        try SampleDataOperations.seed(
            context: context,
            profile: .minimal,
            baseDate: shiftedDate("2000-01-03T12:00:00Z"),
            ifEmptyOnly: true
        )
        try SampleDataOperations.seed(
            context: context,
            profile: .minimal,
            baseDate: shiftedDate("2000-01-10T12:00:00Z"),
            ifEmptyOnly: true
        )
        #expect(fetchItems(context).count == 3)
    }

    @Test
    func seedSampleData_skips_when_ifEmptyOnly_and_items_exist() throws {
        _ = try createItem(
            context: context,
            input: .init(
                date: shiftedDate("2000-01-01T12:00:00Z"),
                content: "Seeded",
                income: 100,
                outgo: .zero,
                category: "Seed",
                priority: 0
            ),
            repeatCount: 1
        )

        try SampleDataOperations.seed(
            context: context,
            profile: .standard,
            baseDate: shiftedDate("2000-01-03T12:00:00Z"),
            ifEmptyOnly: true
        )

        #expect(fetchItems(context).count == 1)
    }

    @Test
    func seedStandard_creates_two_year_ledger_with_opening_payday() throws {
        try SampleDataOperations.seed(
            context: context,
            profile: .standard,
            baseDate: shiftedDate("2000-06-03T12:00:00Z")
        )

        let items = fetchItems(context)
        let years = Set(items.map { item in
            Calendar.current.component(.year, from: item.localDate)
        })
        #expect(items.count == 217)
        #expect(years == [1_999, 2_000, 2_001])
        #expect(items.allSatisfy { item in
            item.tags?.contains { tag in
                tag.type == .debug
            } == true
        })
    }

    @Test
    func seedStandard_scales_amounts_with_the_given_locale() throws {
        let baseDate = shiftedDate("2000-06-03T12:00:00Z")
        let englishContext = testContext
        let japaneseContext = testContext

        try SampleDataOperations.seed(
            context: englishContext,
            profile: .standard,
            baseDate: baseDate,
            locale: Locale(identifier: "en_US")
        )
        try SampleDataOperations.seed(
            context: japaneseContext,
            profile: .standard,
            baseDate: baseDate,
            locale: Locale(identifier: "ja_JP")
        )

        #expect(fetchItems(englishContext).map(\.income).max() == 4_500)
        #expect(fetchItems(japaneseContext).map(\.income).max() == 450_000)
    }

    @Test
    func seedLargeLedger_spans_ten_years_of_standard_months() throws {
        try SampleDataOperations.seed(
            context: context,
            profile: .largeLedger,
            baseDate: shiftedDate("2000-06-03T12:00:00Z")
        )

        let items = fetchItems(context)
        let years = items.map { item in
            Calendar.current.component(.year, from: item.localDate)
        }
        #expect(items.count == 1_081)
        #expect(years.min() == 1_991)
        #expect(years.max() == 2_001)
    }

    @Test
    func seedDuplicateTags_creates_duplicates_of_every_tag_type() throws {
        try SampleDataOperations.seed(
            context: context,
            profile: .duplicateTags,
            baseDate: shiftedDate("2000-01-03T12:00:00Z")
        )

        let duplicatedTypes = Set(
            Dictionary(grouping: try context.fetch(.tags(.all))) { tag in
                tag.typeID + tag.name
            }
            .values
            .filter { tags in
                tags.count > 1
            }
            .compactMap { tags in
                tags.first?.type
            }
        )
        #expect(duplicatedTypes == [.year, .yearMonth, .content, .category])
        #expect(try SettingsStatusOperations.load(context: context).hasDuplicateTags)
    }

    @Test
    func seedDuplicateTags_leaves_existing_items_untouched() throws {
        let existingItem = try createItem(
            context: context,
            input: .init(
                date: shiftedDate("2000-01-01T12:00:00Z"),
                content: "Existing",
                income: .zero,
                outgo: 100,
                category: ItemSampleDataSeeder.duplicateTagCategoryName,
                priority: 0
            ),
            repeatCount: 1
        )
        let existingTagIDs = Set((existingItem.tags ?? []).map(\.persistentModelID))

        try SampleDataOperations.seed(
            context: context,
            profile: .duplicateTags,
            baseDate: shiftedDate("2000-01-03T12:00:00Z")
        )

        #expect(Set((existingItem.tags ?? []).map(\.persistentModelID)) == existingTagIDs)
    }

    @Test
    func seedLargeAmounts_spans_positive_and_negative_millions() throws {
        try SampleDataOperations.seed(
            context: context,
            profile: .largeAmounts,
            baseDate: shiftedDate("2000-06-03T12:00:00Z")
        )

        let items = fetchItems(context)
        let balances = items.map(\.balance)
        #expect(items.count == 12)
        #expect(Set(items.map { item in
            Calendar.current.component(.year, from: item.localDate)
        }) == [2_000])
        #expect(balances.max() == 1_250_000)
        #expect(balances.min() == -1_750_000)
        #expect(items.contains { $0.outgo == 1_000_000 })
        #expect(try SampleDataOperations.hasDebugData(context: context))
    }

    @Test
    func seedInexactTotals_creates_amounts_beyond_exact_totals() throws {
        try SampleDataOperations.seed(
            context: context,
            profile: .inexactTotals,
            baseDate: shiftedDate("2000-06-03T12:00:00Z")
        )

        let items = fetchItems(context)
        #expect(items.count == 2)
        #expect(throws: (any Error).self) {
            try ItemSummaryOperations.totals(for: items)
        }
    }

    // MARK: - Delete

    @Test
    func deleteDebugData_removes_items_and_tags() throws {
        try SampleDataOperations.seed(
            context: context,
            profile: .minimal,
            baseDate: shiftedDate("2000-01-03T12:00:00Z")
        )
        #expect(try SampleDataOperations.hasDebugData(context: context))

        try SampleDataOperations.deleteDebugData(context: context)

        let debugTags = try context.fetch(.tags(.typeIs(.debug)))
        #expect(debugTags.isEmpty)
        #expect(fetchItems(context).isEmpty)
        #expect(!(try SampleDataOperations.hasDebugData(context: context)))
    }

    @Test
    func deleteDebugData_removes_the_whole_standard_ledger() throws {
        try SampleDataOperations.seed(
            context: context,
            profile: .standard,
            baseDate: shiftedDate("2000-01-03T12:00:00Z")
        )

        try SampleDataOperations.deleteDebugData(context: context)

        #expect(fetchItems(context).isEmpty)
    }
}
