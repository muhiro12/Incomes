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
        _ = try Tag.createIgnoringDuplicates(context: context, name: "A", type: .content)
        _ = try Tag.createIgnoringDuplicates(context: context, name: "A", type: .content)
        _ = try ItemService.seedSampleData(
            context: context,
            profile: .debug,
            ignoringDuplicates: true
        )

        let status = try SettingsStatusLoader.load(context: context)
        #expect(status.hasDuplicateTags == true)
        #expect(status.hasDebugData == true)
    }
}
