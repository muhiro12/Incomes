@testable import IncomesLibrary
import Testing

struct UpcomingPaymentNoticeTests {
    @Test
    func requestIdentifier_buildsScheduledIdentifier() {
        let identifier = UpcomingPaymentNotificationPresentation.requestIdentifier(
            for: "item"
        )

        #expect(identifier == "upcoming-payment:item")
    }

    @Test
    func targetContentIdentifier_removesScheduledIdentifierPrefixOnly() {
        #expect(
            UpcomingPaymentNotificationPresentation.targetContentIdentifier(
                fromRequestIdentifier: "upcoming-payment:item"
            ) == "item"
        )
        #expect(
            UpcomingPaymentNotificationPresentation.targetContentIdentifier(
                fromRequestIdentifier: "upcoming-payment-preview:item"
            ) == "upcoming-payment-preview:item"
        )
        #expect(
            UpcomingPaymentNotificationPresentation.targetContentIdentifier(
                fromRequestIdentifier: "unrelated:item"
            ) == "unrelated:item"
        )
    }

    @Test
    func threadIdentifier_formatsYearAndMonth() {
        #expect(
            UpcomingPaymentNotificationPresentation.threadIdentifier(
                year: 2_026,
                month: 1
            ) == "upcoming-payment:2026-01"
        )
    }

    @Test
    func isManagedRequestIdentifier_matchesScheduledAndPreviewIdentifiers() {
        #expect(
            UpcomingPaymentNotificationPresentation.isManagedRequestIdentifier(
                "\(UpcomingPaymentNotificationPresentation.requestIdentifierPrefix)item"
            )
        )
        #expect(
            UpcomingPaymentNotificationPresentation.isManagedRequestIdentifier(
                "\(UpcomingPaymentNotificationPresentation.previewRequestIdentifierPrefix)item"
            )
        )
        #expect(
            UpcomingPaymentNotificationPresentation.isManagedRequestIdentifier(
                "unrelated:item"
            ) == false
        )
    }
}
