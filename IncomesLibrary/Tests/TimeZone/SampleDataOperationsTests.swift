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
    func seedTutorialDataIfNeeded_creates_items_and_debug_tag() throws {
        try SampleDataOperations.seedTutorialIfNeeded(
            context: context,
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
    func seedTutorialDataIfNeeded_is_idempotent_when_not_empty() throws {
        try SampleDataOperations.seedTutorialIfNeeded(
            context: context,
            baseDate: shiftedDate("2000-01-03T12:00:00Z")
        )
        try SampleDataOperations.seedTutorialIfNeeded(
            context: context,
            baseDate: shiftedDate("2000-01-10T12:00:00Z")
        )
        #expect(fetchItems(context).count == 3)
    }

    @Test
    func seedSampleData_creates_debug_items_when_ignoring_duplicates() throws {
        try SampleDataOperations.seed(
            context: context,
            profile: .debug,
            baseDate: shiftedDate("2000-01-03T12:00:00Z"),
            ignoringDuplicates: true,
            ifEmptyOnly: false
        )

        #expect(fetchItems(context).count == 24)
        #expect(try SampleDataOperations.hasDebugData(context: context))
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
            profile: .preview,
            baseDate: shiftedDate("2000-01-03T12:00:00Z"),
            ignoringDuplicates: false,
            ifEmptyOnly: true
        )

        #expect(fetchItems(context).count == 1)
    }

    @Test
    func seedDuplicateTagPreviewData_creates_duplicate_category_tags() throws {
        try SampleDataOperations.seed(
            context: context,
            profile: .preview,
            baseDate: shiftedDate("2000-01-03T12:00:00Z"),
            ifEmptyOnly: false
        )
        #expect(try SettingsStatusOperations.load(context: context).hasDuplicateTags == false)

        try SampleDataOperations.seedDuplicateTagPreviewData(context: context)

        #expect(try SettingsStatusOperations.load(context: context).hasDuplicateTags)
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

    // MARK: - Delete

    @Test
    func deleteDebugData_removes_items_and_tags() throws {
        try SampleDataOperations.seedTutorialIfNeeded(
            context: context,
            baseDate: shiftedDate("2000-01-03T12:00:00Z")
        )
        #expect(try SampleDataOperations.hasDebugData(context: context))

        try SampleDataOperations.deleteDebugData(context: context)

        let debugTags = try context.fetch(.tags(.typeIs(.debug)))
        #expect(debugTags.isEmpty)
        #expect(fetchItems(context).isEmpty)
        #expect(!(try SampleDataOperations.hasDebugData(context: context)))
    }
}
