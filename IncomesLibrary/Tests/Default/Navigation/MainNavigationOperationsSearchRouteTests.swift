@testable import IncomesLibrary
import SwiftData
import Testing

struct MainNavigationOperationsSearchRouteTests {
    let context: ModelContext

    init() {
        context = testContext
    }

    @Test
    func execute_resolves_search_query_to_matching_content_tag() throws {
        let tag = try Tag.create(
            context: context,
            name: "Payday",
            type: .content
        )
        let outcome = try MainNavigationOperations.execute(
            route: .search(query: "Payday"),
            context: context
        )

        switch outcome {
        case let .search(query, predicate):
            #expect(query == "Payday")
            guard case .tagIs(let resolvedTag) = predicate else {
                Issue.record("Expected .tagIs predicate.")
                return
            }
            #expect(resolvedTag.persistentModelID == tag.persistentModelID)
        case .destination,
             .settings,
             .settingsSubscription,
             .settingsLicense,
             .settingsDebug,
             .yearlyDuplication,
             .duplicateTags,
             .orphanTags,
             .itemDetail:
            Issue.record("Expected .search outcome.")
        }
    }
}
