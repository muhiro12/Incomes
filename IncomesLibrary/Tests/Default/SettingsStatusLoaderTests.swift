import Foundation
@testable import IncomesLibrary
import SwiftData
import Testing

struct SettingsStatusLoaderTests {
    let context: ModelContext

    init() {
        context = testContext
    }

    @Test
    func load_returns_false_when_empty() throws {
        let status = try SettingsStatusLoader.load(context: context)
        #expect(status.hasDuplicateTags == false)
        #expect(status.hasOrphanTags == false)
        #expect(status.hasDebugData == false)
    }

    @Test
    func load_detects_duplicate_tags_and_debug_data() throws {
        _ = Tag.createIgnoringDuplicates(context: context, name: "A", type: .content)
        _ = Tag.createIgnoringDuplicates(context: context, name: "A", type: .content)
        _ = try ItemSampleDataSeeder.seedSampleData(
            context: context,
            profile: .debug,
            ignoringDuplicates: true
        )

        let status = try SettingsStatusLoader.load(context: context)
        #expect(status.hasDuplicateTags == true)
        #expect(status.hasOrphanTags == true)
        #expect(status.hasDebugData == true)
    }

    @Test
    func load_detects_orphan_tags_without_other_flags() throws {
        _ = Tag.createIgnoringDuplicates(
            context: context,
            name: "Unused",
            type: .content
        )

        let status = try SettingsStatusLoader.load(context: context)

        #expect(status.hasDuplicateTags == false)
        #expect(status.hasOrphanTags == true)
        #expect(status.hasDebugData == false)
    }

    @Test
    func load_returns_false_after_duplicate_tags_and_debug_data_are_removed() throws {
        let firstTag = Tag.createIgnoringDuplicates(
            context: context,
            name: "A",
            type: .content
        )
        let secondTag = Tag.createIgnoringDuplicates(
            context: context,
            name: "A",
            type: .content
        )
        let debugTag = Tag.createIgnoringDuplicates(
            context: context,
            name: "Sample Debug",
            type: .debug
        )

        let initialStatus = try SettingsStatusLoader.load(context: context)
        #expect(initialStatus.hasDuplicateTags == true)
        #expect(initialStatus.hasOrphanTags == true)
        #expect(initialStatus.hasDebugData == true)

        TagOperations.delete(tag: firstTag)
        TagOperations.delete(tag: secondTag)
        TagOperations.delete(tag: debugTag)

        let refreshedStatus = try SettingsStatusLoader.load(context: context)
        #expect(refreshedStatus.hasDuplicateTags == false)
        #expect(refreshedStatus.hasOrphanTags == false)
        #expect(refreshedStatus.hasDebugData == false)
    }

    @Test
    func load_returns_false_after_duplicate_tags_are_resolved() throws {
        _ = Tag.createIgnoringDuplicates(
            context: context,
            name: "A",
            type: .content
        )
        _ = Tag.createIgnoringDuplicates(
            context: context,
            name: "A",
            type: .content
        )

        let initialStatus = try SettingsStatusLoader.load(context: context)
        #expect(initialStatus.hasDuplicateTags == true)
        #expect(initialStatus.hasOrphanTags == true)

        try TagOperations.resolveAllDuplicates(context: context)

        let resolvedStatus = try SettingsStatusLoader.load(context: context)
        #expect(resolvedStatus.hasDuplicateTags == false)
        #expect(resolvedStatus.hasOrphanTags == true)
    }

    @Test
    func load_returns_false_after_orphan_tags_are_removed() throws {
        _ = Tag.createIgnoringDuplicates(
            context: context,
            name: "Unused",
            type: .content
        )

        let initialStatus = try SettingsStatusLoader.load(context: context)
        #expect(initialStatus.hasOrphanTags == true)

        try TagOperations.deleteAllOrphanTags(context: context)

        let refreshedStatus = try SettingsStatusLoader.load(context: context)
        #expect(refreshedStatus.hasOrphanTags == false)
    }
}
