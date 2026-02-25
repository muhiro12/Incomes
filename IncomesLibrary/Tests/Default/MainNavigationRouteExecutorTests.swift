import Foundation
@testable import IncomesLibrary
import SwiftData
import Testing

struct MainNavigationRouteExecutorTests {
    let context: ModelContext

    init() {
        context = testContext
    }

    @Test
    func execute_returns_settings_for_settings_route() throws {
        let outcome = try MainNavigationRouteExecutor.execute(
            route: .settings,
            context: context
        )

        switch outcome {
        case .settings:
            break
        case .destination,
             .search,
             .settingsSubscription,
             .settingsLicense,
             .settingsDebug,
             .yearlyDuplication,
             .introduction,
             .duplicateTags,
             .itemDetail:
            Issue.record("Expected .settings outcome.")
        }
    }

    @Test
    func execute_returns_settings_subscription_for_settings_subscription_route() throws {
        let outcome = try MainNavigationRouteExecutor.execute(
            route: .settingsSubscription,
            context: context
        )

        switch outcome {
        case .settingsSubscription:
            break
        case .destination,
             .search,
             .settings,
             .settingsLicense,
             .settingsDebug,
             .yearlyDuplication,
             .introduction,
             .duplicateTags,
             .itemDetail:
            Issue.record("Expected .settingsSubscription outcome.")
        }
    }

    @Test
    func execute_returns_settings_license_for_settings_license_route() throws {
        let outcome = try MainNavigationRouteExecutor.execute(
            route: .settingsLicense,
            context: context
        )

        switch outcome {
        case .settingsLicense:
            break
        case .destination,
             .search,
             .settings,
             .settingsSubscription,
             .settingsDebug,
             .yearlyDuplication,
             .introduction,
             .duplicateTags,
             .itemDetail:
            Issue.record("Expected .settingsLicense outcome.")
        }
    }

    @Test
    func execute_returns_settings_debug_for_settings_debug_route() throws {
        let outcome = try MainNavigationRouteExecutor.execute(
            route: .settingsDebug,
            context: context
        )

        switch outcome {
        case .settingsDebug:
            break
        case .destination,
             .search,
             .settings,
             .settingsSubscription,
             .settingsLicense,
             .yearlyDuplication,
             .introduction,
             .duplicateTags,
             .itemDetail:
            Issue.record("Expected .settingsDebug outcome.")
        }
    }

    @Test
    func execute_returns_year_summary_destination_for_year_summary_route() throws {
        let yearTag = try Tag.create(
            context: context,
            name: "2026",
            type: .year
        )
        let outcome = try MainNavigationRouteExecutor.execute(
            route: .yearSummary(2_026),
            context: context
        )

        switch outcome {
        case .destination(let yearTagID, let selectedTag):
            #expect(yearTagID == yearTag.persistentModelID)
            let selectedTag = try #require(selectedTag)
            #expect(selectedTag.persistentModelID == yearTag.persistentModelID)
        case .search,
             .settings,
             .settingsSubscription,
             .settingsLicense,
             .settingsDebug,
             .yearlyDuplication,
             .introduction,
             .duplicateTags,
             .itemDetail:
            Issue.record("Expected .destination outcome for year summary route.")
        }
    }

    @Test
    func execute_returns_yearly_duplication_for_yearly_duplication_route() throws {
        let outcome = try MainNavigationRouteExecutor.execute(
            route: .yearlyDuplication,
            context: context
        )

        switch outcome {
        case .yearlyDuplication:
            break
        case .destination,
             .search,
             .settings,
             .settingsSubscription,
             .settingsLicense,
             .settingsDebug,
             .introduction,
             .duplicateTags,
             .itemDetail:
            Issue.record("Expected .yearlyDuplication outcome.")
        }
    }

    @Test
    func execute_returns_introduction_for_introduction_route() throws {
        let outcome = try MainNavigationRouteExecutor.execute(
            route: .introduction,
            context: context
        )

        switch outcome {
        case .introduction:
            break
        case .destination,
             .search,
             .settings,
             .settingsSubscription,
             .settingsLicense,
             .settingsDebug,
             .yearlyDuplication,
             .duplicateTags,
             .itemDetail:
            Issue.record("Expected .introduction outcome.")
        }
    }

    @Test
    func execute_returns_duplicate_tags_for_duplicate_tags_route() throws {
        let outcome = try MainNavigationRouteExecutor.execute(
            route: .duplicateTags,
            context: context
        )

        switch outcome {
        case .duplicateTags:
            break
        case .destination,
             .search,
             .settings,
             .settingsSubscription,
             .settingsLicense,
             .settingsDebug,
             .yearlyDuplication,
             .introduction,
             .itemDetail:
            Issue.record("Expected .duplicateTags outcome.")
        }
    }

    @Test
    func execute_returns_search_for_search_route() throws {
        let outcome = try MainNavigationRouteExecutor.execute(
            route: .search(query: "rent"),
            context: context
        )

        switch outcome {
        case .search(let query):
            #expect(query == "rent")
        case .destination,
             .settings,
             .settingsSubscription,
             .settingsLicense,
             .settingsDebug,
             .yearlyDuplication,
             .introduction,
             .duplicateTags,
             .itemDetail:
            Issue.record("Expected .search outcome.")
        }
    }

    @Test
    func execute_resolves_year_destination() throws {
        let yearTag = try Tag.create(
            context: context,
            name: "2026",
            type: .year
        )
        let outcome = try MainNavigationRouteExecutor.execute(
            route: .year(2_026),
            context: context
        )

        switch outcome {
        case .destination(let yearTagID, let selectedTag):
            #expect(yearTagID == yearTag.persistentModelID)
            #expect(selectedTag == nil)
        case .search,
             .settings,
             .settingsSubscription,
             .settingsLicense,
             .settingsDebug,
             .yearlyDuplication,
             .introduction,
             .duplicateTags,
             .itemDetail:
            Issue.record("Expected .destination outcome for year route.")
        }
    }

    @Test
    func execute_resolves_month_destination() throws {
        let yearTag = try Tag.create(
            context: context,
            name: "2026",
            type: .year
        )
        let yearMonthTag = try Tag.create(
            context: context,
            name: "202602",
            type: .yearMonth
        )
        let outcome = try MainNavigationRouteExecutor.execute(
            route: .month(year: 2_026, month: 2),
            context: context
        )

        switch outcome {
        case .destination(let yearTagID, let selectedTag):
            #expect(yearTagID == yearTag.persistentModelID)
            let selectedTag = try #require(selectedTag)
            #expect(selectedTag.persistentModelID == yearMonthTag.persistentModelID)
        case .search,
             .settings,
             .settingsSubscription,
             .settingsLicense,
             .settingsDebug,
             .yearlyDuplication,
             .introduction,
             .duplicateTags,
             .itemDetail:
            Issue.record("Expected .destination outcome for month route.")
        }
    }

    @Test
    func execute_resolves_home_destination_from_loader_state() throws {
        let now = Date.now
        let yearTag = try Tag.create(
            context: context,
            name: now.stringValueWithoutLocale(.yyyy),
            type: .year
        )
        let yearMonthTag = try Tag.create(
            context: context,
            name: now.stringValueWithoutLocale(.yyyyMM),
            type: .yearMonth
        )
        let outcome = try MainNavigationRouteExecutor.execute(
            route: .home,
            context: context
        )

        switch outcome {
        case .destination(let yearTagID, let selectedTag):
            #expect(yearTagID == yearTag.persistentModelID)
            let selectedTag = try #require(selectedTag)
            #expect(selectedTag.persistentModelID == yearMonthTag.persistentModelID)
        case .search,
             .settings,
             .settingsSubscription,
             .settingsLicense,
             .settingsDebug,
             .yearlyDuplication,
             .introduction,
             .duplicateTags,
             .itemDetail:
            Issue.record("Expected .destination outcome for home route.")
        }
    }

    @Test
    func execute_returns_item_detail_for_item_route() throws {
        let item = try Item.create(
            context: context,
            date: .now,
            content: "Rent",
            income: 1_000,
            outgo: 400,
            category: "Fixed",
            priority: 1,
            repeatID: UUID()
        )
        let itemID = try item.id.base64Encoded()
        let outcome = try MainNavigationRouteExecutor.execute(
            route: .item(itemID),
            context: context
        )

        switch outcome {
        case .itemDetail(let resolvedItemID):
            #expect(resolvedItemID == item.id)
        case .destination,
             .search,
             .settings,
             .settingsSubscription,
             .settingsLicense,
             .settingsDebug,
             .yearlyDuplication,
             .introduction,
             .duplicateTags:
            Issue.record("Expected .itemDetail outcome for item route.")
        }
    }

    @Test
    func execute_falls_back_to_destination_for_invalid_item_route() throws {
        let outcome = try MainNavigationRouteExecutor.execute(
            route: .item("invalid"),
            context: context
        )

        switch outcome {
        case .destination:
            break
        case .search,
             .settings,
             .settingsSubscription,
             .settingsLicense,
             .settingsDebug,
             .yearlyDuplication,
             .introduction,
             .duplicateTags,
             .itemDetail:
            Issue.record("Expected fallback .destination outcome for invalid item route.")
        }
    }
}
