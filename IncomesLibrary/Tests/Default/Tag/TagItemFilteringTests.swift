import Foundation
@testable import IncomesLibrary
import SwiftData
import Testing

struct TagItemFilteringTests {
    struct YearFixture {
        let firstItem: Item
        let secondItem: Item
        let yearString: String
    }

    let context: ModelContext

    init() {
        context = testContext
    }

    @Test
    func items_filters_by_year_string_and_sorts() throws {
        let fixture = try seedYearFilteringItems(includeThirdYear: true)
        let tag = try #require(
            fixture.firstItem.tags?.first { tag in
                tag.type == .category
            }
        )
        let items = TagQueryOperations.items(
            for: tag,
            yearString: fixture.yearString
        )

        assertYearFilteredItems(items, fixture: fixture, tag: tag)
    }

    @Test
    func items_filters_by_year_string_after_refetch() throws {
        let fixture = try seedYearFilteringItems()
        let fetchedCategoryTag = try context.fetchFirst(
            .tags(.nameIs("Category", type: .category))
        )
        let categoryTag = try #require(fetchedCategoryTag)

        let items = TagQueryOperations.items(
            for: categoryTag,
            yearString: fixture.yearString
        )

        assertYearFilteredItems(items, fixture: fixture, tag: categoryTag)
    }

    @Test
    func items_filters_by_year_string_after_save() throws {
        let fixture = try seedYearFilteringItems()
        try context.save()

        let fetchedCategoryTag = try context.fetchFirst(
            .tags(.nameIs("Category", type: .category))
        )
        let categoryTag = try #require(fetchedCategoryTag)

        let items = TagQueryOperations.items(
            for: categoryTag,
            yearString: fixture.yearString
        )

        assertYearFilteredItems(items, fixture: fixture, tag: categoryTag)
    }

    @Test
    func category_tag_is_deduplicated_for_same_name() throws {
        _ = try Item.create(
            context: context,
            values: .init(
                date: shiftedDate("2001-01-01T00:00:00Z"),
                content: "First",
                income: 0,
                outgo: 1,
                category: "Category",
                priority: 0
            ),
            repeatID: .init()
        )
        _ = try Item.create(
            context: context,
            values: .init(
                date: shiftedDate("2001-03-01T00:00:00Z"),
                content: "Second",
                income: 0,
                outgo: 2,
                category: "Category",
                priority: 0
            ),
            repeatID: .init()
        )

        let matchingTags = try context.fetch(
            .tags(.nameIs("Category", type: .category))
        )

        if matchingTags.count != 1, let tag = matchingTags.first {
            logDiagnostics(
                tag: tag,
                yearString: "2001"
            )
        }

        #expect(matchingTags.count == 1)
    }

    private func seedYearFilteringItems(
        includeThirdYear: Bool = false
    ) throws -> YearFixture {
        let firstDate = shiftedDate("2001-01-01T00:00:00Z")
        let secondDate = shiftedDate("2001-03-01T00:00:00Z")
        let firstItem = try createFilteringItem(
            date: firstDate,
            content: "First",
            outgo: 1
        )
        let secondItem = try createFilteringItem(
            date: secondDate,
            content: "Second",
            outgo: 2
        )
        if includeThirdYear {
            _ = try createFilteringItem(
                date: shiftedDate("2002-01-01T00:00:00Z"),
                content: "Third",
                outgo: 3
            )
        }
        return .init(
            firstItem: firstItem,
            secondItem: secondItem,
            yearString: firstDate.stringValueWithoutLocale(.yyyy)
        )
    }

    private func createFilteringItem(
        date: Date,
        content: String,
        outgo: Decimal
    ) throws -> Item {
        try Item.create(
            context: context,
            values: .init(
                date: date,
                content: content,
                income: 0,
                outgo: outgo,
                category: "Category",
                priority: 0
            ),
            repeatID: .init()
        )
    }

    private func assertYearFilteredItems(
        _ items: [Item],
        fixture: YearFixture,
        tag: IncomesLibrary.Tag
    ) {
        if items.count != 2
            || items.first?.id != fixture.secondItem.id
            || items.last?.id != fixture.firstItem.id {
            logDiagnostics(
                tag: tag,
                yearString: fixture.yearString
            )
        }

        #expect(items.count == 2)
        #expect(items.first?.id == fixture.secondItem.id)
        #expect(items.last?.id == fixture.firstItem.id)
    }

    private func logDiagnostics(
        tag: IncomesLibrary.Tag,
        yearString: String
    ) {
        guard let tagType = tag.type else {
            print("TagItemFilteringTests diagnostics: missing tag type.")
            return
        }
        let matchingTags = (try? context.fetch(
            .tags(.nameIs(tag.name, type: tagType))
        )) ?? []
        print("TagItemFilteringTests diagnostics: name=\(tag.name) type=\(tagType) matches=\(matchingTags.count)")
        for (index, match) in matchingTags.enumerated() {
            let itemYears = (match.items ?? []).map { item in
                item.year?.name ?? "nil"
            }
            print("  match[\(index)] id=\(match.persistentModelID) items=\((match.items ?? []).count) years=\(itemYears)") // swiftlint:disable:this line_length
        }
        let filtered = TagQueryOperations.items(for: tag, yearString: yearString)
        let filteredYears = filtered.map { item in
            item.year?.name ?? "nil"
        }
        print("  filtered items=\(filtered.count) years=\(filteredYears)")
    }
}
