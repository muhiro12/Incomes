import Foundation
@testable import IncomesLibrary
import Testing

struct ErrorMessageOperationsTests {
    private struct LocalizedTestError: LocalizedError {
        var errorDescription: String? {
            "Localized message"
        }
    }

    @Test
    func message_prefers_localized_error_description() {
        let message = ErrorMessageOperations.message(
            from: LocalizedTestError()
        )

        #expect(message == "Localized message")
    }

    @Test
    func message_falls_back_to_localized_description() {
        let error = NSError(
            domain: "ErrorMessageOperationsTests",
            code: 1,
            userInfo: [NSLocalizedDescriptionKey: "Fallback message"]
        )

        #expect(ErrorMessageOperations.message(from: error) == "Fallback message")
    }
}
