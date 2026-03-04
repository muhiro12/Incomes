import Foundation
@testable import IncomesLibrary
import SwiftData
import Testing

struct UpcomingPaymentNotificationPresentationBuilderTests {
    let context: ModelContext

    init() {
        context = testContext
    }

    @Test
    func build_assigns_stable_identifiers_routes_threads_and_badges() throws {
        let firstItem = try ItemService.create(
            context: context,
            date: shiftedDate("2024-01-20T00:00:00Z"),
            content: "Rent",
            income: .zero,
            outgo: 900,
            category: "Housing",
            priority: 0,
            repeatCount: 1
        )
        let secondItem = try ItemService.create(
            context: context,
            date: shiftedDate("2024-01-22T00:00:00Z"),
            content: "Insurance",
            income: .zero,
            outgo: 700,
            category: "Bills",
            priority: 0,
            repeatCount: 1
        )
        let thirdItem = try ItemService.create(
            context: context,
            date: shiftedDate("2024-02-05T00:00:00Z"),
            content: "Gym",
            income: .zero,
            outgo: 650,
            category: "Health",
            priority: 0,
            repeatCount: 1
        )

        let firstPlan = UpcomingPaymentPlanner.PlannedPayment(
            item: firstItem,
            notifyDate: shiftedDate("2024-01-17T09:00:00Z")
        )
        let secondPlan = UpcomingPaymentPlanner.PlannedPayment(
            item: secondItem,
            notifyDate: shiftedDate("2024-01-19T09:00:00Z")
        )
        let thirdPlan = UpcomingPaymentPlanner.PlannedPayment(
            item: thirdItem,
            notifyDate: shiftedDate("2024-02-02T09:00:00Z")
        )

        var settings = NotificationSettings()
        settings.thresholdAmount = 500

        let presentations = UpcomingPaymentNotificationPresentationBuilder.build(
            plans: [thirdPlan, secondPlan, firstPlan],
            settings: settings,
            now: shiftedDate("2024-01-01T00:00:00Z")
        )

        #expect(presentations.count == 3)

        let firstPresentation = try #require(presentations.first)
        let secondPresentation = try #require(presentations.dropFirst().first)
        let thirdPresentation = try #require(presentations.last)

        let firstIdentifier = try firstItem.id.base64Encoded()
        let thirdIdentifier = try thirdItem.id.base64Encoded()

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
        #expect(firstPresentation.threadIdentifier == "upcoming-payment:2024-01")
        #expect(secondPresentation.threadIdentifier == "upcoming-payment:2024-01")
        #expect(thirdPresentation.threadIdentifier == "upcoming-payment:2024-02")
        #expect(firstPresentation.targetContentIdentifier == firstIdentifier)
        #expect(firstPresentation.summaryArgument == "Rent")
        #expect(firstPresentation.summaryArgumentCount == 1)
        #expect(firstPresentation.badgeCount == 1)
        #expect(secondPresentation.badgeCount == 2)
        #expect(thirdPresentation.badgeCount == 3)
        #expect(firstPresentation.daysUntilDue == 3)
        #expect(
            thirdPresentation.requestIdentifier ==
                "\(UpcomingPaymentNotificationPresentation.requestIdentifierPrefix)\(thirdIdentifier)"
        )
    }

    @Test
    func build_increases_relevance_for_nearer_and_larger_payments() throws {
        let lowAttentionItem = try ItemService.create(
            context: context,
            date: shiftedDate("2024-01-20T00:00:00Z"),
            content: "Streaming",
            income: .zero,
            outgo: 500,
            category: "Fun",
            priority: 0,
            repeatCount: 1
        )
        let highAttentionItem = try ItemService.create(
            context: context,
            date: shiftedDate("2024-01-11T00:00:00Z"),
            content: "Mortgage",
            income: .zero,
            outgo: 1_500,
            category: "Housing",
            priority: 0,
            repeatCount: 1
        )

        let lowAttentionPlan = UpcomingPaymentPlanner.PlannedPayment(
            item: lowAttentionItem,
            notifyDate: shiftedDate("2024-01-14T09:00:00Z")
        )
        let highAttentionPlan = UpcomingPaymentPlanner.PlannedPayment(
            item: highAttentionItem,
            notifyDate: shiftedDate("2024-01-10T09:00:00Z")
        )

        var settings = NotificationSettings()
        settings.thresholdAmount = 500

        let presentations = UpcomingPaymentNotificationPresentationBuilder.build(
            plans: [lowAttentionPlan, highAttentionPlan],
            settings: settings,
            now: shiftedDate("2024-01-01T00:00:00Z")
        )

        let lowAttention = try #require(
            presentations.first {
                $0.itemContent == "Streaming"
            }
        )
        let highAttention = try #require(
            presentations.first {
                $0.itemContent == "Mortgage"
            }
        )

        #expect(lowAttention.daysUntilDue == 6)
        #expect(highAttention.daysUntilDue == 1)
        #expect(highAttention.relevanceScore > lowAttention.relevanceScore)
    }

    @Test
    func build_clamps_relevance_and_sets_active_interruption_level() throws {
        let lowUrgencyItem = try ItemService.create(
            context: context,
            date: shiftedDate("2024-01-20T00:00:00Z"),
            content: "Cloud Storage",
            income: .zero,
            outgo: .zero,
            category: "Bills",
            priority: 0,
            repeatCount: 1
        )
        let highUrgencyItem = try ItemService.create(
            context: context,
            date: shiftedDate("2024-01-10T00:00:00Z"),
            content: "Tax",
            income: .zero,
            outgo: 10_000,
            category: "Bills",
            priority: 0,
            repeatCount: 1
        )

        let lowUrgencyPlan = UpcomingPaymentPlanner.PlannedPayment(
            item: lowUrgencyItem,
            notifyDate: shiftedDate("2024-01-10T09:00:00Z")
        )
        let highUrgencyPlan = UpcomingPaymentPlanner.PlannedPayment(
            item: highUrgencyItem,
            notifyDate: shiftedDate("2024-01-10T09:00:00Z")
        )

        var settings = NotificationSettings()
        settings.thresholdAmount = 500

        let presentations = UpcomingPaymentNotificationPresentationBuilder.build(
            plans: [lowUrgencyPlan, highUrgencyPlan],
            settings: settings,
            now: shiftedDate("2024-01-01T00:00:00Z")
        )

        let lowUrgency = try #require(
            presentations.first {
                $0.itemContent == "Cloud Storage"
            }
        )
        let highUrgency = try #require(
            presentations.first {
                $0.itemContent == "Tax"
            }
        )

        #expect(lowUrgency.relevanceScore == 0.40)
        #expect(highUrgency.relevanceScore == 1.0)
        #expect(lowUrgency.interruptionLevel == .active)
        #expect(highUrgency.interruptionLevel == .active)
    }
}
