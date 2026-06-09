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
    func errorDescription_describes_unsupported_locale() {
        #expect(
            ItemInferenceError.unsupportedLocale.errorDescription ==
                "On-device item inference is unavailable in the current language."
        )
    }
}
