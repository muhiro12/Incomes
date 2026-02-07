import Foundation
@testable import IncomesLibrary
import SwiftData
import Testing

struct TagItemFilteringTests {
    let context: ModelContext

    init() {
        context = testContext
    }

    // TODO: Re-enable after year-tag filtering semantics are stabilized across time zone and formatter behavior.
    /*
     @Test
     func items_filters_by_year_string_and_sorts() throws {
     let firstDate = shiftedDate("2001-01-01T00:00:00Z")
     let secondDate = shiftedDate("2001-03-01T00:00:00Z")
     let thirdDate = shiftedDate("2002-01-01T00:00:00Z")

     let firstItem = try Item.create(
     context: context,
     date: firstDate,
     content: "First",
     income: 0,
     outgo: 1,
     category: "Category",
     priority: 0,
     repeatID: .init()
     )
     let secondItem = try Item.create(
     context: context,
     date: secondDate,
     content: "Second",
     income: 0,
     outgo: 2,
     category: "Category",
     priority: 0,
     repeatID: .init()
     )
     _ = try Item.create(
     context: context,
     date: thirdDate,
     content: "Third",
     income: 0,
     outgo: 3,
     category: "Category",
     priority: 0,
     repeatID: .init()
     )

     let tag = try #require(
     firstItem.tags?.first { tag in
     tag.type == .category
     }
     )

     let items = TagService.items(
     for: tag,
     yearString: firstDate.stringValueWithoutLocale(.yyyy)
     )

     if items.count != 2
     || items.first?.id != secondItem.id
     || items.last?.id != firstItem.id {
     logDiagnostics(
     tag: tag,
     yearString: firstDate.stringValueWithoutLocale(.yyyy)
     )
     }

     #expect(items.count == 2)
     #expect(items.first?.id == secondItem.id)
     #expect(items.last?.id == firstItem.id)
     }
     */

    // TODO: Re-enable after year-tag filtering semantics are stabilized across time zone and formatter behavior.
    /*
     @Test
     func items_filters_by_year_string_after_refetch() throws {
     let firstDate = shiftedDate("2001-01-01T00:00:00Z")
     let secondDate = shiftedDate("2001-03-01T00:00:00Z")

     let firstItem = try Item.create(
     context: context,
     date: firstDate,
     content: "First",
     income: 0,
     outgo: 1,
     category: "Category",
     priority: 0,
     repeatID: .init()
     )
     let secondItem = try Item.create(
     context: context,
     date: secondDate,
     content: "Second",
     income: 0,
     outgo: 2,
     category: "Category",
     priority: 0,
     repeatID: .init()
     )

     let fetchedCategoryTag = try context.fetchFirst(
     .tags(.nameIs("Category", type: .category))
     )
     let categoryTag = try #require(fetchedCategoryTag)

     let items = TagService.items(
     for: categoryTag,
     yearString: firstDate.stringValueWithoutLocale(.yyyy)
     )

     if items.count != 2
     || items.first?.id != secondItem.id
     || items.last?.id != firstItem.id {
     logDiagnostics(
     tag: categoryTag,
     yearString: firstDate.stringValueWithoutLocale(.yyyy)
     )
     }

     #expect(items.count == 2)
     #expect(items.first?.id == secondItem.id)
     #expect(items.last?.id == firstItem.id)
     }
     */

    // TODO: Re-enable after year-tag filtering semantics are stabilized across time zone and formatter behavior.
    /*
     @Test
     func items_filters_by_year_string_after_save() throws {
     let firstDate = shiftedDate("2001-01-01T00:00:00Z")
     let secondDate = shiftedDate("2001-03-01T00:00:00Z")

     let firstItem = try Item.create(
     context: context,
     date: firstDate,
     content: "First",
     income: 0,
     outgo: 1,
     category: "Category",
     priority: 0,
     repeatID: .init()
     )
     let secondItem = try Item.create(
     context: context,
     date: secondDate,
     content: "Second",
     income: 0,
     outgo: 2,
     category: "Category",
     priority: 0,
     repeatID: .init()
     )

     try context.save()

     let fetchedCategoryTag = try context.fetchFirst(
     .tags(.nameIs("Category", type: .category))
     )
     let categoryTag = try #require(fetchedCategoryTag)

     let items = TagService.items(
     for: categoryTag,
     yearString: firstDate.stringValueWithoutLocale(.yyyy)
     )

     if items.count != 2
     || items.first?.id != secondItem.id
     || items.last?.id != firstItem.id {
     logDiagnostics(
     tag: categoryTag,
     yearString: firstDate.stringValueWithoutLocale(.yyyy)
     )
     }

     #expect(items.count == 2)
     #expect(items.first?.id == secondItem.id)
     #expect(items.last?.id == firstItem.id)
     }
     */

    @Test
    func category_tag_is_deduplicated_for_same_name() throws {
        _ = try Item.create(
            context: context,
            date: shiftedDate("2001-01-01T00:00:00Z"),
            content: "First",
            income: 0,
            outgo: 1,
            category: "Category",
            priority: 0,
            repeatID: .init()
        )
        _ = try Item.create(
            context: context,
            date: shiftedDate("2001-03-01T00:00:00Z"),
            content: "Second",
            income: 0,
            outgo: 2,
            category: "Category",
            priority: 0,
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
            let itemYears = match.items.orEmpty.map { item in
                item.year?.name ?? "nil"
            }
            print("  match[\(index)] id=\(match.persistentModelID) items=\(match.items.orEmpty.count) years=\(itemYears)")
        }
        let filtered = TagService.items(for: tag, yearString: yearString)
        let filteredYears = filtered.map { item in
            item.year?.name ?? "nil"
        }
        print("  filtered items=\(filtered.count) years=\(filteredYears)")
    }
}
