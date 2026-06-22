@testable import IncomesLibrary
import Testing

struct MonthlySummaryGenerationErrorTests {
    @available(iOS 26.0, *)
    @Test
    func errorDescription_is_available_for_all_cases() {
        for error in MonthlySummaryGenerationError.allCases {
            #expect(error.errorDescription?.isEmpty == false)
        }
    }

    @available(iOS 26.0, *)
    @Test
    func errorDescription_describes_unsupported_locale() {
        #expect(
            MonthlySummaryGenerationError.unsupportedLocale.errorDescription ==
                "On-device monthly summaries are unavailable in the current language."
        )
    }
}
