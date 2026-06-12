import Foundation
@testable import IncomesLibrary
import SwiftData
import Testing

struct UpcomingPaymentItemTargetSupportTests {
    let context: ModelContext

    init() {
        context = testContext
    }

    @Test
    func targetContentIdentifier_returnsPersistentIdentifier() throws {
        let item = try item()
        let identifier = try PersistentIdentifierCoder.encode(item.id)

        #expect(
            UpcomingPaymentItemTargetSupport.targetContentIdentifier(
                for: item
            ) == identifier
        )
    }

    @Test
    func primaryRouteURL_prefersItemRoute() throws {
        let item = try item()
        let identifier = try PersistentIdentifierCoder.encode(item.id)

        #expect(
            UpcomingPaymentItemTargetSupport.primaryRouteURL(for: item) ==
                IncomesDeepLinkURLBuilder.preferredItemURL(for: identifier)
        )
    }

    @Test
    func secondaryRouteURL_returnsMonthRoute() throws {
        let item = try item()
        let calendar = Calendar(identifier: .gregorian)

        #expect(
            UpcomingPaymentItemTargetSupport.secondaryRouteURL(
                for: item,
                calendar: calendar
            ) == IncomesDeepLinkURLBuilder.preferredMonthURL(
                for: item.localDate,
                calendar: calendar
            )
        )
    }
}

private extension UpcomingPaymentItemTargetSupportTests {
    static let outgo: Decimal = 120_000

    func item() throws -> Item {
        try createItem(
            context: context,
            date: shiftedDate("2026-01-10T00:00:00Z"),
            content: "Rent",
            income: .zero,
            outgo: Self.outgo,
            category: "Housing",
            priority: 0,
            repeatCount: 1
        )
    }
}
