@testable import IncomesLibrary
import Testing

struct UpcomingPaymentNoticeTests {
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
