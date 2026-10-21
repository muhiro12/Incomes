@testable import IncomesLibrary
import Testing

struct UpcomingPaymentNoticeTests {
    @Test
    func requestIdentifier_buildsScheduledIdentifier() {
        let identifier = UpcomingPaymentNotificationPresentation.requestIdentifier(
            for: "item"
        )

        #expect(identifier == "upcomingPayment.item")
    }

    @Test
    func targetContentIdentifier_removesScheduledIdentifierPrefixOnly() {
        #expect(
            UpcomingPaymentNotificationPresentation.targetContentIdentifier(
                fromRequestIdentifier: "upcomingPayment.item"
            ) == "item"
        )
        #expect(
            UpcomingPaymentNotificationPresentation.targetContentIdentifier(
                fromRequestIdentifier: "upcomingPaymentPreview.item"
            ) == "upcomingPaymentPreview.item"
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
            ) == "upcomingPayment.2026-01"
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
