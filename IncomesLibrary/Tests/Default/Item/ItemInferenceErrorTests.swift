@testable import IncomesLibrary
import Testing

struct ItemInferenceErrorTests {
    @available(iOS 26.0, *)
    @Test
    func errorDescription_is_available_for_all_cases() {
        for error in ItemInferenceError.allCases {
            #expect(error.errorDescription?.isEmpty == false)
        }
    }

    @available(iOS 26.0, *)
    @Test
    func unsupported_locale_has_a_distinct_recovery_message() {
        let message = ItemInferenceError.unsupportedLocale.errorDescription
        #expect(message != ItemInferenceError.unavailableModel.errorDescription)
        #expect(message != ItemInferenceError.generationFailed.errorDescription)
    }
}
