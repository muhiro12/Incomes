import Foundation
@testable import IncomesLibrary
import MHPlatformCore
import Testing

struct NotificationRoutePayloadTests {
    @Test
    func actionIdentifiers_useCanonicalNotificationActionValues() {
        #expect(
            NotificationRoutePayload.viewItemActionIdentifier ==
                "viewUpcomingPaymentItem"
        )
        #expect(
            NotificationRoutePayload.viewMonthActionIdentifier ==
                "viewUpcomingPaymentMonth"
        )
    }

    @Test
    func userInfo_encodes_upcoming_payment_routes_and_metadata() throws {
        let primaryRouteURL = try url("incomes://item?id=rent")
        let secondaryRouteURL = try url("incomes://month?year=2026&month=1")
        let presentation = upcomingPaymentPresentation(
            primaryRouteURL: primaryRouteURL,
            secondaryRouteURL: secondaryRouteURL,
            targetContentIdentifier: "rent"
        )

        let userInfo = NotificationRoutePayload.userInfo(for: presentation)
        let payload = try #require(NotificationRoutePayload.codec.decode(userInfo))

        #expect(payload.routes.defaultRouteURL == primaryRouteURL)
        #expect(payload.routes.fallbackRouteURL == secondaryRouteURL)
        #expect(
            payload.routes.actionRouteURLs[
                NotificationRoutePayload.viewMonthActionIdentifier
            ] == secondaryRouteURL
        )
        #expect(payload.metadata["itemIdentifier"] == "rent")
        #expect(payload.metadata["notificationKind"] == "upcomingPayment")
        #expect(MHNotificationRouteResolver.resolveRouteURL(
            payload: payload,
            response: .init(actionIdentifier: NotificationRoutePayload.viewItemActionIdentifier)
        ) == primaryRouteURL)
        #expect(MHNotificationRouteResolver.resolveRouteURL(
            payload: payload,
            response: .init(actionIdentifier: NotificationRoutePayload.viewMonthActionIdentifier)
        ) == secondaryRouteURL)
    }
}

private extension NotificationRoutePayloadTests {
    static let relevanceScore = 0.8
    static let amount: Decimal = 120_000
    static let year = 2_026
    static let month = 1
    static let dueDay = 10
    static let notifyDay = 9

    func upcomingPaymentPresentation(
        primaryRouteURL: URL,
        secondaryRouteURL: URL,
        targetContentIdentifier: String
    ) -> UpcomingPaymentNotificationPresentation {
        .init(
            requestIdentifier: "upcomingPayment.\(targetContentIdentifier)",
            primaryRouteURL: primaryRouteURL,
            secondaryRouteURL: secondaryRouteURL,
            threadIdentifier: "upcomingPayment.2026-01",
            targetContentIdentifier: targetContentIdentifier,
            summaryArgument: "Rent",
            summaryArgumentCount: 1,
            badgeCount: 1,
            daysUntilDue: 1,
            relevanceScore: Self.relevanceScore,
            interruptionLevel: .active,
            itemContent: "Rent",
            amount: Self.amount,
            dueDate: date(
                year: Self.year,
                month: Self.month,
                day: Self.dueDay
            ),
            notifyDate: date(
                year: Self.year,
                month: Self.month,
                day: Self.notifyDay
            )
        )
    }

    func url(_ value: String) throws -> URL {
        try #require(URL(string: value))
    }

    func date(year: Int, month: Int, day: Int) -> Date {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = .gmt

        var components = DateComponents()
        components.calendar = calendar
        components.timeZone = .gmt
        components.year = year
        components.month = month
        components.day = day

        guard let date = calendar.date(from: components) else {
            preconditionFailure("Invalid date components")
        }
        return date
    }
}
