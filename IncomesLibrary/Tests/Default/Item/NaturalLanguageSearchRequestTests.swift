import Foundation
@testable import IncomesLibrary
import Testing

struct NaturalLanguageSearchRequestTests {
    @Test("An inexact source amount cannot ground a rounded model amount")
    func rounded_source_amount_is_not_accepted() {
        var grounding = NaturalLanguageSearchGrounding(
            request: "income of at least 1.00000000000000000000000000000000000000001"
        )
        let isGrounded = grounding.useAmount(1)
        #expect(!isGrounded)
        #expect(grounding.unusedNumberTexts.count == 1)
    }

    @Test("Unsupported semantics cannot be dropped or reinterpreted as literal content", arguments: [
        "expenses in the food category", "交通費カテゴリ", "食費カテゴリの支出",
        "来月のサブスク", "subscriptions next month", "高い買い物", "cheap stuff",
        "rent more than 500", "支出が100未満", "sort rent by date"
    ])
    func unsupported_request_is_rejected_before_generation(_ request: String) {
        #expect(throws: NaturalLanguageSearchError.self) {
            try NaturalLanguageSearchOperations.validatedRequest(request)
        }
    }

    @Test("Supported requests are not blocked by the conservative unsupported vocabulary", arguments: [
        "来月の家賃", "rent next month", "支出が500以上1000以下",
        "income between -300 and -100", "electricity in March 2026"
    ])
    func supported_request_remains_available(_ request: String) throws {
        #expect(try NaturalLanguageSearchOperations.validatedRequest(request) == request)
    }
}
