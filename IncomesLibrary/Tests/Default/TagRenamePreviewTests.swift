import Foundation
@testable import IncomesLibrary
import SwiftData
import Testing

struct TagRenamePreviewTests {
    let context: ModelContext
    let testOutgo: Decimal = 10

    init() {
        context = testContext
    }

    @Test
    func previewCategoryRename_marks_unchanged_name() throws {
        let tag = try createCategoryTag(
            name: "Food",
            itemCount: 1
        )

        let preview = try TagService.previewCategoryRename(
            context: context,
            tag: tag,
            to: "  Food  "
        )

        #expect(preview.normalizedTargetName == "Food")
        #expect(preview.affectedItemCount == 1)
        #expect(preview.validationError == nil)
        #expect(preview.isUnchanged)
        #expect(preview.canApply == false)
    }

    @Test
    func previewCategoryRename_marks_invalid_target() throws {
        let tag = try createCategoryTag(
            name: "Food",
            itemCount: 2
        )

        let preview = try TagService.previewCategoryRename(
            context: context,
            tag: tag,
            to: "Others"
        )

        #expect(preview.normalizedTargetName == nil)
        #expect(preview.affectedItemCount == 2)
        #expect(preview.validationError == .invalidTarget)
        #expect(preview.isUnchanged == false)
        #expect(preview.canApply == false)
    }

    @Test
    func previewCategoryRename_marks_duplicate_target() throws {
        let sourceTag = try createCategoryTag(
            name: "Food",
            itemCount: 2
        )
        _ = try createCategoryTag(
            name: "Travel",
            itemCount: 1
        )

        let preview = try TagService.previewCategoryRename(
            context: context,
            tag: sourceTag,
            to: "Travel"
        )

        #expect(preview.normalizedTargetName == "Travel")
        #expect(preview.affectedItemCount == 2)
        #expect(preview.validationError == .duplicateTargetName)
        #expect(preview.isUnchanged == false)
        #expect(preview.canApply == false)
    }

    @Test
    func previewCategoryRename_reports_affected_item_count_for_valid_rename() throws {
        let tag = try createCategoryTag(
            name: "Food",
            itemCount: 3
        )

        let preview = try TagService.previewCategoryRename(
            context: context,
            tag: tag,
            to: "Travel"
        )

        #expect(preview.normalizedTargetName == "Travel")
        #expect(preview.affectedItemCount == 3)
        #expect(preview.validationError == nil)
        #expect(preview.isUnchanged == false)
        #expect(preview.canApply)
    }
}

private extension TagRenamePreviewTests {
    func createCategoryTag(
        name: String,
        itemCount: Int
    ) throws -> IncomesLibrary.Tag {
        for index in 0..<itemCount {
            _ = try createItem(
                content: "\(name)-\(index)",
                category: name
            )
        }

        return try #require(
            try TagService.getByName(
                context: context,
                name: name,
                type: .category
            )
        )
    }

    func createItem(
        content: String,
        category: String
    ) throws -> Item {
        try Item.create(
            context: context,
            date: .now,
            content: content,
            income: .zero,
            outgo: testOutgo,
            category: category,
            priority: 0,
            repeatID: .init()
        )
    }
}
