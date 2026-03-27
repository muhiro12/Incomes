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
        #expect(status.hasDebugData == false)
    }

    @Test
    func load_detects_duplicate_tags_and_debug_data() throws {
        _ = Tag.createIgnoringDuplicates(context: context, name: "A", type: .content)
        _ = Tag.createIgnoringDuplicates(context: context, name: "A", type: .content)
        _ = try ItemService.seedSampleData(
            context: context,
            profile: .debug,
            ignoringDuplicates: true
        )

        let status = try SettingsStatusLoader.load(context: context)
        #expect(status.hasDuplicateTags == true)
        #expect(status.hasDebugData == true)
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
        #expect(initialStatus.hasDebugData == true)

        TagService.delete(tag: firstTag)
        TagService.delete(tag: secondTag)
        TagService.delete(tag: debugTag)

        let refreshedStatus = try SettingsStatusLoader.load(context: context)
        #expect(refreshedStatus.hasDuplicateTags == false)
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

        try TagService.resolveAllDuplicates(context: context)

        let resolvedStatus = try SettingsStatusLoader.load(context: context)
        #expect(resolvedStatus.hasDuplicateTags == false)
    }
}
