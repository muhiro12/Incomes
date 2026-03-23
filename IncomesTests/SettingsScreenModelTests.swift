import Foundation
@testable import Incomes
import IncomesLibrary
import SwiftData
import Testing

@MainActor
struct SettingsScreenModelTests {
    @Test
    func authorization_presentation_maps_notification_states() {
        let model = SettingsScreenModel()

        #expect(
            model.authorizationPresentation(for: .authorized) == .authorized
        )
        #expect(
            model.authorizationPresentation(for: .denied) == .denied
        )
        #expect(
            model.authorizationPresentation(for: .notDetermined) == .notDetermined
        )
    }

    @Test
    func load_status_detects_duplicate_tags_and_debug_data() throws {
        let modelContainer = try IncomesPlatformEnvironmentFactory.makePreviewModelContainer()
        let context = modelContainer.mainContext
        _ = Tag.createIgnoringDuplicates(
            context: context,
            name: "Rent",
            type: .category
        )
        _ = Tag.createIgnoringDuplicates(
            context: context,
            name: "Rent",
            type: .category
        )
        _ = Tag.createIgnoringDuplicates(
            context: context,
            name: "Sample Debug",
            type: .debug
        )
        let model = SettingsScreenModel()

        model.loadStatus(context: context)

        #expect(model.hasDuplicateTags)
        #expect(model.hasDebugData)
    }

    @Test
    func load_status_refreshes_after_cleanup() throws {
        let modelContainer = try IncomesPlatformEnvironmentFactory.makePreviewModelContainer()
        let context = modelContainer.mainContext
        let firstTag = Tag.createIgnoringDuplicates(
            context: context,
            name: "Rent",
            type: .category
        )
        let secondTag = Tag.createIgnoringDuplicates(
            context: context,
            name: "Rent",
            type: .category
        )
        let debugTag = Tag.createIgnoringDuplicates(
            context: context,
            name: "Sample Debug",
            type: .debug
        )
        let model = SettingsScreenModel()

        model.loadStatus(context: context)
        TagService.delete(tag: firstTag)
        TagService.delete(tag: secondTag)
        TagService.delete(tag: debugTag)
        model.loadStatus(context: context)

        #expect(model.hasDuplicateTags == false)
        #expect(model.hasDebugData == false)
    }
}
