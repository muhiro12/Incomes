import Foundation
@testable import IncomesLibrary
import SwiftData
import Testing

struct UpcomingPaymentPresentationTests {
    let context: ModelContext

    init() {
        context = testContext
    }

    @Test
    func build_assigns_stable_identifiers_routes_threads_and_badges() throws {
        let fixture = try stableIdentifierFixture()
        let presentations = fixture.presentations

        #expect(presentations.count == 3)

        let firstPresentation = try #require(presentations.first)
        let secondPresentation = try #require(presentations.dropFirst().first)
        let thirdPresentation = try #require(presentations.last)

        let firstIdentifier = try PersistentIdentifierCoder.encode(fixture.firstItem.id)
        let thirdIdentifier = try PersistentIdentifierCoder.encode(fixture.thirdItem.id)

        assertRouteIdentifiers(
            firstPresentation: firstPresentation,
            firstItem: fixture.firstItem,
            firstIdentifier: firstIdentifier,
            thirdPresentation: thirdPresentation,
            thirdIdentifier: thirdIdentifier
        )
        assertThreadsAndBadges(
            firstPresentation: firstPresentation,
            secondPresentation: secondPresentation,
            thirdPresentation: thirdPresentation
        )
    }

    @Test
    func build_increases_relevance_for_nearer_and_larger_payments() throws {
        let lowAttentionItem = try createPaymentItem(
            date: "2024-01-20T00:00:00Z",
            content: "Streaming",
            outgo: 500,
            category: "Fun"
        )
        let highAttentionItem = try createPaymentItem(
            date: "2024-01-11T00:00:00Z",
            content: "Mortgage",
            outgo: 1_500,
            category: "Housing"
        )

        let presentations = paymentPresentations(
            plans: [
                plannedPayment(item: lowAttentionItem, notifyDate: "2024-01-14T09:00:00Z"),
                plannedPayment(item: highAttentionItem, notifyDate: "2024-01-10T09:00:00Z")
            ]
        )
        let lowAttention = try presentation(content: "Streaming", in: presentations)
        let highAttention = try presentation(content: "Mortgage", in: presentations)

        #expect(lowAttention.daysUntilDue == 6)
        #expect(highAttention.daysUntilDue == 1)
        #expect(highAttention.relevanceScore > lowAttention.relevanceScore)
    }

    @Test
    func build_clamps_relevance_and_sets_active_interruption_level() throws {
        let lowUrgencyItem = try createPaymentItem(
            date: "2024-01-20T00:00:00Z",
            content: "Cloud Storage",
            outgo: .zero,
            category: "Bills"
        )
        let highUrgencyItem = try createPaymentItem(
            date: "2024-01-10T00:00:00Z",
            content: "Tax",
            outgo: 10_000,
            category: "Bills"
        )

        let presentations = paymentPresentations(
            plans: [
                plannedPayment(item: lowUrgencyItem, notifyDate: "2024-01-10T09:00:00Z"),
                plannedPayment(item: highUrgencyItem, notifyDate: "2024-01-10T09:00:00Z")
            ]
        )
        let lowUrgency = try presentation(content: "Cloud Storage", in: presentations)
        let highUrgency = try presentation(content: "Tax", in: presentations)

        #expect(lowUrgency.relevanceScore == 0.40)
        #expect(highUrgency.relevanceScore == 1.0)
        #expect(lowUrgency.interruptionLevel == .active)
        #expect(highUrgency.interruptionLevel == .active)
    }
}

// Test fixture values are intentionally literal to keep scenarios readable.
// swiftlint:disable no_magic_numbers
private extension UpcomingPaymentPresentationTests {
    struct StableIdentifierFixture {
        let firstItem: Item
        let thirdItem: Item
        let presentations: [UpcomingPaymentNotificationPresentation]
    }

    func stableIdentifierFixture() throws -> StableIdentifierFixture {
        let firstItem = try createPaymentItem(
            date: "2024-01-20T00:00:00Z",
            content: "Rent",
            outgo: 900,
            category: "Housing"
        )
        let secondItem = try createPaymentItem(
            date: "2024-01-22T00:00:00Z",
            content: "Insurance",
            outgo: 700,
            category: "Bills"
        )
        let thirdItem = try createPaymentItem(
            date: "2024-02-05T00:00:00Z",
            content: "Gym",
            outgo: 650,
            category: "Health"
        )
        return .init(
            firstItem: firstItem,
            thirdItem: thirdItem,
            presentations: stableIdentifierPresentations(
                firstItem: firstItem,
                secondItem: secondItem,
                thirdItem: thirdItem
            )
        )
    }

    func stableIdentifierPresentations(
        firstItem: Item,
        secondItem: Item,
        thirdItem: Item
    ) -> [UpcomingPaymentNotificationPresentation] {
        paymentPresentations(
            plans: [
                plannedPayment(item: thirdItem, notifyDate: "2024-02-02T09:00:00Z"),
                plannedPayment(item: secondItem, notifyDate: "2024-01-19T09:00:00Z"),
                plannedPayment(item: firstItem, notifyDate: "2024-01-17T09:00:00Z")
            ]
        )
    }

    func paymentPresentations(
        plans: [UpcomingPaymentOperations.PlannedPayment]
    ) -> [UpcomingPaymentNotificationPresentation] {
        var settings = NotificationSettings()
        settings.thresholdAmount = 500
        return UpcomingPaymentOperations.notificationPresentations(
            plans: plans,
            settings: settings,
            now: shiftedDate("2024-01-01T00:00:00Z")
        )
    }

    func createPaymentItem(
        date: String,
        content: String,
        outgo: Decimal,
        category: String
    ) throws -> Item {
        try createItem(
            context: context,
            input: .init(
                date: shiftedDate(date),
                content: content,
                income: .zero,
                outgo: outgo,
                category: category,
                priority: 0
            ),
            repeatCount: 1
        )
    }

    func plannedPayment(
        item: Item,
        notifyDate: String
    ) -> UpcomingPaymentOperations.PlannedPayment {
        .init(
            item: item,
            notifyDate: shiftedDate(notifyDate)
        )
    }

    func presentation(
        content: String,
        in presentations: [UpcomingPaymentNotificationPresentation]
    ) throws -> UpcomingPaymentNotificationPresentation {
        try #require(
            presentations.first { presentation in
                presentation.itemContent == content
            }
        )
    }

    func assertRouteIdentifiers(
        firstPresentation: UpcomingPaymentNotificationPresentation,
        firstItem: Item,
        firstIdentifier: String,
        thirdPresentation: UpcomingPaymentNotificationPresentation,
        thirdIdentifier: String
    ) {
        #expect(
            firstPresentation.requestIdentifier ==
                "\(UpcomingPaymentNotificationPresentation.requestIdentifierPrefix)\(firstIdentifier)"
        )
        #expect(
            firstPresentation.primaryRouteURL ==
                IncomesDeepLinkURLBuilder.preferredItemURL(for: firstIdentifier)
        )
        #expect(
            firstPresentation.secondaryRouteURL ==
                IncomesDeepLinkURLBuilder.preferredMonthURL(for: firstItem.localDate)
        )
        #expect(firstPresentation.targetContentIdentifier == firstIdentifier)
        #expect(
            thirdPresentation.requestIdentifier ==
                "\(UpcomingPaymentNotificationPresentation.requestIdentifierPrefix)\(thirdIdentifier)"
        )
    }

    func assertThreadsAndBadges(
        firstPresentation: UpcomingPaymentNotificationPresentation,
        secondPresentation: UpcomingPaymentNotificationPresentation,
        thirdPresentation: UpcomingPaymentNotificationPresentation
    ) {
        #expect(firstPresentation.threadIdentifier == "upcoming-payment:2024-01")
        #expect(secondPresentation.threadIdentifier == "upcoming-payment:2024-01")
        #expect(thirdPresentation.threadIdentifier == "upcoming-payment:2024-02")
        #expect(firstPresentation.summaryArgument == "Rent")
        #expect(firstPresentation.summaryArgumentCount == 1)
        #expect(firstPresentation.badgeCount == 1)
        #expect(secondPresentation.badgeCount == 2)
        #expect(thirdPresentation.badgeCount == 3)
        #expect(firstPresentation.daysUntilDue == 3)
    }
}
// swiftlint:enable no_magic_numbers
