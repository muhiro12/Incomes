import Foundation
@testable import IncomesLibrary
import SwiftData
import Testing

struct UpcomingPaymentTestNoticeTests {
    let context: ModelContext

    init() {
        context = testContext
    }

    @Test
    func returnsUnavailableWithoutNextItem() throws {
        var settings = NotificationSettings()
        settings.thresholdAmount = 500

        let result = try UpcomingPaymentOperations.testNotificationPresentation(
            context: context,
            settings: settings,
            now: shiftedDate("2024-01-10T00:00:00Z"),
            notifyDate: shiftedDate("2024-01-10T00:00:01Z")
        )

        switch result {
        case .unavailable(.noItem):
            break
        default:
            Issue.record("Expected no item result.")
        }
    }

    @Test
    func buildsPreviewForNextItem() throws {
        let nextItem = try makeNextItem()
        var settings = NotificationSettings()
        settings.thresholdAmount = 500
        let notifyDate = shiftedDate("2024-01-10T00:00:01Z")

        let result = try UpcomingPaymentOperations.testNotificationPresentation(
            context: context,
            settings: settings,
            now: shiftedDate("2024-01-10T00:00:00Z"),
            notifyDate: notifyDate
        )

        guard case .presentation(let presentation) = result else {
            Issue.record("Expected a preview presentation.")
            return
        }

        let identifier = try PersistentIdentifierCoder.encode(nextItem.id)

        #expect(presentation.itemContent == "Insurance")
        #expect(
            presentation.requestIdentifier ==
                "\(UpcomingPaymentNotificationPresentation.previewRequestIdentifierPrefix)\(identifier)"
        )
        #expect(presentation.targetContentIdentifier == identifier)
        #expect(presentation.notifyDate == notifyDate)
        #expect(presentation.daysUntilDue == 2)
    }

    func makeNextItem() throws -> Item {
        try createItem(
            context: context,
            input: .init(
                date: shiftedDate("2024-01-12T00:00:00Z"),
                content: "Insurance",
                income: .zero,
                outgo: 800,
                category: "Bills",
                priority: 0
            ),
            repeatCount: 1
        )
    }
}
