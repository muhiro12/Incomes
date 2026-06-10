@testable import IncomesLibrary
import SwiftData
import Testing

struct MainNavigationYearTagRouteTests {
    let context: ModelContext

    init() {
        context = testContext
    }

    @Test
    func routeForYearTag_returnsYearRouteForValidYearTag() throws {
        let yearTag = try Tag.create(
            context: context,
            name: "2026",
            type: .year
        )

        #expect(MainNavigationOperations.route(forYearTag: yearTag) == .year(2_026))
    }

    @Test
    func routeForYearTag_returnsNilForInvalidYearTagName() throws {
        let yearTag = try Tag.create(
            context: context,
            name: "10000",
            type: .year
        )

        #expect(MainNavigationOperations.route(forYearTag: yearTag) == nil)
    }

    @Test
    func routeForYearTag_returnsNilForNonYearTag() throws {
        let categoryTag = try Tag.create(
            context: context,
            name: "2026",
            type: .category
        )

        #expect(MainNavigationOperations.route(forYearTag: categoryTag) == nil)
    }
}
