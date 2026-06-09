import Foundation
@testable import IncomesLibrary
import Testing

struct ErrorMessageSupportTests {
    private struct LocalizedTestError: LocalizedError {
        var errorDescription: String? {
            "Localized message"
        }
    }

    @Test
    func message_prefers_localized_error_description() {
        let message = ErrorMessageSupport.message(
            from: LocalizedTestError()
        )

        #expect(message == "Localized message")
    }

    @Test
    func message_falls_back_to_localized_description() {
        let error = NSError(
            domain: "ErrorMessageSupportTests",
            code: 1,
            userInfo: [NSLocalizedDescriptionKey: "Fallback message"]
        )

        #expect(ErrorMessageSupport.message(from: error) == "Fallback message")
    }
}
